extends RefCounted
class_name PilePreparationJob

const PilePreparationDiagnosticsScript = preload(
	"res://receiving/pile_preparation_diagnostics.gd"
)

enum JobState { PENDING, RUNNING, SUCCEEDED, FAILED }

var batch: LootBatch
var profile: FreightBayPresentationProfile
var state: JobState = JobState.PENDING
var diagnostics: PilePreparationDiagnostics


func _init(
	new_batch: LootBatch = null,
	new_profile: FreightBayPresentationProfile = null
) -> void:
	batch = new_batch
	profile = new_profile
	diagnostics = PilePreparationDiagnosticsScript.new()
	if batch == null:
		return
	diagnostics.batch_id = batch.batch_id
	diagnostics.content_seed = batch.content_seed
	diagnostics.presentation_seed = batch.presentation_seed
	diagnostics.target_bulk = batch.target_bulk
	diagnostics.actual_bulk = batch.actual_bulk
	diagnostics.item_count = batch.entries.size()
	if profile != null:
		diagnostics.accepted_profile_revision = profile.revision


func begin() -> bool:
	if state != JobState.PENDING:
		return false
	if batch == null or profile == null:
		return false
	if batch.preparation_state != LootBatch.STATE_CONTENT_COMMITTED:
		return false
	if not profile.validate_identity().is_empty():
		return false
	state = JobState.RUNNING
	return true


func mark_failed(reason: StringName) -> bool:
	if state != JobState.RUNNING:
		return false
	var recorded_reason: StringName = reason if reason != &"" else &"other"
	diagnostics.rejection_counts_by_reason[recorded_reason] = int(
		diagnostics.rejection_counts_by_reason.get(recorded_reason, 0)
	) + 1
	state = JobState.FAILED
	return true


func mark_succeeded() -> bool:
	if state != JobState.RUNNING:
		return false
	state = JobState.SUCCEEDED
	return true
