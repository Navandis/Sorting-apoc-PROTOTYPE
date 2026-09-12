extends Resource
class_name FreightBayPresentationProfile

@export var profile_id: StringName = &""
@export_range(1, 9999, 1) var revision: int = 1
@export var pile_bounds: AABB = AABB()
@export var deck_support_y_m: float = 0.0
@export var settle_spawn_volume: AABB = AABB()
@export var temporary_proxy_collision_envelope: AABB = AABB()
@export var barrier_side_reach_envelope: AABB = AABB()
@export var drainability_viewpoints: Array[Vector3] = []
@export var containment_tolerance_m: float = 0.01
@export var penetration_tolerance_m: float = 0.01
@export var fallback_layout_version: int = 1


func validate_identity() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(profile_id).is_empty():
		errors.append("FreightBayPresentationProfile requires profile_id.")
	if revision <= 0:
		errors.append("FreightBayPresentationProfile revision must be positive.")
	return errors
