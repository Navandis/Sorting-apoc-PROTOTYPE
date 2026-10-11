extends Node3D

## One initial UPDATE_ONCE capture. Existing batch/TAKE events request bounded
## recapture; a future shutter controller calls request_refresh() after settling.
signal refresh_started

var _refresh_pending := false
var _refresh_requested := false


func _ready() -> void:
	var manager := get_node_or_null("../../ReceivingRuntime/ReceivingManager") as ReceivingManager
	if manager != null:
		manager.active_batch_changed.connect(_on_active_batch_changed)


func request_refresh() -> void:
	_refresh_requested = true
	if _refresh_pending:
		return
	_refresh_pending = true
	_refresh_after_geometry.call_deferred()


func _refresh_after_geometry() -> void:
	# Let synchronous batch reveal and deferred TAKE host deletion finish first.
	await get_tree().process_frame
	await get_tree().process_frame
	_refresh_requested = false
	var presenter := get_node_or_null("../../ReceivingRuntime/ReceivingDeckPresenter")
	if presenter != null:
		for item: WorldItem in presenter.get_materialized_world_items():
			if not item.picked_up.is_connected(_on_item_picked_up):
				item.picked_up.connect(_on_item_picked_up)
	# Godot 4.7's setter invalidates the renderer dependency even for the same
	# mode. Verified with stale/refreshed cubemap captures on Compatibility.
	# Keep the saved node, properties and pose; never enable UPDATE_ALWAYS.
	$InteriorProbe.update_mode = ReflectionProbe.UPDATE_ONCE
	refresh_started.emit()
	# Coalesce events during capture; one follow-up includes the latest geometry.
	await get_tree().create_timer(0.2).timeout
	_refresh_pending = false
	if _refresh_requested:
		request_refresh()


func _on_active_batch_changed(_batch_id: String) -> void:
	request_refresh()


func _on_item_picked_up(_item: ItemInstance) -> void:
	request_refresh()
