extends SceneTree

var game: Node
var suffix := ""
var after := false

func _initialize() -> void:
	call_deferred("capture")

func outcome() -> Dictionary:
	return {"success":true,"earned":1240,"lost":0,"loot_value":1240,"items":6,"lost_items":0,"elapsed":42.0,"full_clear":false,"mode":"normal","rush_bonus":0,"contract_met":false,"unlocked_locations":[],"special_unlocked":false,"new_trophies":[],"loot_types":["fridge","chair","small_tv"],"final_job_completed":false}

func capture() -> void:
	LocalLog.enabled = false
	after = OS.get_cmdline_user_args().has("--after")
	for dimensions in [Vector2i(360, 720), Vector2i(320, 712)]:
		root.size = dimensions
		suffix = "%dx%d" % [dimensions.x, dimensions.y]
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/ui_studio_session.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.successes = 4
		game.store.data.first_job_at = 1
		game.store.data.wallet = 9420
		root.add_child(game)
		game.ui.set_safe_area_override(Vector4(0,72,0,54))
		await shot("home")
		game.action("locations")
		await shot("jobs")
		game.ui.jobs_index = Balance.LOCATION_ORDER.find("pyramid")
		game.ui.locations(game.store)
		await shot("chapter_locked")
		game.store.data.objectives.apartment.cash = true
		game.store.data.objectives.apartment.signature = true
		game.store.data.upgrades.capacity = 6
		SpecialJobs.make_pending(game.store.data, "apartment")
		game.ui.jobs_index = 0
		game.ui.locations(game.store)
		await shot("jobs_final_special")
		game.store.data.special_pending = false
		game.action("shop")
		await shot("upgrades")
		game.ui.shop_toggle_details("strength")
		await shot("upgrade_details")
		game.action("collection")
		await shot("collection_empty")
		game.store.data.trophies.append(Balance.TROPHIES.keys()[0])
		game.action("collection")
		await shot("collection_owned")
		game.action("cosmetics")
		await shot("cosmetics")
		game.action("settings")
		await shot("settings")
		game.action("stats")
		await shot("stats")
		game.store.data.duplication = Duplication.defaults()
		game.store.data.duplication.unlocked = true
		game.store.data.duplication.slot_level = 2
		game.store.data.duplication.known = ["fridge","piano","lab_quantum_core"]
		Duplication.start(game.store.data,0,"fridge",int(Time.get_unix_time_from_system())-10)
		Duplication.start(game.store.data,1,"piano",int(Time.get_unix_time_from_system())-100)
		game.ui.duplication_lab(game.store)
		await shot("duplication")
		for state in ["success", "busted", "abandoned", "trophy", "full_clear", "final_job", "museum_final", "special"]:
			var result := outcome()
			var location := "apartment"
			if state in ["busted", "abandoned"]:
				result.success = false
				result.earned = 0
				result.lost = 2350 if state == "busted" else 0
				result.lost_items = 8 if state == "busted" else 0
				result.alarm_triggered = state == "busted"
				result.abandoned = state == "abandoned"
			if state in ["trophy", "full_clear", "final_job", "museum_final"]: result.new_trophies = ["PINK FLAMINGO"]
			if state in ["full_clear", "final_job", "museum_final"]: result.full_clear = true
			if state in ["final_job", "museum_final"]:
				result.final_job_completed = true
				result.mode = "FINAL_JOB"
				result.earned = 4600
				result.unlocked_locations = ["house"]
			if state == "museum_final":
				location = "museum"
				result.unlocked_locations = ["pyramid"]
			if state == "special":
				result.mode = SpecialJobs.MODE
				result.rush_bonus = 400
			game.ui.results(result, game.store, location)
			await shot(state)
		game.start_run("apartment")
		game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		await shot("hud_ready")
		game.run.phase = RunManager.Phase.ACTIVE
		game.run.current_noise = game.run.alarm_threshold * 0.95
		await shot("hud_warning")
		game.run.alarm_active = true
		game.run.remaining = 8
		await shot("hud_alarm")
		game.run.cargo_used = game.run.capacity()
		game.run.cargo_value = 2350
		await shot("hud_full")
		game.ui.show_pause()
		await shot("pause")
		game.cleanup_run()
		game.start_tutorial()
		game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		await shot("tutorial")
		game.free()
		await process_frame
	print("STUDIO UI CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/studio_%s_%s_%s.png" % ["after" if after else "before", label, suffix])
