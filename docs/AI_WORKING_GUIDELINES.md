# Sorting Apocalypse — Proportionate AI Working Guidelines

For ChatGPT architects, local Codex and reviewers. This is a solo project: optimize for a correct, playable result, recoverable edits and reasonable total effort—not maximal process. These task-sizing rules take precedence over generic workflow-template ceremony; they do not waive correctness, user approval or preservation requirements.

## Before execution

**1. Size the task and its proof together.** A bounded repair needs a short brief: intended result, owning files, non-goals, relevant tests and stopping point. Do not turn baseline capture, documentation or packaging into independently reviewed milestones. Read current state and relevant source/dependencies; do not repeatedly reload unrelated project history into every worker.

**2. Use one implementer by default.** Add another worker only for genuinely independent substantial work or a specific expertise gap. A small repair gets at most one consolidated final review, with another look limited to a concrete correction. Do not chain implementer → specification reviewer → quality reviewer for each administrative step.

**3. Test the real invariant, not the proposed edit.** Translate the reported symptom into the complete affected condition before coding. For a shifted storage grid, check both boundaries—not just the reported rear edge. Do not invent constraints such as preserving invalid capacity. Reuse established gameplay paths; do not reimplement them inside maintenance tooling.

## During execution

**4. Match testing to risk.** Cover the reported failure, ordinary use, actually supported variants and credible nearby regressions. Preserve strong checks for item identity, destructive writes and save integrity. Hypothetical configurations, microscopic input mutations and exhaustive combinations need a concrete reason. More assertions are not automatically better coverage.

**5. Run evidence-producing commands once where possible.** Capture logs on the first useful run. Reuse a verified same-state baseline, clearly labelled; run a new baseline when state or evidence warrants it. Use focused tests while editing and one agreed final regression sweep. After corrections, rerun affected checks. Documentation, classifier or archive changes alone do not justify repeating unchanged game tests. Inspect errors as well as exit/PASS markers; never hide a failure.

**6. Keep tooling and evidence subordinate.** Prefer existing commands, a short diff and a small targeted probe. No new runner, classifier, approval framework, immutable archive system or nested review process without demonstrated necessity. For a small repair, one concise result record, relevant raw logs and a few informative images normally suffice. Package after substantive review. Preserve existing evidence; do not multiply source copies or delete user files to make status clean. Stage source archives outside the Godot project, or exclude their roots before copying scripts.

**7. Escalate cost, not ceremony.** For a bounded repair, roughly 20–30 minutes without a tested correction, a second tooling/review loop, or support work overtaking the repair triggers a brief status: actual blocker, completed result, simpler alternative and expected remaining work. Pause the expanding approach and ask before substantial added scope. This is a checkpoint—not permission to skip tests, rush a bad fix, or impose the same duration on architectural tasks.

## Completion

**8. Stop at the agreed result.** When the repair and relevant checks pass, deliver it for any required human check. Separate blockers from optional improvements; defer cosmetic documentation nits and speculative hardening. Record known debt honestly. Do not build more machinery to prove that the delivery machinery is complete. No unauthorized merge, push, cleanup or next milestone.

**Architect's responsibility:** Keep handoffs and evidence requests proportionate too. State approval/preservation boundaries once; do not generate a large package or a new bookkeeping phase for every small correction.

**Bootstrap insert:** “Read `docs/AI_WORKING_GUIDELINES.md` before planning or delegating. Apply its proportionality rules to this session's handoffs, implementation, review and evidence. Increase process only for a stated task-specific risk.”

**Handoff preference:** Future implementation handoffs should state the intended model, reasoning effort, and whether the work starts in a new or existing session.
