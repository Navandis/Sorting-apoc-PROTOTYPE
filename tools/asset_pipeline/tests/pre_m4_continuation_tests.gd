extends "res://tools/asset_pipeline/tests/m2_continuation_tests.gd"

func run() -> void:
	create_timer(90).timeout.connect(func():
		push_error("PRE_M4_CONTINUATION incomplete helper")
		quit(3))
	var mode:=""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--evidence-dir="):external_dir=arg.trim_prefix("--evidence-dir=")
		if arg.begins_with("--mode="):mode=arg.trim_prefix("--mode=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")) and mode in ["write","read"],"Explicit external continuation mode/directory required"):
		finish()
		return
	var snapshots:=Snapshots.new()
	var codec=load("res://gameplay/run/state_codec.gd").new()
	var service:=Service.new(external_dir.path_join("slot"))
	var expected_path:=external_dir.path_join("expected.json")
	if mode=="write":
		var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/props_inventory.json"))
		var names: Array=["SM_Dry_Goods_01h","SM_KB3D_SDM_HockeyStick_01","SM_KB3D_SIS_FourFoldedShirtsBundle_01","SM_KB3D_SIS_HikingBoots_01","SM_KB3D_HOK_PropBasketball_01","SM_KB3D_SIS_IntRecordStore_AcousticGuitar_01","SM_Military_Med_crate_01","SM_KB3D_LVC_RawFish_Medium_02"]
		var ids: Array=[]
		for name: String in names:
			ids.append(inventory.models.filter(func(r):return r.source_path.get_file().get_basename()==name)[0].item_id)
		var scenario: Dictionary=load("res://gameplay/run/run_scenario.gd").new().default_definition()
		scenario.events=[]
		for index: int in 2:
			scenario.events.append({"id":"return_%03d" % (index+1),"kind":"return","day":1,"at":25224.0+24.0*index,"departure":0.0,"manifest":ids.slice(index*4,index*4+4),"presentation_seed":9450+index})
		var wing: Node3D=load(Snapshots.WING).instantiate()
		wing.configure_new_run(scenario)
		wing.get_node("Player").enable_held_item_view=false
		root.add_child(wing)
		wing.set_process(false)
		wing.get_node("Player").set_physics_process(false)
		wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
		wing.run_schedule.advance(30.0)
		var runtime=wing.get_node("ReceivingRuntime")
		check(runtime.lift_cycle.can_take_receiving() and runtime.receiving_manager.get_queued_batch_ids().size()==1,"New mixed A OPEN and exact B FIFO queued")
		var carry=wing.get_node("Player/CarriedItems")
		check(carry.max_bulk==10,"Player capacity unchanged")
		check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(carry),"Writer actual TAKE leaves remaining cargo")
		var expected:=snapshots.capture(wing)
		check(snapshots.validate(expected).is_empty(),"New mixed cargo snapshot validates: "+snapshots.validate(expected))
		var file:=FileAccess.open(expected_path,FileAccess.WRITE)
		file.store_string(codec.stringify(expected))
		file.close()
		check(service.save_snapshot(expected).ok,"Disposable external service saves remaining exact mixed cargo")
		var incompatible: Dictionary=expected.duplicate(true)
		incompatible.content="pre-expansion-fingerprint"
		check(not snapshots.validate(incompatible).is_empty(),"Whole-catalogue content mismatch retains explainable incompatible-save rejection")
		wing.free()
	else:
		var expected: Dictionary=codec.parse(FileAccess.get_file_as_string(expected_path))
		var shell:=HeadlessShell.new()
		shell.save_service=service
		root.add_child(shell)
		if not check(shell.continue_run(),"Separate reader production Continue loads new-item cargo"):
			shell.free()
			finish()
			return
		var wing=shell.wing
		wing.set_process(false)
		wing.get_node("Player").set_physics_process(false)
		wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
		check(snapshots.capture(wing)==expected,"Exact identities, remaining cargo and FIFO survive separate process")
		var runtime=wing.get_node("ReceivingRuntime")
		var manager=runtime.receiving_manager
		var active: String=manager.get_active_batch_id()
		var queued: String=manager.get_queued_batch_ids()[0]
		var carry=wing.get_node("Player/CarriedItems")
		check(runtime.deck_presenter.get_materialized_world_items().size()==3,"Only remaining cargo materializes")
		for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():check(world.pickup_into(carry),"Restored A actual TAKE")
		check(runtime.lift_cycle.get_cycle_state()==5 and manager.get_active_batch_id()==active,"Last TAKE starts closing while A remains authoritative")
		wing.run_schedule.advance(runtime.lift_cycle._phase_duration-runtime.lift_cycle._elapsed)
		check(runtime.lift_cycle.is_busy() and manager.get_active_batch_id()==active,"A retained through full outbound")
		wing.run_schedule.advance(runtime.lift_cycle._phase_duration-runtime.lift_cycle._elapsed)
		check(manager.get_active_batch_id()==queued,"FIFO B activates after full outbound only")
		# Advance the real remaining ARRIVAL cue, then the normal shutter reveal.
		# A fixed 20 seconds can still be inside the accepted arrival/reveal cycle.
		wing.run_schedule.advance(runtime.lift_cycle._phase_duration-runtime.lift_cycle._elapsed)
		wing.run_schedule.advance(6.0)
		check(runtime.lift_cycle.can_take_receiving(),"Exact B opens")
		for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():check(world.pickup_into(carry),"B actual TAKE")
		check(carry.get_item_count()==8,"All eight distinct committed items retained once")
		check(snapshots.validate(snapshots.capture(wing)).is_empty(),"Final exact cargo ownership validates")
		check(shell.save_and_exit(),"Production Save & Exit persists externally")
		shell.free()
	finish()

func finish() -> void:
	paused=false
	print("PRE_M4_CONTINUATION_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
