# Continuous Run Foundation implementation evidence

These are the original implementation-session logs and selected captures copied from `%TEMP%\sorting-collection-proof-631f10d6`. [SHA-256 manifest](SHA256SUMS.txt) covers the 38 raw logs and two captures. The archive is excluded from the Godot scan.

- [Pre-edit startup check](baseline-startup.log), [editor scan](editor-scan.log) and [first regression sweep](final-sweep/).
- Behavior failures are preserved separately, including the [old midnight behavior](continuous-red.log), [missing collection readout](goal-red-behavior.log), [old save namespace](continuation-red.log) and [released-cargo validator gap](continuation-released-red.log).
- The corrected final reruns are [continuous run](final-continuous_run_foundation_tests.log), [Awaiting Lift integration](final-receiving_awaiting_lift_integration_tests.log) and [lift cycle](final-receiving_lift_cycle_tests.log). The [76-check continuation pass](final-sweep/collection_continuation_tests.log) includes the validator correction.
- The [native Compatibility render log](rendered-continuation.log), [OPEN Receiving](receiving-open.png) and [completion HUD](collection-complete.png) predate that correction. The captures show the intentionally distinct restored target of 5.
- The developer's later observations are attributed in the [result record](../../2026-11-07-continuous-run-collection-goal-result.md#developer-acceptance).
