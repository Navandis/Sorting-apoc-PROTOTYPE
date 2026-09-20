extends Node3D

## Review-only loose cabinet samples. The two saved host sets are authored at
## their actual world positions so the canonical item visuals never inherit the
## cabinet's Y compression. Registration deliberately never changes a host
## transform: it only attaches the ordinary WorldItem pickup component.

const SeedRegistrarScript = preload("res://gameplay/logistics_wing/development/seed_registrar.gd")

var _active_hosts: Node3D
var _authored_transforms: Dictionary = {}
var _registration_ok := false


func activate_case(case_id: String) -> bool:
	var use_full_height := case_id == "A"
	var full_height := get_node_or_null("FullHeightHosts") as Node3D
	var lowered := get_node_or_null("LoweredHosts") as Node3D
	if full_height == null or lowered == null:
		push_error("CabinetTakeSamples requires FullHeightHosts and LoweredHosts")
		return false
	full_height.visible = use_full_height
	lowered.visible = not use_full_height
	_active_hosts = full_height if use_full_height else lowered
	_authored_transforms.clear()
	var seed_items := _active_hosts.get_node_or_null("SeedItems") as Node3D
	if seed_items == null:
		push_error("CabinetTakeSamples requires its saved SeedItems root")
		return false
	for host: Node in seed_items.get_children():
		if host is Node3D:
			_authored_transforms[String(host.name)] = (host as Node3D).global_transform
	var registrar := _active_hosts.get_node_or_null("SeedRegistrar") as Node
	if registrar == null or registrar.get_script() != SeedRegistrarScript:
		push_error("CabinetTakeSamples requires its saved SeedRegistrar")
		return false
	_registration_ok = bool(registrar.call("register_existing_hosts"))
	return _registration_ok and authored_transforms_preserved()


func get_active_hosts() -> Array[Node3D]:
	var hosts: Array[Node3D] = []
	if _active_hosts == null:
		return hosts
	var seed_items := _active_hosts.get_node_or_null("SeedItems") as Node3D
	if seed_items == null:
		return hosts
	for child: Node in seed_items.get_children():
		if child is Node3D:
			hosts.append(child as Node3D)
	return hosts


func authored_transforms_preserved() -> bool:
	if not _registration_ok:
		return false
	for host: Node3D in get_active_hosts():
		if not _authored_transforms.has(String(host.name)):
			return false
		var authored: Transform3D = _authored_transforms[String(host.name)] as Transform3D
		if not host.global_transform.is_equal_approx(authored):
			return false
	return true
