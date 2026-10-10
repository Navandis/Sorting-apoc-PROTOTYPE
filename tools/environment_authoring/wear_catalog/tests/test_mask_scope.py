"""Imperfection approval/export contracts, using isolated output destinations."""
import copy
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.environment_authoring.wear_catalog import authoring, cli, workflow
from tools.environment_authoring.wear_repository.path_guard import Repository

ROOT = Path(__file__).resolve().parents[4]
USES = ["TINTED_OPACITY_LAYER", "WEAR_OPACITY_MODULATION"]


class MaskScopeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "opacity.png").write_bytes(b"reviewed opacity")
        (self.root / "roughness.png").write_bytes(b"different roughness")
        self.repo = Repository(self.root)
        self.candidate = dict(stable_id="eaf4:test:new_mask", source_class="IMPERFECTION_MASK",
                              profile="IMPERFECTION_TEXTURE_PROFILE", available_resolutions=["1K"],
                              maps_by_resolution={"1K": {
                                  "opacity": [{"relative_path": "opacity.png"}],
                                  "roughness": [{"relative_path": "roughness.png"}]}})
        self.index = dict(schema_version=1, scanner_revision="eaf4a-1",
                          logical_candidates=[self.candidate], source_families=[])
        self.staged = workflow.stage_candidate(self.repo, self.candidate, "1K", self.root / "cache")
        self.decision = workflow.decision_template(self.staged, dict(semantic_category="IMPERFECTION_MASK"))
        self.decision.update(decision="APPROVED", decision_revision=1,
                             scalar_channel="opacity.red", supported_uses=USES.copy())
        self.catalog_path = self.root / "catalog.json"

    def catalog(self, decision=None):
        record = copy.deepcopy(decision or self.decision)
        record["status"] = record.pop("decision")
        record.update(effective_status="APPROVED", current_source_fingerprint=record["reviewed_source_fingerprint"])
        return dict(schema_version=1, wear=[record])

    def export(self, catalog=None):
        if catalog is not None:
            self.catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
        with patch.object(authoring, "DATA", self.root), patch.object(authoring, "CATALOG", self.catalog_path), \
             patch.object(authoring, "CACHE", self.root / "approved_cache"), \
             patch.object(cli, "load_index", return_value=self.index), \
             patch.object(cli, "load_repository", return_value=self.repo):
            cli.restage_approved()
        return json.loads((self.root / "approved_specs/approved_masks.json").read_text())["masks"][0]

    def test_reviewed_opacity_is_exported_when_roughness_also_exists(self):
        entry = self.export(self.catalog())
        self.assertEqual(entry["texture"], workflow.CACHE_RESOURCE_ROOT + "/" + self.staged["maps"]["opacity"]["cache_relative"])

    def test_both_uses_are_not_modulation_only(self):
        entry = self.export(self.catalog())
        self.assertFalse(entry["modulation_only"])
        self.assertEqual(entry["supported_uses"], USES)
        self.assertEqual(entry["scalar_channel"], "opacity.red")

    def test_selected_hash_and_export_are_deterministic_for_each_scope(self):
        for channel, uses in [("opacity.red", USES), ("roughness.red", [USES[0]]),
                              ("roughness.red", [USES[1]])]:
            with self.subTest(channel=channel, uses=uses):
                decision = dict(self.decision, scalar_channel=channel, supported_uses=uses)
                entry = self.export(self.catalog(decision))
                mask = channel.split(".")[0]
                self.assertEqual(entry["texture"], workflow.CACHE_RESOURCE_ROOT + "/" + self.staged["maps"][mask]["cache_relative"])
                self.assertEqual(entry["scalar_sha256"], self.staged["maps"][mask]["sha256"])
                self.assertEqual(entry["supported_uses"], uses)
                self.assertEqual(entry["modulation_only"], uses == [USES[1]])
                before = (self.root / "approved_specs/approved_masks.json").read_bytes()
                self.assertEqual(entry, self.export())
                self.assertEqual(before, (self.root / "approved_specs/approved_masks.json").read_bytes())
                self.assertFalse(list((self.root / "approved_specs").glob("*.tres")))

    def test_invalid_scopes_fail_before_any_output_write(self):
        variants = [dict(scalar_channel=None), dict(scalar_channel="roughness.green"),
                    dict(supported_uses=[]), dict(supported_uses=[USES[0], USES[0]]),
                    dict(supported_uses=["PHYSICAL_ROUGHNESS"]), dict(supported_uses="TINTED_OPACITY_LAYER")]
        for changed in variants:
            with self.subTest(changed=changed):
                catalog = self.catalog(dict(self.decision, **changed))
                self.catalog_path.write_text(json.dumps(catalog))
                before = self.catalog_path.read_bytes()
                with self.assertRaisesRegex(ValueError, "scalar_channel|supported_uses"):
                    self.export()
                self.assertEqual(before, self.catalog_path.read_bytes())
                self.assertFalse((self.root / "approved_specs").exists())

    def test_unannotated_new_approval_is_rejected(self):
        decision = copy.deepcopy(self.decision)
        decision.pop("scalar_channel")
        decision.pop("supported_uses")
        with self.assertRaisesRegex(ValueError, "scalar_channel"):
            workflow.reconcile(dict(schema_version=1, wear=[]), [decision],
                               {decision["source_stable_id"]: decision["reviewed_source_fingerprint"]})

    def test_template_is_pending_and_does_not_guess_reviewed_channel_or_uses(self):
        template = workflow.decision_template(self.staged, {})
        self.assertEqual(template["decision"], "PENDING")
        self.assertEqual(template["scalar_channel"], "")
        self.assertEqual(template["supported_uses"], [])

    def test_scope_revision_and_idempotence(self):
        catalog, _ = workflow.reconcile(dict(schema_version=1, wear=[]), [self.decision],
                                        {self.decision["source_stable_id"]: self.decision["reviewed_source_fingerprint"]})
        same, audit = workflow.reconcile(catalog, [self.decision],
                                         {self.decision["source_stable_id"]: self.decision["reviewed_source_fingerprint"]})
        self.assertEqual(same, catalog)
        self.assertEqual(audit, [])
        changed = dict(self.decision, supported_uses=[USES[0]])
        with self.assertRaisesRegex(ValueError, "higher revision"):
            workflow.reconcile(catalog, [changed], {changed["source_stable_id"]: changed["reviewed_source_fingerprint"]})
        changed["decision_revision"] = 2
        updated, _ = workflow.reconcile(catalog, [changed], {changed["source_stable_id"]: changed["reviewed_source_fingerprint"]})
        self.assertEqual(updated["wear"][0]["supported_uses"], [USES[0]])

    def test_missing_selected_map_and_ambiguity_fail_without_output_write(self):
        for defect in ("missing", "ambiguous", "resolution", "class"):
            with self.subTest(defect=defect):
                candidate = copy.deepcopy(self.candidate)
                if defect == "missing": candidate["maps_by_resolution"]["1K"].pop("opacity")
                if defect == "ambiguous": candidate["maps_by_resolution"]["1K"]["opacity"] *= 2
                if defect == "resolution": candidate["available_resolutions"] = ["8K"]
                if defect == "class": candidate["source_class"] = "UNKNOWN"
                index = dict(self.index, logical_candidates=[candidate])
                with self.assertRaises(ValueError):
                    workflow.validate_decision_sources(self.repo, index, [self.decision], dict(schema_version=1, wear=[]))

    def test_changed_source_fingerprint_fails_decision_preflight(self):
        (self.root / "opacity.png").write_bytes(b"source changed after review")
        with self.assertRaisesRegex(ValueError, "fingerprint"):
            workflow.validate_decision_sources(self.repo, self.index, [self.decision], dict(schema_version=1, wear=[]))

    def test_dry_run_writes_nothing_and_invalid_later_record_cannot_partially_export(self):
        self.catalog_path.write_text(json.dumps(self.catalog()))
        before = self.catalog_path.read_bytes()
        with patch.object(authoring, "CATALOG", self.catalog_path), patch.object(cli, "load_index", return_value=self.index), \
             patch.object(cli, "load_repository", return_value=self.repo):
            plan = cli.restage_approved(output_dir=self.root / "scratch", dry_run=True)
        self.assertEqual(len(plan["masks"]), 1)
        self.assertEqual(before, self.catalog_path.read_bytes())
        self.assertFalse((self.root / "scratch").exists())
        # Validate all approvals before staging the first one.
        second = dict(self.candidate, stable_id="eaf4:test:second_mask")
        self.index["logical_candidates"].append(second)
        bad = copy.deepcopy(self.catalog()["wear"][0])
        bad.update(source_stable_id=second["stable_id"], catalog_wear_id=workflow.catalog_id(second["stable_id"]), scalar_channel="invalid")
        catalog = self.catalog()
        catalog["wear"].append(bad)
        self.catalog_path.write_text(json.dumps(catalog))
        before = self.catalog_path.read_bytes()
        with self.assertRaisesRegex(ValueError, "scalar_channel"):
            self.export()
        self.assertEqual(before, self.catalog_path.read_bytes())
        self.assertFalse((self.root / "approved_specs").exists())
        self.assertFalse((self.root / "approved_cache").exists())

    def test_scope_cannot_claim_physical_material_or_new_modulation_target(self):
        decision = dict(self.decision, patch_mode="EAF4_PATCH")
        with self.assertRaisesRegex(ValueError, "contradicts"):
            workflow.reconcile(dict(schema_version=1, wear=[]), [decision],
                               {decision["source_stable_id"]: decision["reviewed_source_fingerprint"]})
        conventional = dict(self.candidate, source_class="MASKED_DECAL")
        with self.assertRaisesRegex(ValueError, "require an IMPERFECTION_MASK"):
            workflow.validate_decision_sources(self.repo, dict(self.index, logical_candidates=[conventional]),
                                               [self.decision], dict(schema_version=1, wear=[]))

    def test_source_changed_after_plan_preserves_accepted_cache_and_outputs(self):
        self.export(self.catalog())
        protected = [self.catalog_path, *list((self.root / "approved_specs").glob("*.*")),
                     *[p for p in (self.root / "approved_cache").rglob("*") if p.is_file()]]
        before = {p:p.read_bytes() for p in protected}
        original_stage = workflow.stage_candidate
        def change_before_staging(*args, **kwargs):
            if not kwargs.get("dry_run", False):
                (self.root / "opacity.png").write_bytes(b"changed between planning and cache write")
            return original_stage(*args, **kwargs)
        with patch.object(workflow, "stage_candidate", side_effect=change_before_staging):
            with self.assertRaisesRegex(ValueError, "fingerprint|changed"):
                self.export()
        self.assertEqual(before, {p:p.read_bytes() for p in protected})


class ActualSourceCompatibilityTests(unittest.TestCase):
    """Actual audited IDs/maps, hypothetical decisions confined to memory/temp outputs."""
    def setUp(self):
        from tools.environment_authoring.wear_repository.path_guard import load_repository
        from tools.environment_authoring.wear_repository.source_index import load_index
        self.repo = load_repository()
        self.index = load_index()
        self.catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
        self.manifest = json.loads((ROOT / "environment_authoring/wear/imperfection_experiments/manifest.json").read_text())
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.catalog_path = self.root / "catalog.json"

    def plan(self, catalog, output=None):
        self.catalog_path.write_text(json.dumps(catalog))
        with patch.object(authoring, "CATALOG", self.catalog_path), patch.object(cli, "load_repository", return_value=self.repo), \
             patch.object(cli, "load_index", return_value=self.index):
            return cli.restage_approved(output_dir=output, dry_run=output is None)

    def test_trusted_legacy_grunge_and_all_conventional_specs_are_unchanged(self):
        before = authoring.CATALOG.read_bytes()
        # Preserve revision-1 compatibility independently of later live approvals.
        initial = json.loads((authoring.DATA / "decisions/2026-09-27-eaf4b-human-review.json").read_text(encoding="utf-8"))
        historical = dict(schema_version=1, wear=[copy.deepcopy(r) for r in self.catalog["wear"]
                                                if r["semantic_category"] != "IMPERFECTION_MASK"])
        for decision in initial["decisions"]:
            if decision["semantic_category"] != "IMPERFECTION_MASK": continue
            record = copy.deepcopy(decision)
            record["status"] = record.pop("decision")
            record.update(effective_status=record["status"], current_source_fingerprint=record["reviewed_source_fingerprint"])
            historical["wear"].append(record)
        historical["wear"].sort(key=lambda r:r["source_stable_id"])
        plan = self.plan(historical)
        legacy = next(r for r in historical["wear"] if r["source_stable_id"] == workflow.LEGACY_GRUNGE_ID)
        old_export = dict(catalog_wear_id=legacy["catalog_wear_id"], source_stable_id=legacy["source_stable_id"],
                          source_fingerprint=legacy["reviewed_source_fingerprint"], modulation_only=True,
                          texture=workflow.CACHE_RESOURCE_ROOT + "/" + legacy["catalog_wear_id"] + "/1k/roughness.jpg")
        new_export = plan["masks"][0]
        self.assertEqual(len(plan["masks"]), 1)
        for key, value in old_export.items(): self.assertEqual(new_export[key], value)
        self.assertEqual(new_export["scalar_channel"], "roughness.red")
        self.assertEqual(new_export["supported_uses"], ["WEAR_OPACITY_MODULATION"])
        texture = ROOT / new_export["texture"].removeprefix("res://")
        self.assertEqual(new_export["scalar_sha256"], hashlib.sha256(texture.read_bytes()).hexdigest())
        self.assertEqual(len(plan["specs"]), 11)
        for filename, text in plan["specs"].items():
            self.assertEqual(text, (authoring.DATA / "approved_specs" / filename).read_text(encoding="utf-8"), filename)
        scratch = self.root / "no_op"
        scratch.mkdir()
        for filename in plan["specs"]:
            (scratch / filename).write_bytes((authoring.DATA / "approved_specs" / filename).read_bytes())
        original_bytes = {p.name:p.read_bytes() for p in scratch.glob("*.tres")}
        self.plan(historical, scratch)
        self.plan(historical, scratch)
        self.assertEqual(original_bytes, {p.name:p.read_bytes() for p in scratch.glob("*.tres")})
        for identifier in workflow.LEAKAGE_MODULATION_IDS:
            self.assertIn(old_export["texture"], plan["specs"][identifier + ".tres"])
        decision = workflow._human_fields(legacy)
        workflow.validate_decision_sources(self.repo, self.index, [decision], historical)
        latest = workflow.current_fingerprints(self.repo, self.index, historical["wear"])
        masks = workflow.current_imperfection_status(self.repo, self.index, historical["wear"])
        same, audit = workflow.reconcile(historical, [decision], latest, masks, source_index=self.index)
        self.assertEqual(same, historical)
        self.assertEqual(audit, [])
        with self.assertRaisesRegex(ValueError, "scalar_channel"):
            workflow.validate_decision_sources(self.repo, self.index, [decision], dict(schema_version=1, wear=[]))
        revised = dict(decision, decision_revision=2)
        with self.assertRaisesRegex(ValueError, "scalar_channel"):
            workflow.validate_decision_sources(self.repo, self.index, [revised], historical)
        self.assertEqual(before, authoring.CATALOG.read_bytes())

    def test_actual_sixteen_hypothetical_approvals_export_exact_eleven_five_channels(self):
        from tools.environment_authoring.wear_catalog.build_imperfection_experiments import audit
        candidates, rows = audit(self.repo, self.index, self.catalog)
        self.assertEqual(rows, self.manifest["candidates"])
        decisions = []
        existing = {r["source_stable_id"]: r for r in self.catalog["wear"]}
        for candidate, row in zip(candidates, rows):
            staged = workflow.stage_candidate(self.repo, candidate, "1K", self.root / "unused", dry_run=True)
            hints = existing.get(row["stable_id"], {})
            decision = workflow.decision_template(staged, hints)
            decision.update(decision="APPROVED", decision_revision=hints.get("decision_revision", 0) + 1,
                            scalar_channel=row["channel"] + ".red", supported_uses=USES.copy(),
                            review_notes="Hypothetical test only; no live human decision is written.")
            decisions.append(decision)
        workflow.validate_decision_sources(self.repo, self.index, decisions, self.catalog)
        latest = workflow.current_fingerprints(self.repo, self.index, self.catalog["wear"] + decisions)
        dependencies = workflow.current_imperfection_status(self.repo, self.index, self.catalog["wear"])
        future, _ = workflow.reconcile(self.catalog, decisions, latest, dependencies, source_index=self.index)
        plan = self.plan(future, self.root / "out")
        self.assertEqual(len(plan["masks"]), 16)
        self.assertEqual(len(plan["specs"]), 11)
        for row in rows:
            entry = next(m for m in plan["masks"] if m["source_stable_id"] == row["stable_id"])
            self.assertEqual(entry["scalar_channel"], row["channel"] + ".red")
            self.assertEqual(entry["scalar_sha256"], row["sha256"])
            self.assertEqual(entry["source_fingerprint"], row["source_fingerprint"])
            self.assertEqual(entry["supported_uses"], USES)
            self.assertFalse(entry["modulation_only"])
            cache = self.root / "out/cache" / entry["texture"].removeprefix(workflow.CACHE_RESOURCE_ROOT + "/")
            self.assertEqual(hashlib.sha256(cache.read_bytes()).hexdigest(), row["sha256"])
        self.assertEqual(sum(m["scalar_channel"] == "opacity.red" for m in plan["masks"]), 11)
        self.assertEqual(sum(m["scalar_channel"] == "roughness.red" for m in plan["masks"]), 5)
        outputs = {p.name:p.read_bytes() for p in (self.root / "out").glob("*.*")}
        self.assertEqual(plan, self.plan(future, self.root / "out"))
        self.assertEqual(outputs, {p.name:p.read_bytes() for p in (self.root / "out").glob("*.*")})
        # Scope does not grant conventional overlays beyond the established pair.
        unrelated = copy.deepcopy(future)
        other = next(r for r in unrelated["wear"] if r["semantic_category"] == "GRIME")
        donor = next(r for r in future["wear"] if r["catalog_wear_id"] in workflow.LEAKAGE_MODULATION_IDS)
        other["imperfection"] = donor["imperfection"]
        with self.assertRaisesRegex(ValueError, "two approved soft Leakage"):
            self.plan(unrelated)
        other["catalog_wear_id"] = donor["catalog_wear_id"]
        with self.assertRaisesRegex(ValueError, "two approved soft Leakage|catalog_wear_id"):
            self.plan(unrelated)
        standalone = copy.deepcopy(future)
        next(r for r in standalone["wear"] if r["source_stable_id"] == workflow.LEGACY_GRUNGE_ID)["supported_uses"] = [USES[0]]
        with self.assertRaisesRegex(ValueError, "not approved for WEAR_OPACITY_MODULATION"):
            self.plan(standalone)


if __name__ == "__main__":
    unittest.main()
