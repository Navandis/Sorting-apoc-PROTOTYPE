import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from zipfile import ZipFile

from tools.environment_authoring.wear_repository.path_guard import Repository, BoundaryError
from tools.environment_authoring.wear_catalog import workflow, authoring, cli


class WearWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "color.png").write_bytes(b"color")
        (self.root / "mask.png").write_bytes(b"mask")
        (self.root / "rough.png").write_bytes(b"rough")
        (self.root / "other.png").write_bytes(b"other")
        self.repo = Repository(self.root)
        self.candidate = {
            "stable_id": "eaf4:test:mark",
            "source_class": "MASKED_DECAL",
            "profile": "FAB_DECAL_PROFILE",
            "available_resolutions": ["1K", "2K"],
            "maps_by_resolution": {
                "1K": {"basecolor": [{"relative_path": "other.png"}], "opacity": [{"relative_path": "mask.png"}]},
                "2K": {"basecolor": [{"relative_path": "color.png"}], "opacity": [{"relative_path": "mask.png"}],
                       "roughness": [{"relative_path": "rough.png"}], "height": [{"relative_path": "other.png"}]},
            },
            "opacity_source": ["SEPARATE_MASK"],
            "source_physical_width_m": 0.5,
            "source_physical_height_m": 0.25,
            "tileable": False,
            "metadata_facts": {"kind": "decal"},
            "warnings": [],
        }
        self.index = {"schema_version": 1, "scanner_revision": "eaf4a-1",
                      "logical_candidates": [self.candidate], "source_families": []}

    def test_selects_only_needed_resolution_and_channels(self):
        selected = workflow.select_maps(self.candidate, "2K")
        self.assertEqual(set(selected), {"basecolor", "opacity", "roughness"})
        self.assertEqual(selected["basecolor"], "color.png")
        with self.assertRaises(ValueError):
            workflow.select_maps(self.candidate, "4K")

    def test_staging_is_guarded_and_content_fingerprinted(self):
        output = self.root / "cache"
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", output)
        self.assertEqual(len(staged["maps"]), 3)
        self.assertEqual((output / staged["maps"]["basecolor"]["cache_relative"]).read_bytes(), b"color")
        self.assertFalse(any(p.name == "other.png" for p in output.rglob("*")))
        original = staged["source_fingerprint"]
        (self.root / "color.png").write_bytes(b"changed")
        self.assertNotEqual(workflow.stage_candidate(self.repo, self.candidate, "2K", output)["source_fingerprint"], original)
        self.candidate["maps_by_resolution"]["2K"]["basecolor"][0]["relative_path"] = "../escape.png"
        with self.assertRaises((ValueError, BoundaryError)):
            workflow.stage_candidate(self.repo, self.candidate, "2K", output)

    def test_synthetic_approved_restaging_and_stale_refusal(self):
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        decision = workflow.decision_template(staged, {"semantic_category": "crack", "surface_capabilities": ["WALL"]})
        decision["decision"] = "APPROVED"
        decision["decision_revision"] = 1
        catalog, _ = workflow.reconcile({"schema_version": 1, "wear": []}, [decision],
                                         {self.candidate["stable_id"]: staged["source_fingerprint"]})
        record = workflow.query(catalog)[0]
        fresh = workflow.stage_current_approved(self.repo, self.index, record, self.root / "approved_cache")
        self.assertEqual(fresh["source_fingerprint"], record["reviewed_source_fingerprint"])
        self.assertEqual(len(fresh["maps"]), 3)
        stale, _ = workflow.reconcile(catalog, [], {self.candidate["stable_id"]: "changed"})
        with self.assertRaises(ValueError):
            workflow.stage_current_approved(self.repo, self.index, stale["wear"][0], self.root / "approved_cache")

    def test_rejects_archive_and_ambiguous_maps(self):
        self.candidate["maps_by_resolution"]["2K"]["opacity"] = [{"relative_path": "mask.png"}, {"relative_path": "other.png"}]
        with self.assertRaises(ValueError):
            workflow.select_maps(self.candidate, "2K")
        self.candidate["maps_by_resolution"]["2K"]["opacity"] = [{"relative_path": "bundle.zip"}]
        with self.assertRaises(ValueError):
            workflow.select_maps(self.candidate, "2K")

    def test_batch_accepts_only_stable_ids_and_fresh_index(self):
        batch = workflow.make_batch("wear_foundation_01", self.index, [{"stable_id": self.candidate["stable_id"], "resolution": "2K"}])
        self.assertEqual(workflow.validate_batch(batch, self.index)[0]["stable_id"], self.candidate["stable_id"])
        batch["source_index_fingerprint"] = "old"
        with self.assertRaises(ValueError):
            workflow.validate_batch(batch, self.index)
        batch["source_index_fingerprint"] = workflow.index_fingerprint(self.index)
        batch["candidates"][0]["source_path"] = "C:/outside.png"
        with self.assertRaises(ValueError):
            workflow.validate_batch(batch, self.index)

    def test_catalog_states_and_current_query(self):
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        pending = workflow.decision_template(staged, {"semantic_category": "crack", "cause_tags": ["impact"], "surface_capabilities": ["WALL"]})
        self.assertEqual(pending["decision"], "PENDING")
        decision = {**pending, "decision": "APPROVED", "decision_revision": 1}
        catalog, audit = workflow.reconcile({"schema_version": 1, "wear": []}, [decision], {self.candidate["stable_id"]: staged["source_fingerprint"]})
        self.assertEqual(len(audit), 1)
        self.assertEqual(len(workflow.query(catalog, semantic_category="crack", surface_capability="WALL")), 1)
        same, audit = workflow.reconcile(catalog, [decision], {self.candidate["stable_id"]: staged["source_fingerprint"]})
        self.assertEqual(same, catalog)
        self.assertEqual(audit, [])
        stale, _ = workflow.reconcile(catalog, [], {self.candidate["stable_id"]: "changed"})
        self.assertEqual(stale["wear"][0]["effective_status"], "STALE")
        self.assertEqual(workflow.query(stale), [])
        missing, _ = workflow.reconcile(catalog, [], {})
        self.assertEqual(missing["wear"][0]["effective_status"], "SOURCE_MISSING")
        for state in ("REJECTED", "DEFERRED"):
            new = {**decision, "decision": state, "decision_revision": 2}
            result, _ = workflow.reconcile(catalog, [new], {self.candidate["stable_id"]: staged["source_fingerprint"]})
            self.assertEqual(result["wear"][0]["effective_status"], state)


    def test_unsupported_and_missing_freshness(self):
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        record = workflow.decision_template(staged, {})
        record["decision"] = "APPROVED"
        record["decision_revision"] = 1
        catalog, _ = workflow.reconcile({"schema_version": 1, "wear": []}, [record],
                                         {self.candidate["stable_id"]: staged["source_fingerprint"]})
        unsupported = {**self.candidate, "source_class": "FULL_SURFACE_MATERIAL"}
        index = {**self.index, "logical_candidates": [unsupported]}
        current = workflow.current_fingerprints(self.repo, index, catalog["wear"])
        self.assertEqual(current[self.candidate["stable_id"]], "UNSUPPORTED")
        result, _ = workflow.reconcile(catalog, [], current)
        self.assertEqual(result["wear"][0]["effective_status"], "UNSUPPORTED")
        self.assertEqual(workflow.query(result), [])
        missing = {**self.index, "logical_candidates": []}
        current = workflow.current_fingerprints(self.repo, missing, catalog["wear"])
        self.assertIsNone(current[self.candidate["stable_id"]])
        (self.root / "color.png").unlink()
        current = workflow.current_fingerprints(self.repo, self.index, catalog["wear"])
        self.assertIsNone(current[self.candidate["stable_id"]])

    def test_spec_serialization_preserves_approved_controls(self):
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        entry = {"semantic_category": "crack", "cause_tags": ["impact"],
                 "surface_capabilities": ["WALL"], "selection_rationale": "fixture",
                 "initial_parameters": {"render_mode": "CUTOUT", "physical_size_m": [0.7, 0.3],
                     "surface_offset_m": 0.002, "opacity_multiplier": 0.8, "albedo_strength": 0.2,
                     "normal_strength": 0.7, "normal_y_flip": True, "roughness_strength": 0.6,
                     "albedo_tint": [0.2, 0.3, 0.4], "edge_feather": 0.025,
                     "imperfection": {"scale": [2.0, 3.0], "rotation": 45.0,
                                       "contrast": 1.8, "strength": 0.6},
                     "provenance": "human-approved"}}
        text = authoring.spec_text(entry, staged, self.candidate, "test/mask.png")
        for expected in ("normal_y_flip = true", "albedo_tint = Color(0.2, 0.3, 0.4, 1.0)",
                         "edge_feather = 0.025", "imperfection_scale = Vector2(2.0, 3.0)",
                         "imperfection_rotation = 45.0", "imperfection_strength = 0.6"):
            self.assertIn(expected, text)

    def test_review_zip_uses_manifest_allowlist(self):
        with patch.object(authoring, "REPORTS", self.root):
            review = self.root / "test_review"
            review.mkdir()
            (review / "manifest.json").write_text(json.dumps({"records": [{"filename": "capture.png"}]}), encoding="utf-8")
            (review / "batch_summary.md").write_text("review", encoding="utf-8")
            (review / "decision_template.json").write_text("{}", encoding="utf-8")
            (review / "capture.png").write_bytes(b"png")
            (review / "stale.png").write_bytes(b"old")
            archive = authoring.package_review("test_review")
            with ZipFile(archive) as package:
                self.assertEqual(set(package.namelist()),
                                 {"manifest.json", "batch_summary.md", "decision_template.json", "capture.png"})


    def test_synthetic_approved_restages_to_spec_with_guarded_mask(self):
        mask_candidate = {**self.candidate, "stable_id": "eaf4:mask:grunge",
                          "source_class": "IMPERFECTION_MASK", "profile": "IMPERFECTION_TEXTURE_PROFILE",
                          "available_resolutions": ["1K"],
                          "maps_by_resolution": {"1K": {"roughness": [{"relative_path": "other.png"}]}}}
        index = {**self.index, "logical_candidates": [self.candidate, mask_candidate]}
        staged = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        mask_staged = workflow.stage_candidate(self.repo, mask_candidate, "1K", self.root / "cache")
        decision = workflow.decision_template(staged, {"semantic_category": "stain",
            "surface_capabilities": ["WALL"], "imperfection": {
                "source_stable_id": mask_candidate["stable_id"],
                "source_fingerprint": mask_staged["source_fingerprint"],
                "selected_resolution": "1K", "scale": [2.0, 3.0],
                "rotation": 45.0, "contrast": 1.8, "strength": 0.6}})
        decision["decision"] = "APPROVED"
        decision["decision_revision"] = 1
        catalog, _ = workflow.reconcile({"schema_version": 1, "wear": []}, [decision],
                                         {self.candidate["stable_id"]: staged["source_fingerprint"]})
        catalog_path = self.root / "catalog.json"
        catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
        with patch.object(authoring, "DATA", self.root), patch.object(authoring, "CATALOG", catalog_path), \
             patch.object(authoring, "CACHE", self.root / "approved_cache"), \
             patch.object(cli, "load_index", return_value=index), \
             patch.object(cli, "load_repository", return_value=self.repo):
            cli.restage_approved()
        spec_path = self.root / "approved_specs" / (staged["catalog_wear_id"] + ".tres")
        self.assertTrue(spec_path.is_file())
        spec = spec_path.read_text(encoding="utf-8")
        self.assertIn("imperfection_mask_texture = ExtResource", spec)
        self.assertIn("imperfection_scale = Vector2(2.0, 3.0)", spec)
        self.assertIn("source_fingerprint = ", spec)
        (self.root / "other.png").write_bytes(b"changed")
        with patch.object(authoring, "DATA", self.root), patch.object(authoring, "CATALOG", catalog_path), \
             patch.object(authoring, "CACHE", self.root / "approved_cache"), \
             patch.object(cli, "load_index", return_value=index), \
             patch.object(cli, "load_repository", return_value=self.repo):
            cli.restage_approved()
        stale_catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        self.assertEqual(stale_catalog["wear"][0]["effective_status"], "STALE")
        self.assertEqual(workflow.query(stale_catalog), [])


    def test_approved_imperfection_restages_as_modulation_only(self):
        candidate = {**self.candidate, "stable_id": "eaf4:mask:grunge",
                     "source_class": "IMPERFECTION_MASK", "profile": "IMPERFECTION_TEXTURE_PROFILE",
                     "available_resolutions": ["1K"],
                     "maps_by_resolution": {"1K": {"roughness": [{"relative_path": "other.png"}]}}}
        index = {**self.index, "logical_candidates": [candidate]}
        staged = workflow.stage_candidate(self.repo, candidate, "1K", self.root / "cache")
        decision = workflow.decision_template(staged, {"semantic_category": "IMPERFECTION_MASK",
                                                        "surface_capabilities": ["PLANAR_ANY"]})
        decision["decision"] = "APPROVED"
        decision["decision_revision"] = 1
        catalog, _ = workflow.reconcile({"schema_version": 1, "wear": []}, [decision],
                                         {candidate["stable_id"]: staged["source_fingerprint"]})
        catalog_path = self.root / "catalog.json"
        catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
        with patch.object(authoring, "DATA", self.root), patch.object(authoring, "CATALOG", catalog_path), \
             patch.object(authoring, "CACHE", self.root / "approved_cache"), \
             patch.object(cli, "load_index", return_value=index), \
             patch.object(cli, "load_repository", return_value=self.repo):
            cli.restage_approved()
        approved = self.root / "approved_specs"
        masks = json.loads((approved / "approved_masks.json").read_text(encoding="utf-8"))
        self.assertEqual(len(masks["masks"]), 1)
        self.assertEqual(masks["masks"][0]["source_stable_id"], candidate["stable_id"])
        self.assertEqual(masks["masks"][0]["source_fingerprint"], staged["source_fingerprint"])
        self.assertEqual(masks["masks"][0]["texture"], "res://assets/environment/wear/eaf4_cache/" +
                         staged["maps"]["roughness"]["cache_relative"])
        self.assertFalse((approved / (staged["catalog_wear_id"] + ".tres")).exists())


    def test_rerun_selects_exactly_unresolved_sources(self):
        second = {**self.candidate, "stable_id": "eaf4:test:pending"}
        first_stage = workflow.stage_candidate(self.repo, self.candidate, "2K", self.root / "cache")
        second_stage = workflow.stage_candidate(self.repo, second, "2K", self.root / "cache")
        batch = workflow.make_batch("wear_foundation_01", {**self.index,
            "logical_candidates": [self.candidate, second]}, [
            {"stable_id": self.candidate["stable_id"], "resolution": "2K", "surface_capabilities": ["WALL"]},
            {"stable_id": second["stable_id"], "resolution": "2K", "surface_capabilities": ["WALL"]}])
        stage = {"batch_id": "wear_foundation_01", "source_index_fingerprint": batch["source_index_fingerprint"],
                 "candidates": [first_stage, second_stage]}
        catalog = {"schema_version": 1, "wear": [{"source_stable_id": self.candidate["stable_id"],
                                                    "effective_status": "APPROVED"}]}
        entry = {"source_stable_id": second["stable_id"], "catalog_wear_id": second_stage["catalog_wear_id"],
                 "diagnostic_context": "WEAR_DIAGNOSTIC_LIGHT",
                 "calibrated_parameters": {"opacity": 1.0, "albedo_strength": 0.45},
                 "rationale": "Show the subtle mark clearly."}
        config = {"schema_version": 1, "rerun_id": "wear_foundation_01_rerun_01",
                  "original_batch_id": "wear_foundation_01",
                  "source_index_fingerprint": batch["source_index_fingerprint"], "candidates": [entry]}
        selected = workflow.validate_rerun(config, batch, stage, catalog)
        self.assertEqual(len(selected), 1)
        self.assertEqual(selected[0]["source_stable_id"], second["stable_id"])
        with self.assertRaises(ValueError):
            workflow.validate_rerun({**config, "candidates": []}, batch, stage, catalog)
        with self.assertRaises(ValueError):
            workflow.validate_rerun({**config, "candidates": [{**entry,
                "source_stable_id": self.candidate["stable_id"]}]}, batch, stage, catalog)


if __name__ == "__main__":
    unittest.main()
