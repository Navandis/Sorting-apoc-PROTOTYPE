# M1 persistent Medical — implementation and validation

16 October 2026. Local candidate; independent contextual review, developer playtest and human PROMOTE remain pending. No M2 work, publication, push, merge or PR is authorized by this record.

## Source and execution

- Authoritative asset-equipped checkout: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`.
- Branch: `codex/m1-persistent-medical`, base `4cdbb139eaf80632ae79c1d3cbb95f23dfd70a4e`. Clean main and live origin/main matched at preflight; ordinary read-only OpenSSL query worked after the machine's Schannel credential failure. No reset/stash/clean, clone or extra worktree.
- Engine: `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, `4.7.stable.official.5b4e0cb0f`, Compatibility. No developer Godot process was present or terminated. No engine/dependency installation.
- Evidence: `D:\Sorting_Apocalypse_MVP\M1\2026-10-16\m1-20261016-a`. Fresh run; existing ancestors had no reparse points and the resolved location was outside every existing worktree.
- Exact final commands, modes, timestamps and actual exits: external `final-commands.jsonl`; raw console and engine logs are retained separately. Earlier incremental attempts and their disposition are indexed in external `commands-and-results.md`. Final commit/patch/source manifest are recorded externally in `final-git.txt` and `source-manifest.json` to avoid a self-referencing commit ID here.

## Implemented behavior and boundaries

The new launch scene `gameplay/run/run_shell.tscn` has its own UID `uid://bpf17lciqtn65`; project startup selects its explicit path. Startup parity verifies this entry before loading the canonical wing, and still detects duplicate declarations of the canonical wing UID `uid://bljf1nlhijej`. The canonical wing, legacy `main.tscn`, review scenes and saved human DevelopmentSetup remain intact.

New Run initializes one Medical request with target 12 and creates the initial continuation only after successful initialization. Continue restores it. ESC offers Resume / Save & Exit / New Run; replacement requires confirmation. Save & Exit publishes a successful snapshot before unloading to launch; failure leaves the current run paused with an explanation. Zoning and menu own separate pause reasons. Audio uses the same stream players on ordinary pause/resume. Already-deferred upstream admission also respects pause and resumes once.

Medical binds the existing `Environment/Greybox/Proxies/MedicalInterface` at the gameplay-composition layer. Its local reticle/label and non-pausing panel use contextual Utility. First E opens, release plus a second E spends one current selected item, and echo/held input cannot repeat. Wheel/number selection changes preview. Close spends nothing; ESC retains menu ownership. The player suppresses and resets polled shelf commands while an overlay owns input, and requires E release after close/resume/load. Destination reach, aim, visibility and obstruction are checked again; leaving it closes the panel.

`contribution_request.gd` owns lanes, targets, receipts and closure independently of the panel and save service. Whole-item removal and request credit happen without intervening callbacks; carrying notifications follow the receipt. Capture refuses an active transaction. Receipts retain exact spent IDs, applied credit and waste; resolution never consumes again. The UI distinguishes solid committed pips from outlined projected pips, projected totals, gain, waste and remainder. Ineligible selection has a red outline, no gain and explicit text. No new Kitchen, Loadout, patient, scheduler or day-clock behavior exists.

## Provisional Medical fixture

Only these three definitions gain explicit `medical_bay` overrides. Primary Utility, storage category, Bulk, Footprint, pose, stack roles and assets are untouched. These are test inputs, not final balance or P01's proposed formula.

| Definition | Medical Utility | Existing original hosts under `DevelopmentSetup/SeedItems` | Host origins in the saved composition (metres) |
| --- | ---: | --- | --- |
| `loot_000025` antibiotics / Medicine Bottle | 5 | `Medical_Antibiotics` | (-13.0920925, .884, 3.234186) |
| `loot_000026` Bandages 1 | 3 | `Medical_Bandages` | (-12.341123, .884, 3.2278805) |
| `loot_000028` Med Kit 4 | 8 each | `MedKit_A`, `MedKit_B` | A (-6.2618937, .96, -2.5071163); B (-7.8864574, .96, .5578277) |

Host origins are not mesh centres: existing authored visual-child offsets remain authoritative. Persistent original IDs are `<RUN_ID>:wing_seed_v1:<HOST_NAME>`. The external fixture saves and `fixture-supply-manifest.json` contain a concrete run's IDs. The existing Book/Book2, food, hydration and other palette hosts provide ordinary ineligible stock through the same TAKE/carry paths. Total positive fixture supply exceeds 12. Gloves `loot_000034` and Pants `loot_000036` remain blocked. No whole-catalogue Utility pass or supply/furniture relocation occurred.

## Save schema and ordinary failure policy

Version 1 uses JSON snapshots named `Save_<RUN_ID>_DDMMYY-HH-MM.json`, one `active-slot.json` pointer and bounded temporary replacement files. The pointer carries local wall-time metadata; the snapshot separately stores double-precision gameplay elapsed seconds. M1 records elapsed play only; it does not advance 07:00–midnight time or expose a clock HUD.

`run_save_service.gd` accepts a destination in its constructor; every executor save/New Run test injects a fresh external directory. The normal production location, reported by the installed engine, is:

`D:\AI Tools\Godot-4.7-Codex\runtime_profile\AppData\Roaming\Godot\app_userdata\Sorting-apoc-PROTOTYPE\saves`

That directory was absent at the read-only check. It was neither created nor overwritten by these tests. Isolated slots are the named `*-slot*`, `process-slot*`, `final-slot-*` directories and `rendered-*/rendered-slot` under the evidence run. No application identity or second serializer redirects tests.

The codec deliberately supports value types only: tagged exact integer strings, StringNames, vectors, AABBs and transforms. Scalar float64 bits are stored explicitly because the initial decimal JSON experiment changed the least significant bits of live timers; repeated loads now preserve actual precision. Unsupported/malformed data yields an explanation. There is no resource/object deserialization from saves.

Validation checks supported schema/scenario, physical-definition compatibility, item/owner references, one physical owner per remaining identity, carrying organization, reservations/cells/stacks, receipts/closure, Receiving batches/FIFO/upstream statuses and allocator sequence. Physical compatibility includes authored Bulk, Footprint, storage pose/roles, group and visual path, deliberately excluding Utility. Current Receiving profile ID/revision must match. Owner paths/layouts and seed/ladder references are also checked against the staged canonical scene before publication. Incompatible saves remain untouched; reconstruction failure discards the staged candidate rather than publishing a partial world.

Writes stage and reread the real snapshot, then replace the destination/pointer using bounded rollback files. Same-minute saves replace the active filename correctly. Only the pointer's previous application snapshot is retired after successful publication; unexpected files/working files are preserved and reported. Failure before publication retains the previous successful slot. This is ordinary save integrity, with no crash journal, recovery generations or Ironman durability claim.

## Capture and restore policy

Owner adapters capture original hosts, carrying gaps/selection, player world/camera/velocity, storage cells/zones/initialization/names, exact reservations and ordered stack Entry data plus committed representation transforms. Ordinary storage keys are wing-relative generated owner paths plus surface IDs. Existing storage survives erased/reassigned zoning, and saved yaw is not derived from today's unit Front. New placement still uses ordinary acceptance rules.

Continue sets suppression flags before tree entry/readiness. Static furniture and runtime wiring initialize; new seed registration and CLI demo issue do not. A shared remaining-item map supplies original hosts, carrying, committed storage and active Receiving representations. Batch history and spent receipts are metadata, not extra physical owners. Player/HUD/held representations rebuild afterward. Exact ladder path, height/pose, attachment anchor/yaw and suppression bookkeeping are restored; **no ladder-base fallback was needed**. Transient panels and pending player commands close/reset, and menu pause flags are not serialized.

The persisted random run namespace and next sequence cover request IDs, original seed IDs and new debug cargo, without changing content seeds. Allocator rewind that would reuse an ID is rejected. Standalone prototype/debug serial behavior remains in its original scope. Continue is not a fresh deposit, return submission or preparation.

ReceivingManager retains active/deposited FIFO state and exact committed batch snapshots. AwaitingLiftAdmission retains waiting commitments and terminal admitted/forfeited records. Pending prepared B from the opt-in two-batch helper is explicitly saved and reconnected to A's OPEN signal, without regeneration. Fully OPEN-only targeting/TAKE, indefinite OPEN, 1 active + 2 deposited queued slots, fairness and full-turnaround retirement remain intact.

Lift recovery saves state, `_elapsed`, `_phase_duration`, warning progress, shutter Y, batch, busy and departing. Logical elapsed/duration now govern closing and departure endpoints; a restored or late `.playing` flag cannot extend the deadline or release capacity early. Normal authored cue lengths, 3.40 s contact timing and overlap remain the source of phase duration. Load seeks the appropriate cue at the logical offset, including arrival/opening overlap. No load catch-up ages gameplay, and repeated restores preserve remaining logical time exactly. Ordinary pause suspends/resumes the existing streams and shutter without reconstructing them.

CF-01 replaces coroutine global-frame awaits with owner-bound one-shot callbacks for both geometry-settling frames and cooldown. Godot disconnects them on owner deletion. The original script reproduced deleted-instance resume errors at both frame windows; the repaired two-window probe is quiet. The saved UPDATE_ONCE probe, geometry settling, coalescing and legitimate latest-state follow-up remain verified.

## Evidence and limits

The final sweep's per-suite results are recorded in external `final-commands.jsonl` and the delivery addendum below. Required storage, ladder, startup and affected Receiving suites use their existing real operations. New checks cover the canonical 5/12 +3 and 11/12 +8 (1 applied / 7 wasted), actual panel binding, input release/echo, selected-item rejection, partial/closed saves, exact physical continuation, logical phases, pending and terminal ownership, nested pause and scene lifetime.

`m1_continuation_tests.gd` runs in separate writer and reader Godot processes through the production save service. The reader compares the entire captured state, including original hosts, carrying gaps/selection, ordered stacks/reservations/poses, erased zones/names, exact player/attached-ladder state, all cargo/return owners and logical timing. It then creates new same-seed cargo and checks disjoint identities. A reader run with the old CLI demo flags verifies that Continue does not reissue startup cargo.

Rendered evidence is `rendered-verified/01`–`07` PNGs: no-save launch, valid 5+3 preview, ineligible feedback, whole-item cap/waste, ESC menu, enabled Continue and closed result. The real Windows Compatibility renderer and held view were enabled. Inputs were synthetic Godot InputEvents, and fixture TAKE/positioning used direct production operations. This is **not OS keyboard/mouse or human audio acceptance**. Logical shutter/audio pause and resume are covered programmatically; hearing cue continuity and ordinary movement/route ergonomics remain human checks.

The rendered run passed 28 functional checks but is **not a clean renderer result**: it reproduced twelve existing CF-07 `Parameter "material" is null` diagnostics in the four GLES3 material functions during held-item changes/restoration. Images remained readable and the assertions completed. These exact signatures are retained, not a blanket exemption for other errors. Initial headless held-view attempts also reproduced the previously documented dummy-renderer limitation; final affected headless fixtures disable held rendering where stated.

Earlier parse failures, incomplete helpers, the numeric precision failure and the first capture's unsettled mouse orientation are retained as failed attempts. Two early aborted executor test processes were not closed promptly and briefly overlapped subsequent attempts; they were identified by exact command lines and stopped. Those attempts are discarded as proof. No developer editor was stopped; final evidence runs are serial. The new abort canary requires a nonzero exit and absence of the completion marker; neither exit 0 alone nor a surviving PASS line establishes helper completion.

No tracked engine cache/art changes are intended. Godot used existing ignored imports and its runtime profile/cache; this is not a zero-filesystem-writes or exhaustive cache-hash claim. Protected DOCX masters/mirrors and all human scene transforms/materials/wear remain unchanged.

## Developer playtest and fresh review handoff

1. Launch the configured project. Verify New Run / grey Continue before a first run; cancel and confirm replacement when a slot exists.
2. TAKE antibiotics/bandages/medkits from the existing development tables. At Medical, first E opens without spending; release and E submit one selected item. Hold E, wheel/number-select, select Book, and close without submitting. Verify pips, 5+3 preview, cap/waste and invalid text.
3. Save & Exit at partial progress, reopen the application and Continue. Check the same request/items/selection and absent taken originals. Finish the request, save/reopen again, and inspect the closed result without another consumption.
4. Store a mixed/ordered stack, rotate a placement, erase/change zones beneath stored items and name a surface. Save/reopen: committed stock stays put; new placement obeys the edited zones.
5. Save while attached partway up the Gallery B ladder. Continue at the same ladder/height/view; check attach/detach/rearm and ordinary movement afterward.
6. Use the existing explicit Receiving debug demonstrations. Save/reopen incoming, opening, partly unloaded OPEN, closing and busy outbound. Check TAKE gating, exact remaining cargo, deposited FIFO/upstream waiting and one full-turnaround promotion. Repeat a mid-phase save/load and listen for shortened/seeking cues without a restarted logical delay.
7. ESC during motion/theatre: verify player, shutter and sound suspend and resume together. Open zoning, then ESC, and close/resume in both orders. Hold E across resume and confirm no queued action.

One **fresh contextual review** should compare the final local commit against the base and read the new request/codec/save/snapshot/shell code together with the modified player, carrying, seed, storage and Receiving owners. Focus on transaction notification ordering, failed replacement preservation, staged restore/reference validation, committed storage pose, phase/audio endpoints, queued callback pause and pre-ready duplication suppression. Implementer self-review is not that independent review. Do not promote, merge/push or start M2 before the separate human disposition.

## Final delivery addendum

The selected 26-suite serial sweep completed with every expected PASS/completion and actual exit 0. It covers startup, the nine listed storage/ladder foundations, affected Receiving identity/batch/manager/presenter/lift/queue/Awaiting/debug/reflection owners, wing composition and the new M1 suites. Three intentional errors were inspected in full: the existing Awaiting mutation case (`team_D`, batch `D`) and the two explicit duplicate seed namespace fixtures. All other sweep logs were quiet.

Final self-review added two real failure checks and their corrections: Windows cursor capture when zoning closes beneath the menu, and failed seed initialization publishing an empty New Run over a previous save. A follow-up also verified the distinction between New Run setup initialization and an already-restored registrar. The latest affected runs are:

| Evidence basename | Completion / actual exit | Diagnostics |
| --- | --- | --- |
| `verified-persistence` | 26 checks, 0 failures / 0 | None |
| `verified-receiving` | 71 checks, 0 failures / 0 | None; includes admitted and forfeited terminal state |
| `verified-menu` | 21 checks, 0 failures / 0 | Only the intentional `Medical_Bandages` / `missing_seed_definition` rejection |
| `verified-process-writer` | 16 checks, 0 failures / 0 | None; real save in `verified-process-slot` |
| `verified-process-reader` | 15 checks, 0 failures / 0 | None; separate process, old CLI debug flags supplied and suppressed |
| `verified-rendered` | 28 functional checks, 0 failures / 0 | Twelve exact CF-07 held-material diagnostics retained |
| `final-m1_abort_canary` | Deliberate abort / 2 | No completion marker, as required |
| `final-m1_reflection_fixed_probe` | Both frame-wait windows / 0 | None |

Unchanged sweep evidence is retained after those narrow corrections; only affected paths were rerun. Raw earlier failures remain in the evidence index and are not promoted to PASS. Final images in `rendered-verified` were visually inspected. Native OS input and human listening/playtest remain pending. No unresolved new functional failure was identified by implementer self-review; this is not independent review or human acceptance.

The final artifact is one tested local feature-branch commit plus `m1-persistent-medical.patch` in the external run directory. `final-git.txt` records the actual final commit, base, worktree status and patch SHA-256. No pre-existing unrelated working-tree edits were present; no unrelated files were staged. Existing worktrees and ignored commercial assets/imports/evidence remain preserved. No push, merge or PR was performed. The active MVP master awaits its later human progress/disposition update.

## 16 October 2026 — Medical UI/input follow-up

**TECHNICALLY VERIFIED / HUMAN REVIEW PENDING.** This follow-up retains `6c56edff05b5e803ad9f17fc5f3b8467e7800f4e` as the original M1 checkpoint. The owner reports successful native save/restart/Continue, exact player/ladder pose, carrying/selection, Medical rejection/contribution, Receiving and New Run testing of that checkpoint; these are human reports, not new executor runs. The controls below supersede the earlier E-opener and inspectable-completed-panel instructions in this record.

The card now follows the viewport center in a bounded 600 × 440 logical-pixel layout. F opens/closes without spending; E submits one selected eligible item per distinct press. Opening samples the actual held E/F state. Repeats are suppressed, while ordinary shelf hold-E throughput remains intact. ESC closes an open contribution panel first, without pausing; the next distinct ESC opens the menu. The shell owns that priority. Successful all-lane completion closes the panel after the transaction returns, restores gameplay input/cursor, and suppresses both actionable cues from request state. Closed results remain in persisted data; Continue cannot reopen them, and New Run reactivates Medical.

Fresh evidence is outside all worktrees at `D:\Sorting_Apocalypse_MVP\M1\2026-10-16\m1-ui-input-followup-a`. Preflight confirmed the expected clean branch/HEAD, local and remote main at `4cdbb13`, no running Godot process, existing imports, and Godot `4.7.stable.official.5b4e0cb0f`. One implementer used the current Codex session; its exact runtime model identifier/reasoning-effort setting was unavailable, so High is not claimed. `commands.jsonl` records commands and actual exits; `final-git.txt` records the follow-up SHA, clean status and both patch hashes.

| Fresh final evidence | Completion / exit | Diagnostics |
| --- | --- | --- |
| `green-contribution` | 27 checks, 0 failures / 0 | None; includes empty/ineligible preservation, cap/waste, all-lane closure and transaction boundary |
| `green-menu-v2` | 23 checks, 0 failures / 0 | Only the intentional `Medical_Bandages` / `missing_seed_definition` rejection; includes nested zoning/menu ownership |
| `storage-final` | Existing command regression PASS / 0 | None |
| `rendered-final` | 63 checks, 0 failures / 0 | Sixteen historical CF-07 material diagnostics, four occurrences of each signature below; no other errors/warnings |

The real Windows Compatibility run used synthetic Godot InputEvents through player/panel/shell callbacks. It covers held/preheld F/E, first E after F, wheel/number preview, rejection, completion, ESC priority/echo/resume, partial and closed Save & Exit/Continue, New Run cues, and real shelf E dispatch/hold/release suppression. Shelf targeting/timing alone is arranged deterministically. Saves are injected into fresh external directories; the developer's actual `user://saves` is not used. The old 26-suite sweep was not rerun or claimed as fresh proof.

Centering and control containment passed at 1920 × 1080 and resized 1280 × 720: logical card rectangle `(660,320,600,440)`, center X 960; the existing canvas scaling maps it to physical center X 640 at 1280. Final captures `02`, `02b`, `03`, `04` and `07` were visually inspected for projections, rejection, waste and closed cues. `before-reused` contains unchanged original-checkpoint screenshots from the previous evidence run, explicitly reused as the before comparison. The rendered log retains `Parameter "material" is null` at GLES3 `material_casts_shadows:2592`, `material_is_animated:2579`, `material_get_instance_shader_parameters:2618`, and `material_update_dependency:2630`; this follow-up does not repair CF-07.

Red assertions and earlier fixture failures remain in the external folder. The first contribution red attempt aborted after indexing a receipt that the old opener had not created; the corrected red run completed with four expected failures. ESC targeting, buffered input/off-tree shelf fixtures, and one stale reticle assertion were corrected without relaxing behavioral assertions. Shelf input coverage now lives in the rendered test; the original storage command suite is unchanged. Final runs were serial, and no developer process was stopped.

Pending human check: F open/close and first E, held E, invalid selection, ESC panel-close → menu → resume, completion hiding both action cues, and closed-state restart/Continue. Native OS keyboard/mouse feel and subjective readability remain **PENDING HUMAN**. One future independent contextual review must assess combined published-base → final M1, including this follow-up. No independent review was dispatched here; no push, merge, PR, human promotion or M2 work is authorized by this result.
