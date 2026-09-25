extends SceneTree

var game: Node

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/satisfying_%s.png" % name)

func load_case(location: String, type_id: String, label: String) -> void:
	if is_instance_valid(game.run): game.run.phase = RunManager.Phase.FINISHED
	game.start_run(location)
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.run.phase = RunManager.Phase.ACTIVE
	game.level.player.position = game.level.van.load_position
	var found: LootItem
	for item in game.level.items:
		if item.data.type_id == type_id:
			found = item
			break
	if found == null:
		printerr("MISSING CAPTURE ITEM " + type_id)
		return
	game.run.carried = found
	found.state = LootItem.State.LOADING
	found.reparent(game.level.player.carry_anchor, false)
	found.position = Vector3.ZERO
	game.run.commit_load()
	await create_timer(0.15).timeout
	await shot(label + "_burst")
	await create_timer(0.17).timeout
	await shot(label + "_impact")
	print("CASE %s $%d %s bounce %.3f cash %d" % [label, found.data.cash_value, found.data.weight_class, LootVan.impact_scale(found.data.weight_class), CashBurst3D.piece_count(found.data.cash_value)])

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("user://satisfying_capture.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 20, "noise": 20}
	root.add_child(game)
	await load_case("apartment", "chair", "chair_50")
	await load_case("house", "fridge", "fridge_340")
	await load_case("villa", "small_safe", "safe_500")
	await load_case("mansion", "piano", "piano_1000")
	await load_case("museum", "museum_artifact", "artifact_2500")
	game.run.phase = RunManager.Phase.FINISHED
	game.start_run("apartment")
	game.run.set_physics_process(false)
	game.run.phase = RunManager.Phase.ACTIVE
	await shot("noise_safe")
	game.run.current_noise = game.run.alarm_threshold * 0.8
	game.on_feedback("noise_warning", "+NOISE · ALARM CLOSE")
	game.ui.update_run(game.run, 0.2)
	await shot("noise_warning")
	game.run.current_noise = game.run.alarm_threshold
	game.run.alarm_active = true
	game.run.remaining = 11
	game.on_feedback("alarm", "ALARM! GET OUT!")
	game.ui.update_run(game.run, 0.1)
	await shot("alarm_trigger")
	await create_timer(0.9).timeout
	game.ui.update_run(game.run, 0.1)
	await shot("alarm_settled")
	game.run.phase = RunManager.Phase.FINISHED
	for amount in [150, 1000, 5200]:
		game.start_run("apartment")
		game.run.set_physics_process(false)
		game.run.phase = RunManager.Phase.ACTIVE
		game.level.player.position = game.level.van.load_position
		game.run.cargo_value = amount
		game.run.escape()
		await create_timer(0.12).timeout
		await shot("escape_%d" % amount)
	game.store.data.upgrades = {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}
	game.store.data.wallet = 10000
	game.action("shop")
	game.buy("grip")
	await create_timer(0.10).timeout
	await shot("upgrade_grip")
	game.buy("capacity")
	await create_timer(0.10).timeout
	await shot("upgrade_van")
	game.buy("strength")
	await create_timer(0.10).timeout
	await shot("upgrade_strength")
	game.action("settings")
	await shot("settings")
	game.free()
	print("SATISFYING CAPTURE COMPLETE")
	quit()
