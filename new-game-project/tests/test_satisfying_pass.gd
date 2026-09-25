extends "res://tests/test_suite.gd"

func test() -> void:
	LocalLog.enabled = false
	await create_run()
	var original_player := world.player.global_position
	var camera := CameraJuice.new()
	world.add_child(camera)
	camera.setup(world.camera)
	camera.set_process(false)
	var original_camera := world.camera.position
	camera.impact_punch(1.0)
	camera._process(0.05)
	check(world.player.global_position == original_player and world.camera.position.distance_to(original_camera) < 0.06, "Camera punch moves only the camera by a tiny amount")
	check(world.camera.size >= camera.base_size * 0.985, "Orthographic punch stays below 1.5% zoom")
	camera.set_enabled(false)
	check(world.camera.position == original_camera and world.camera.size == camera.base_size, "Camera effects OFF restores exact base transform")
	camera.alarm_pulse()
	camera._process(0.1)
	check(world.camera.position == original_camera, "Camera effects OFF blocks alarm impulse")
	camera.setup(world.camera, world.player)
	world.player.position += Vector3(2.0, 0.0, -4.0)
	camera._process(0.35)
	check(world.camera.position.x > original_camera.x and world.camera.position.z < original_camera.z and world.camera.size == camera.base_size, "Closer gameplay camera follows the thief smoothly without zoom jumps")
	camera.set_enabled(false)
	check(world.camera.position == camera.base_position + camera.follow_offset, "Disabling shake preserves the follow camera")
	check(LootVan.impact_scale("LIGHT") < LootVan.impact_scale("MEDIUM") and LootVan.impact_scale("MEDIUM") < LootVan.impact_scale("HEAVY") and LootVan.impact_scale("HEAVY") < LootVan.impact_scale("VERY_HEAVY"), "Van compression increases monotonically with weight")
	for weight in ["LIGHT", "MEDIUM", "HEAVY", "VERY_HEAVY"]:
		world.van.land_impact(weight, 340)
		check(world.van.model.position.y < 0 and world.van.last_impact_weight == weight, "%s load stores weight and compresses van" % weight)
	var haptics := HapticManager.new()
	root.add_child(haptics)
	haptics.force_mobile_for_test = true
	haptics.set_enabled(false)
	haptics.play("alarm")
	check(haptics.vibration_calls == 0, "Haptics OFF makes no vibration calls")
	haptics.set_enabled(true)
	haptics.play("pickup_light")
	check(haptics.vibration_calls == 1, "Enabled haptics makes one pickup pulse")
	haptics.set_enabled(false)
	haptics.free()
	var sound := SoundBank.new()
	root.add_child(sound)
	check(sound.groups.pickup_light.size() == 3 and sound.groups.pickup_heavy.size() == 3, "Light and heavy pickups each have three local WAV variants")
	check(sound.groups.impact_light.size() == 2 and sound.groups.impact_very_heavy.size() == 2, "Van impacts have weight variants")
	sound.set_sfx_volume(0)
	sound.play("alarm")
	check(sound.active_players.is_empty() and not sound.played.has("alarm_trigger"), "Zero SFX volume makes no player and no error")
	sound.set_sfx_volume(1)
	for i in 8: sound.play("cash_burst")
	check(sound.active_players.size() <= SoundBank.MAX_VOICES, "Audio mixer caps overlapping voices")
	sound.free()
	var old_balance_hash := Balance.ALARM_THRESHOLD_FACTOR
	check(old_balance_hash == 0.65 and Balance.ALARM_WINDOW == 12.0 and Balance.LOAD_DURATION == 0.30, "Balance constants remain unchanged")
	run.free()
	world.free()
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("user://satisfying_pass_test.json")
	game.store.session_only = true
	game.store.data.heist_briefing_seen = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.wallet = 10000
	root.add_child(game)
	game.sound_muted = false
	game.sfx_volume = 1.0
	game.sound.set_sfx_volume(1.0)
	game.haptics_enabled = true
	game.haptics.set_enabled(true)
	game.camera_effects_enabled = true
	game.set_process(false)
	game.set_physics_process(false)
	game.action("shop")
	var before_wallet: int = game.store.data.wallet
	game.buy("grip")
	check(game.store.data.upgrades.grip == 2 and game.store.data.wallet == before_wallet - Balance.upgrade_cost("grip", 1), "Upgrade purchase charges exactly once")
	game.action("home")
	await create_timer(0.6).timeout
	check(game.store.data.upgrades.grip == 2 and game.ui.result_overlay == null, "Scene change cancels upgrade animation without extra purchase")
	game.action("shop")
	game.buy("strength")
	for overlay in game.ui.get_tree().get_nodes_in_group("ui_juice_overlay"):
		check(overlay.size.y <= 112, "Strength badge stays compact")
	check(game.store.data.upgrades.strength == 2 and game.ui.get_tree().get_nodes_in_group("ui_juice_overlay").size() > 0, "Strength purchase reveals a short unlock badge")
	game.action("settings")
	game.action("toggle_haptics")
	game.action("toggle_camera_effects")
	game.action("sfx_volume:0.0")
	check(not game.haptics_enabled and not game.camera_effects_enabled and game.sound.volume == 0, "Settings disable haptics/camera and mute SFX")
	var config := ConfigFile.new()
	check(config.load(game.store.path + ".settings.cfg") == OK and not config.get_value("feedback", "haptics", true) and not config.get_value("feedback", "camera_effects", true) and float(config.get_value("audio", "sfx_volume", 1)) == 0.0, "Feedback settings persist separately from progress")
	game.start_run("apartment")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.run.phase = RunManager.Phase.ACTIVE
	check(not game.camera_juice.enabled, "New run inherits camera effects OFF")
	game.run.current_noise = game.run.alarm_threshold * 0.5
	game.ui.update_run(game.run, 0.016)
	check(game.ui.noise_bar.value > 0 and game.ui.noise_bar.value < 50, "Noise bar animates rather than jumping")
	game.run.current_noise = game.run.alarm_threshold
	game.run.alarm_active = true
	game.level.player.position = game.level.van.load_position
	game.ui.notify("ALARM! GET OUT!")
	game.ui.update_run(game.run, 0.016)
	check(game.ui.toast_time <= 0.8 and game.ui.timer_caption.text == "POLICE IN", "Alarm callout is short and police countdown is legible")
	game.ui.update_run(game.run, 1.0)
	game.ui.update_run(game.run, 0.016)
	check(game.ui.timer_caption.text == "POLICE IN" and game.ui.toast.text == "", "Alarm settles into one compact countdown")
	check(game.run.can_escape() and not game.ui.instruction_panel.visible, "Alarm hides duplicate instruction when escape CTA is available")
	game.run.alarm_active = false
	game.run.remaining = 20
	game.run.current_noise = 0
	game.run.cargo_value = 140
	game.run.cargo.append(game.level.items[0])
	game.level.player.position = game.level.van.load_position
	var wallet_before_escape: int = game.store.data.wallet
	game.run.escape()
	game.run.escape()
	check(game.store.data.wallet == wallet_before_escape + 140 and game.screen == "results" and game.ui.result_overlay == null, "Escape banks the item and opens Results directly")
	check(game.store.data.wallet == wallet_before_escape + 140, "Loot value is paid once")
	check(result_text(game.ui.menu).contains("ESCAPED!") and (result_text(game.ui.menu).contains("PLAY AGAIN") or result_text(game.ui.menu).contains("UPGRADE CARRY SPEED")), "Results emphasizes escape and the next action")
	await create_timer(0.7).timeout
	check(result_text(game.ui.menu).contains("+ $140"), "Cash reward counts up to the banked sale amount")
	game.action("home")
	await create_timer(0.9).timeout
	check(game.ui.get_tree().get_nodes_in_group("ui_juice_overlay").is_empty(), "Result overlay cleans up after scene change")
	game.start_run("apartment")
	game.run.phase = RunManager.Phase.ACTIVE
	game.run.cargo_value = 500
	var wallet_before_bust: int = game.store.data.wallet
	game.run.finish(false)
	check(game.store.data.wallet == wallet_before_bust and game.run.result.lost == 500 and game.ui.result_overlay == null and result_text(game.ui.menu).contains("BUSTED!"), "Busted result preserves wallet and shows loss")
	game.free()
	print("SATISFYING PASS CHECKS %d; FAILURES %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func result_text(node: Node) -> String:
	var value := str(node.text) + "\n" if node is Label or node is Button else ""
	for child in node.get_children(): value += result_text(child)
	return value
