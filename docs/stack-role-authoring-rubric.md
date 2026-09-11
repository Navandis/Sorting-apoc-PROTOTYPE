# Stack Role Authoring Rubric

`can_support_stack` requires a meaningful usable support surface at the
item's physical scale under the centered single-column stacking model. A tiny
bottle or container top does not qualify merely because a theoretical very
small object could geometrically fit on it.

This is an authoring-review principle. It does not add minimum-support-size
runtime logic.

`can_be_stacked` does not require a geometrically flat base. An item may be
stackable when its approved stored pose has a visually credible, deterministic
resting relationship on a sufficiently large flat support; the Watermelon and
Ball are reference cases. This is an authored credibility judgment, not a
geometry inference rule.

Form integrity also matters. A loose, deformable, or assembled pile is not a
rigid stack member merely because its import has one mesh or root. If credible
support requires its contents to shift, collapse, roll apart, or substantially
deform, use a conservative role. The Firewood Pile is the reference case:
`false / false`. These principles do not add runtime physics or geometry logic.

Physical plausibility remains the gate. Gameplay or display practicality may
break a genuinely borderline but physically credible judgment; it never
justifies an unstable, impossible, or nonsensical relationship. `SM_Armor_02`
is the reference case: its semi-rigid upright form is plausible, and display
practicality resolves the borderline resting judgment as `true / false`.

Stack Role is always judged against the current approved storage pose. Pose
must be approved/current before assessment; Stack Role snapshots it, and a
later pose change stales the approval. Stack metadata never alters runtime
pose. `SM_Hammer_3` is pose-dependent: its current approved pose presents the
heavy iron head as a credible resting configuration (`true / false`).
