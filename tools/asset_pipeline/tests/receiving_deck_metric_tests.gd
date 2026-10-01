extends SceneTree

const DeckSurface = preload("res://gameplay/logistics_wing/receiving/receiving_deck_surface.gd")
var failures := 0

func _init() -> void:
	call_deferred("run")

func run() -> void:
	# Catches inherited visual scale changing Receiving cells or profile offsets.
	var ancestor := Node3D.new()
	ancestor.transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(4, 0.82, 2))
	ancestor.scale = Vector3(1.11, 1.225, 1)
	root.add_child(ancestor)
	var wrapper := DeckSurface.new()
	ancestor.add_child(wrapper)
	wrapper.position = Vector3(0.2, 0.1, -0.3)
	var local_pose := Transform3D(Basis(Vector3.UP, PI / 2), Vector3(0.4, 0.12, -0.6))
	check(wrapper.configure_private_surface(&"MainDeck", local_pose, 3.30, 2.00, 0.10, 1.5), "private surface configures")
	var surface: StorageSurface = wrapper.get_storage_surface()
	check(surface.get_grid_size() == Vector2i(33, 20), "private grid is 33 x 20 beneath scaled ancestry")
	check(is_equal_approx(surface.cell_size_m, 0.10), "private cells remain 0.10 metres")
	check(surface.get_usable_size_m().is_equal_approx(Vector2(3.30, 2.00)), "private size remains literal metres")
	# Preserve scaled wrapper origin (3.7,0.9425,1.778); +90 turns metric (0.4,0.12,-0.6) into (-0.6,0.12,-0.4).
	check(surface.global_position.is_equal_approx(Vector3(3.1, 1.0625, 1.378)), "profile offset is applied in metric axes")
	check(surface.global_basis.is_equal_approx(Basis(Vector3.UP, PI)), "profile orientation composes without inherited scale")
	ancestor.scale = Vector3(2, 3, 0.5)
	check(surface.get_grid_size() == Vector2i(33, 20) and is_equal_approx(surface.cell_size_m, 0.10), "later visual scale changes leave configured metric grid intact")
	var second := DeckSurface.new()
	ancestor.add_child(second)
	check(second.configure_private_surface(&"Second", Transform3D.IDENTITY, 3.30, 2.00, 0.10, 1.5), "new surface configures after visual scale change")
	check(second.get_storage_surface().get_grid_size() == Vector2i(33, 20) and is_equal_approx(second.get_storage_surface().cell_size_m, 0.10), "new surfaces also ignore changed visual scale")
	ancestor.free()
	await test_production_fixtures()

	# Ordinary furniture still converts local dimensions and average-axis cells.
	var furniture := Node3D.new()
	furniture.scale = Vector3(2, 3, 1)
	root.add_child(furniture)
	var ordinary := StorageSurface.new()
	furniture.add_child(ordinary)
	ordinary.configure(&"Ordinary", 1.5, 1.5, 0.125)
	check(ordinary.get_grid_size() == Vector2i(16, 8), "ordinary scaled furniture retains 16 x 8 conversion")
	check(is_equal_approx(ordinary.cell_size_m, 0.1875) and ordinary.get_usable_size_m().is_equal_approx(Vector2(3, 1.5)), "ordinary storage retains scale-aware dimensions/cells")
	furniture.free()
	print("PASS: Receiving deck metric isolation tests" if failures == 0 else "FAIL: Receiving deck metric isolation tests (%d)" % failures)
	quit(0 if failures == 0 else 1)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func test_production_fixtures() -> void:
	# Catches fixture bodies and cargo using different frames under runtime scale.
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	root.add_child(wing)
	await physics_frame
	var runtime = wing.get_node("ReceivingRuntime")
	check(runtime.run_debug_delivery(1842, 9001, 24, ReceivingDeckLayoutPlanner.FixtureMode.MIXED), "scaled production mixed delivery prepares")
	await physics_frame
	var presenter = runtime.get_node("ReceivingDeckPresenter")
	var metric := Transform3D(presenter.global_basis.orthonormalized(), presenter.global_position)
	var batch: LootBatch = runtime.get_node("ReceivingManager").get_active_batch()
	var surfaces := {}
	for surface: StorageSurface in presenter.get_private_storage_surfaces():
		surfaces[surface.surface_id] = surface
		check(is_equal_approx(surface.cell_size_m, 0.10) and surface.global_basis.get_scale().is_equal_approx(Vector3.ONE), "each production private surface uses 0.10 m and unit scale")
	for fixture: ReceivingFreightFixtureInstance in batch.presentation_fixtures:
		var definition: Resource
		for candidate: Resource in runtime.deck_profile.freight_fixture_definitions:
			if candidate.fixture_id == fixture.fixture_definition_id:
				definition = candidate
		var cargo: StorageSurface = surfaces[fixture.surface_id]
		var expected: Transform3D = metric * fixture.local_transform * definition.item_surface_local_transform
		check(cargo.global_transform.is_equal_approx(expected), "fixture cargo pose uses presenter metric frame")
		var expected_grid := Vector2i(floori(definition.item_surface_usable_width_m / 0.10), floori(definition.item_surface_usable_depth_m / 0.10))
		check(cargo.get_grid_size() == expected_grid, "fixture cargo dimensions match literal definition metres")
		for fixture_root: Node3D in presenter.get_materialized_fixture_nodes():
			if fixture_root.name == "FreightFixture_%s" % fixture.instance_id.validate_node_name():
				check(fixture_root.global_transform.is_equal_approx(metric * fixture.local_transform), "fixture visual body shares the cargo metric frame")
	wing.free()