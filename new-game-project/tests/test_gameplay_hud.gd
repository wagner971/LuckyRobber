extends "res://tests/test_ui_v2.gd"

var game: Node

func shot(label: String) -> void:
	await process_frame
	await process_frame
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/hud_" + label + ".png")

func check_bounds() -> void:
	var ui = game.ui
	var view = ui.root.get_global_rect()
	for control in [ui.hud_top, ui.instruction_panel, ui.hud_bottom, ui.pause_button, ui.timer, ui.van_value, ui.space, ui.noise_status, ui.target]:
		check(view.encloses(control.get_global_rect()), "%s fits %s" % [control.name, root.size])
	check(ui.hud_top.get_global_rect().end.y < view.size.y * 0.23, "Top HUD leaves playfield clear")
	check(ui.hud_bottom.get_global_rect().position.y > view.size.y * 0.7, "Interaction stays below playfield")
	check(ui.instruction_panel.size == ui.instruction_panel.get_combined_minimum_size() and ui.instruction_panel.get_global_rect().end.y < ui.hud_bottom.get_global_rect().position.y, "Instruction card hugs its text above bottom actions")
	if ui.escape_button.visible:
		check(not ui.instruction_panel.get_global_rect().intersects(ui.escape_button.get_global_rect()), "Compact instruction card does not cover ESCAPE")

func test() -> void:
	LocalLog.enabled = false
	game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/hud_profile.json")
	game.store.session_only = true
	game.store.data.heist_briefing_seen = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.upgrades = {"strength":5,"grip":20,"carry":20,"capacity":16,"noise":20}
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	game.start_run("mansion")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	var ui = game.ui
	var run = game.run
	check(ui.scene_polish.visible and game.level.scene_environment.adjustment_enabled and game.level.scene_environment.glow_enabled, "Shared mobile polish is active during a heist")
	check(ui.hud.get_child(0) == ui.scene_polish and ui.scene_polish.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Polish sits behind readable HUD and does not capture touch")
	game.level.set_visual_polish(false)
	ui.set_scene_polish("mansion", false)
	check(not ui.scene_polish.visible and not game.level.scene_environment.glow_enabled, "Camera effects switch can remove the visual pass")
	game.level.set_visual_polish(true)
	ui.set_scene_polish("mansion", true)
	ui.update_run(run, 0)
	await shot("ready")
	check(ui.timer.text == "%04.1f" % run.remaining and not ui.meter.visible, "Ready timer reflects this job and inactive progress stays hidden")
	check(ui.pause_button.icon != null and ui.interaction_icon.texture != null, "HUD icons imported")
	check(not ui.drop_button.visible and not ui.escape_button.visible, "Ready has no unavailable actions")
	check_bounds()
	# Decoration is transparent to actual viewport touch events.
	var touch = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = ui.van_value.get_global_rect().get_center()
	touch.pressed = true
	root.push_input(touch, true)
	check(ui.input.pointer == 0, "Noninteractive HUD decoration does not steal joystick touches")
	touch.pressed = false
	root.push_input(touch, true)
	await process_frame
	touch.position = ui.pause_button.get_global_rect().get_center()
	touch.pressed = true
	root.push_input(touch, true)
	check(ui.input.pointer == -1, "Pause touch does not start joystick")
	touch.pressed = false
	root.push_input(touch, true)
	check(run.phase == RunManager.Phase.PAUSED, "Touch pause opens modal")
	await shot("pause")
	find_button(ui.modal, "RESUME").pressed.emit()
	run.phase = RunManager.Phase.ACTIVE
	run.remaining = 42.8
	run.target = game.level.items[0]
	run.progress = 0.4
	run.progress_duration = 0.8
	run.nearby_text = "ART COLLECTION · $1850 · 6 CARGO"
	ui.update_run(run, 0)
	check(ui.meter.visible and is_equal_approx(ui.meter.value, 50), "Pickup progress displays actual fraction")
	await shot("pickup")
	run.commit_pickup()
	ui.update_run(run, 0)
	check(ui.drop_button.visible and ui.target.text == run.carried.data.display_name, "Carrying shows item and DROP")
	await shot("carry")
	run.nearby_text = "LOADING " + run.carried.data.display_name
	run.progress = 0.15
	run.progress_duration = Balance.LOAD_DURATION
	ui.update_run(run, 0)
	check(ui.interaction_caption.text == "STAY HERE TO LOAD" and ui.interaction_icon.texture == HudStyle.ICONS.box and is_equal_approx(ui.meter.value, 50), "Load uses crate icon and real loading duration")
	await shot("loading")
	await process_frame
	touch.position = ui.drop_button.get_global_rect().get_center()
	touch.pressed = true
	root.push_input(touch, true)
	touch.pressed = false
	root.push_input(touch, true)
	check(run.carried == null and ui.input.pointer == -1, "Touch DROP releases actual item without starting movement")
	run.progress = 0
	run.nearby_text = "RETURN TO THE VAN"
	run.current_noise = run.alarm_threshold * 0.8
	run.cargo_used = 14
	run.cargo_value = 2450
	ui.update_run(run, 0)
	check(ui.noise_status.text.contains("ALARM CLOSE") and ui.noise_icon.texture == HudStyle.ICONS.warning, "Warning uses label and warning icon")
	check(ui.van_value.text == "$2450" and ui.space.text == "14 / 38", "Cargo and cash reflect run, not bank")
	await shot("warning")
	check(not ui.alarm_vignette.visible, "Noise warning remains confined to the HUD")
	run.cargo_used = run.capacity()
	run.select_target()
	ui.update_run(run, 0)
	ui.notify("VAN FULL · ESCAPE!")
	await shot("full")
	check(run.label_item() == null and run.nearby_text == "VAN FULL · ESCAPE!", "Full van stops suggesting more pickups")
	check(ui.interaction_caption.text == "VAN FULL" and ui.target.text.contains("ESCAPE!"), "Full van directs the player to escape")
	run.alarm_active = true
	run.tutorial = "ALARM! RETURN TO THE VAN · ESCAPE"
	run.remaining = 9.4
	run.current_noise = run.alarm_threshold
	run.cargo_used = run.capacity()
	run.cargo_value = 12340
	game.level.player.global_position = game.level.van.load_position
	ui.notify("ALARM! GET OUT!")
	ui.update_run(run, 0)
	await shot("alarm")
	check(ui.space.text.begins_with("FULL") and ui.cargo_bar.value == 100, "Full van has explicit label and full meter")
	check(ui.escape_button.visible and ui.escape_button.text.contains("ESCAPE NOW"), "Alarm exposes escape action")
	check(ui.toast_panel.visible and ui.toast.text == "ALARM! GET OUT!", "Alarm banner visible")
	check(ui.timer_caption.text == "POLICE IN" and ui.alarm_countdown_bar.visible and ui.alarm_vignette.visible, "Alarm shows a dedicated police countdown and static amber corners")
	check_bounds()
	root.size = Vector2i(360, 800)
	await shot("alarm_tall")
	check_bounds()
	root.size = Vector2i(600, 800)
	await shot("alarm_tablet")
	check_bounds()
	ui.update_run(run, 2)
	check(not ui.toast_panel.visible and ui.toast.text.is_empty(), "Feedback card hides completely on expiry")
	root.size = Vector2i(450, 800)
	await process_frame
	await process_frame
	ui.update_run(run, 0)
	await shot("alarm_settled")
	touch.position = ui.escape_button.get_global_rect().get_center()
	touch.pressed = true
	root.push_input(touch, true)
	touch.pressed = false
	root.push_input(touch, true)
	check(run.phase == RunManager.Phase.FINISHED and game.screen == "results", "Touch ESCAPE settles run normally")
	game.free()
	print("GAMEPLAY HUD CHECKS %d; FAILURES %d" % [checks, failures])
	quit(1 if failures else 0)
