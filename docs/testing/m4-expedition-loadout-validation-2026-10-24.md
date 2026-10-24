# M4 Expedition Loadout — local candidate validation

24 October 2026. **M4 TECHNICALLY VERIFIED / INDEPENDENT CONTEXTUAL REVIEW AND HUMAN PLAYTEST PENDING.** No unresolved required technical check or implementation blocker. This is a local candidate, without human promotion or publication. No merge, push, PR, M5 or Expedition outcomes were performed.

Executor: Codex / GPT-6 family; the runtime did not expose a more specific model variant. One implementer executed inline. A fresh independent contextual review remains the next gate.

## Candidate and authorities

Authoritative checkout: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`, branch `codex/m4-expedition-loadout`.

| Revision | Identity |
|---|---|
| Published main at read-only preflight | `3bb69a906e921f06dd12c61bd4d8f33db35d6fce` |
| Twelve-item addition ancestor | `e8ed1200019cd1206a303e1c9e524899d96948e3` |
| Developer's saved physical checkpoint | `a669c0d5c218696d9f977a505551063e0160b69f` |
| Verified implementation base | `71101cf6bd6302842e7c7090a0849b25ef9b75a5` |
| Locked data, loadout and timed fixture | `d81d48a236e78fd40f44b27d562bcdae32d219ae` |
| Carousel, continuation and reporting | `f5eae9b89f208033c34013a15b178ce9745c7c8a` |

The four pre-M4 revisions form the required ancestry in the order above. The starting tree was clean; the definitions at `71101cf` preserved the physical checkpoint. No Godot process was running. Four other registered worktrees were inventoried and left untouched. Remote main was queried using `git -c http.sslBackend=openssl ls-remote origin refs/heads/main refs/heads/codex/pre-m4-catalogue-topup-12`; the unpublished top-up branch was absent remotely. Default Schannel reported `SEC_E_NO_CREDENTIALS`; the read-only OpenSSL override succeeded without changing Git configuration.

The final documentation commit, full candidate SHA, patch checksums and final clean-tree observation are in external `final-delivery.json`. The review patch is `m4-base-to-candidate.patch` from `71101cf` through that final candidate, excluding licensed assets. `m4-published-base-context.patch` additionally includes the unpublished top-up ancestry from `3bb69a9`; use it as context, without treating the top-up as published.

Implementation input is frozen verbatim under [data/scenarios/m4](../../data/scenarios/m4/README.md). Packet hashes, verified against both working files and final committed blobs:

| Packet file | SHA-256 |
|---|---|
| README.md | `2deaabbaf491fab27f13e4aff0c28e8d20e7ee7d87498d362fe4cb47fb981e33` |
| Handoff | `08cd515bf28cedabba2765700971659c2a260062a164090a4d574aafeecc7e03` |
| Locked baseline JSON | `31bb108cccf4d2de3851dbf6b2253e1d61a40ff078c997e9be91454ba90f6ac6` |
| Locked baseline CSV | `0ae761cce49181445e6e5d83b91c6e45af512a3ee1366defc6a2878d3920660b` |

The packet's `.gitattributes` preserves delivered bytes, including the CSV's CRLF endings. Historical packet statements saying implementation is next describe the packet's preparation status; this validation record describes the resulting candidate.

## Implemented contract

All 167 approved Utility/Bulk rows are explicit in the existing definitions; Medical context overrides agree. Player capacity is 20 Bulk. Teams form full groups of four followed by at most one remainder, without a team-count cap. Each member supplies 28 raw Bulk and Food/Hydration/Medical/Weapons/Protection requirements of 12/12/6/12/12. The authored roster forms four four-member teams each day.

The selected carried item is committed only to the centered team. The existing consumption transaction revalidates recipient, selection, time, lane and full Bulk, records raw/applied/wasted Utility and dispatch facts before observers, and preserves the global spent-ID guard. Full/manual/cutoff dispatches are irreversible and exactly once; full Bulk alone does not dispatch an incomplete team. Return Capacity is raw capacity minus outgoing Bulk, with no M4 return-outcome simulation.

The existing DispatchWorkSurface hosts the carousel. F opens/closes, distinct E submits, ESC closes the panel before the menu, A/D and arrow keys/buttons/side cards select teams. Transition E and preheld navigation are guarded. Terminal cards remain centered/read-only with whole-card light-blue styling. All-done closes the panel and disables that day's interaction. The carried strip scrolls its visible selection window beyond ten items while retaining the number shortcuts.

The shared clock runs 06:00–00:00 at rate 24 (2.5 real minutes per game hour). Preparation ends at 10:00 before breakfast opens. Medical, meals and all twelve ordered 16-item deliveries use the locked three-day timetable; daily delivered Bulk remains 244/257/271. The witness's calendar coordinates and 30-minute analytical allowance were not introduced as runtime delays. Scenario exhaustion stays finite.

Exactly 85 items / 240 Bulk replace the old M3 starting stock for a new M4 run. Instance IDs are unique. Existing storage placement commits arrange the stock on the lower two Gallery A West shelf levels (19 and 55 stacks); all 85 are progressively retrievable. The authored scene's development palette is preserved and suppressed only at runtime for M4. Supplies persist across days; Continue restores before activation and does not reseed or recreate teams.

Schema 4 extends the existing snapshot/codec/validator and one-slot service. Prior schema 1–3 saves are rejected explainably, without migration or modification. Mixed dispatched/open requests, immutable results, clock, storage/zoning, ladder, Receiving and legitimate saved velocity survive restoration. Midnight reporting retains Dispatch identity/members, reason/time, required/credited/unmet lanes, outgoing Bulk and Return Capacity, alongside prior Medical/meals/coverage/backlog/forfeits/autosave sections. Begin Day does not resolve teams again.

## Preservation and the authorized seating correction

External `preservation.json`, `preservation-final.json` and `review-metadata-preservation.json` record source/target comparisons. All 167 definitions preserve names, models, source mappings, authored transforms/scales/Front, Footprints, roles and Auto Stack Groups; only approved numeric fields/context values changed. All 2,421 inventoried licensed asset/dependency files have identical hashes. Catalogue membership, seven retirements, stack registry, `wing_gameplay.tscn`, `functional_fixtures.tscn` and other worktrees are unchanged. No asset archive was staged.

The developer's explicit scale acceptance for 163–174 was recorded through the existing review metadata helper. Scale/pose/Footprint/roles are current for 167; Auto Stack Group acceptance remains current for 155 and honestly pending for twelve, whose saved groups remain None. The 162 preceding review records (including retired sources) are unchanged. This does not close or publish the physical top-up.

The first exact mixed-manifest run exposed seating gaps for Roast Piglet 061 (107.5 mm), Gas Mask 147 (92.6 mm) and Hammer 3 041 (6.7 mm), beyond the existing 6 mm allowance. Rotated bounding-box empty corners caused the error. The developer explicitly answered **“Allow the narrow seating correction.”** The shared pose helper now uses transformed mesh vertices for its vertical minimum. Horizontal bounds/centering, authored poses/scales/Footprints/models and manifests remain unchanged. All twelve exact manifests subsequently pass strict seating, reach, TAKE and shelf handoff checks. No substitution, omission, split, enlarged deck/reach/carry capacity or balance adjustment was used.

## Commands and selected passing evidence

Evidence root **E**: `C:\Users\Boschetar\.codex\attachments\m4-2026-10-24`. Bulky logs, captures and test saves remain outside the project. Installed executable **G**: `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, observed version `4.7.stable.official.5b4e0cb0f`, Compatibility renderer. Native tests used Windows OpenGL on the installed NVIDIA device.

Every engine invocation used isolated environment directories:

```powershell
$env:APPDATA = 'C:\Users\Boschetar\.codex\attachments\m4-2026-10-24\runtime-profile\AppData'
$env:LOCALAPPDATA = 'C:\Users\Boschetar\.codex\attachments\m4-2026-10-24\runtime-profile\LocalAppData'
```

From the authoritative project directory, headless commands use the following argument form. Substitute the script and log stem from the table; optional user arguments follow `--`. `$godotM4` is G and `$evidenceM4` is E. Each selected invocation below exited **0** with its expected completion marker and zero failures.

```powershell
& $godotM4 --headless --path . --rendering-method gl_compatibility --log-file "$evidenceM4\<stem>.engine.log" --script 'res://tools/asset_pipeline/tests/<script>.gd' *> "$evidenceM4\<stem>.console.log"
$LASTEXITCODE
```

| Script | Selected console-log stem | Observed result / coverage |
|---|---|---|
| m4_baseline_tests | final-m4_baseline_tests | 167 rows, zero failures; exact routes, capacities, fixture |
| m4_loadout_tests | final-m4_loadout_tests | 51 checks; formation 0, 1–4, 12–17, 21; revalidation, rejection, waste/Bulk, recipient isolation, observer ordering, dispatch reasons |
| m4_schedule_tests | final-m4_schedule_tests | 28 checks; three days, cutoff-before-breakfast, exact/fractional/bulk boundaries, history, exhaustion |
| m4_carousel_tests | final-carousel-input | 22 checks; 1/2/6-team cases, transitions, input, rejection feedback, wheel/numbers, item 15 |
| m4_report_tests | report-postfix | Zero failures after final report-layout correction |
| m4_snapshot_tests | final-m4_snapshot_tests | Separate writer: 27 checks; partial, mixed, cutoff, report-pending snapshots |
| m4_snapshot_tests, user args `--read` | final-snapshot-read | Separate reader: 21 checks; exact identities/accounting/time/ownership, storage/zoning/ladder/Receiving, tamper rejection, no replay |
| m4_witness_tests | final-m4_witness_tests | 1,174 checks, 81 obligations, 211 consumes; 66 items / 234 Bulk left |
| m4_cargo_tests | cargo-green | All 12 exact manifests, 192 production TAKEs and 192 shelf handoffs; blockers empty |
| m4_seed_tests | seed-green | 173 checks, 85 items / 240 Bulk |
| m4_seed_access_tests | seed-access | 85/85 actual production-ray TAKEs at existing 2.3 m reach; blockers empty |
| m4_receiving_lifecycle_tests | final-m4_receiving_lifecycle_tests | Exact A/B/C/D; 32 real TAKEs, 1+2 deposited capacity plus upstream, contact/interrupted/full outbound, FIFO admission |
| receiving_awaiting_lift_tests | final-receiving_awaiting_lift_tests | PASS, zero failures; six lifecycle helpers |
| pre_m4_catalogue_tests | final-pre_m4_catalogue_tests | Zero failures; 167 active and current physical-review counts |
| authoring_review_manifest_tests | final-authoring_review_manifest_tests | PASS |
| storage_visual_pose_tests | final-storage_visual_pose_tests | PASS |
| storage_stacking_interaction_tests | final-storage_stacking_interaction_tests | PASS |
| m1_contribution_tests | final-m1_contribution_tests | 27 checks, zero failures |

The numeric witness is an isolated accounting test, not runtime automatic allocation or proof of normal-speed comfort. Its Day 2 lunch uses existing Corn Sack `D2-B:001` and Pumpkin Large `SEED:020`: raw 70, credited 60, wasted 10, full Bulk 18. No extra pumpkin or supply was created.

The native integration command, without `--headless`, used:

```powershell
& $godotM4 --path . --rendering-method gl_compatibility --log-file "$evidenceM4\final-native.engine.log" --script 'res://tools/asset_pipeline/tests/m4_rendered_tests.gd' -- --m4-evidence-dir=C:/Users/Boschetar/.codex/attachments/m4-2026-10-24/native-final *> "$evidenceM4\final-native.console.log"
& $godotM4 --path . --rendering-method gl_compatibility --resolution 1280x720 --log-file "$evidenceM4\fresh-report-green.engine.log" --script 'res://tools/asset_pipeline/tests/m4_held_movement_tests.gd' *> "$evidenceM4\fresh-report-green.console.log"
```

The first exited **0**, `M4_RENDERED_COMPLETE display=Windows checks=228 failures=0`. It drives production keyboard/pointer/controller/physics paths, both resolutions, held/echoed E/F/navigation, released-W stopping, modal priority, manual/cutoff behavior, Save & Exit/Continue, saved velocity and report acceptance. Controlled fixture setup/time advancement is explicit; this is not an uninterrupted human playthrough. The second exited **0**, `M4_HELD_MOVEMENT_COMPLETE checks=8 failures=0`: fresh 1280×720 Continue fits the report and Begin Day after initial layout, click resumes, held W is blocked during Dispatch and resumes across closing. It reads only the first helper's isolated slot. No developer save was opened, migrated, overwritten or deleted.

Cargo/seed physical evidence predates later UI/validator changes; its inputs and physical owners remained the same afterward, so it was reused rather than rerun. Native 228-check evidence predates the final deferred report-minimum-layout fix; the affected report unit test and fresh native Continue/movement case were rerun after that fix. `final-selected-results.json` records the selected markers, observed exits, diagnostics and attribution. `final-results.json` is an earlier batch ledger, not the final acceptance list.

## Captures and limitations

External `native-final/` contains `dispatch-partial-{1920,1280}.png`, `dispatch-terminal-{1920,1280}.png`, `report-{1920,1280}.png`, `report-existing-sections-{1920,1280}.png`, `carried-strip-15-{1920,1280}.png` and `seed-overview-1920.png`. Carousel/report bounds and pointer operation were checked at both sizes; representative images were inspected visually. The 15-item strip uses an explicitly isolated one-Bulk-item display fixture, not extra scenario supply. `seed-inventory.json` captures all 85 identities, definitions, surface paths and placement positions for developer review.

Earlier RED and failed intermediate logs are retained honestly. Baseline tests failed on old values before the exact update. The initial cargo seating failure was resolved only after explicit authorization above. Early headless/native integration attempts exposed viewport/input-fixture problems and the proxy's own collider obstructing station targeting; final native proof uses the real collider descendant and unchanged reach. The saved-velocity test was corrected to respect the accepted menu's stop behavior before testing a valid saved velocity. A fresh-Continue report regression (`fresh-report-red`) exposed a real transient height of 1008 instead of 660; deferred relayout on `minimum_size_changed` fixes it (`fresh-report-green`). These failed runs are not counted as passes.

`storage_pose_content_tests` intentionally exits **2** with `RETIRED_FIXTURE: initial 42-item content checkpoint`; it was not reactivated or counted as a passing current test. The current catalogue, storage pose/stacking, all-manifest and seed checks provide the relevant current coverage.

Observed diagnostics remain visible: Windows root-certificate-store errors; four native `Parameter "material" is null` messages matching existing CF-07 (also present in prior M3 logs); and the deliberate invalid-return negative case in `receiving_awaiting_lift_tests` (`team_D`, changed/incompatible commitment). Selected current logs have no unexplained script/assertion/incomplete-helper or leak errors. Pickaxe 108's co-located LOD caveat and twelve pending group approvals remain disclosed. No broad asset/engine repair or new durability/journal system was added.

## Next review and developer playtest

Request one fresh contextual review of the combined base-to-candidate diff and relevant request/carry/schedule/snapshot/station/storage/Receiving callers, including preservation and global spent-ID validation. Then perform native input/audio, continuation and normal-speed workload playtests. Human promotion remains pending; another abstract balance pass is not a prerequisite.

1. Launch the configured main `run_shell.tscn` (F5), use an intentionally disposable playtest slot/profile, and start New Run. F6 standalone wing remains the preserved authoring palette. Inspect the initial shelf arrangement against the 85-entry inventory; TAKE/PUT/stack/ladder/zoning should retain accepted behavior.
2. At Dispatch, inspect all teams and five lanes at both resolutions. Test F, distinct/held E, preheld A/D, arrows/side cards, transition E, wheel/numbers, ESC priority and W released/held across closing. Carry and select more than ten small items.
3. Use the same persistent supplies for teams, Medical and meals. Check excess Utility/full Bulk, full-lane and over-capacity rejection, full/manual/empty/cutoff dispatch, light-blue terminal cards, stable position, all-done closure and next-day reactivation.
4. Save & Exit and restart during a partial team, mixed terminal/open teams, after cutoff and while the midnight report is pending. Compare identities, lane progress, outgoing/return Bulk, clock, remaining stock, stored items, ladder and partial Receiving. Begin Day must not replay spends, teams, seeding or resolution. Older schemas should explain incompatibility.
5. Play the three authored days at normal speed, including real Receiving cycles/audio, exact deliveries, breakfast at the simultaneous 10:00 boundary, Medical/meals and reports. Assess readability, travel/carry workload, input/audio comfort and scarcity before proposing further numerical changes. Confirm authored exhaustion after Day 3.

No independent review, human hardware/input/audio acceptance, normal-speed three-day workload acceptance, publication or M5 completion is claimed here.
