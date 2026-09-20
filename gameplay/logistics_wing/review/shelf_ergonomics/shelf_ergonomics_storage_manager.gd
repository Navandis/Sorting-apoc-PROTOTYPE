extends "res://gameplay/logistics_wing/functional_storage_manager.gd"

## Review-local installer.  The shared production profiles remain untouched;
## these candidates only alter the vertical scale and their matching supports.

var review_case := "A"
var ceiling_y_m := 3.40


func configure_review(new_case: String, new_ceiling_y_m: float) -> void:
	review_case = new_case
	ceiling_y_m = new_ceiling_y_m


func _install_known_shelves() -> void:
	if _scene_root == null:
		return
	for child: Node in _scene_root.get_children():
		if not (child is Node3D):
			continue
		var fixture := child as Node3D
		var fixture_name := String(fixture.name)
		if fixture_name.begins_with("SM_MetalShelves"):
			_install_authored_profile(
				fixture,
				[
					_make_level_profile(0.100, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.380, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.677, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.965, 0.96, 0.92, 0.00, 0.00),
				],
				maxf(0.05, ceiling_y_m - 2.86 * fixture.global_basis.get_scale().y)
			)
		elif fixture_name.begins_with("SM_ventilated_locker"):
			_install_authored_profile(
				fixture,
				[
					_make_level_profile(0.045, 0.94, 0.92, 0.00, 0.00),
					_make_level_profile(0.390, 0.89, 0.92, 0.005, -0.03),
					_make_level_profile(0.622, 0.94, 0.92, 0.00, -0.03),
					_make_level_profile(0.800, 0.94, 0.92, 0.00, 0.00),
				],
				0.519 * fixture.global_basis.get_scale().y
			)
	_install_modular_racks()
