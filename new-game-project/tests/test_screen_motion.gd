extends SceneTree

var checks := 0
var failures := 0
var game

func _initialize() -> void: call_deferred("test")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + message)

func copy_text(node: Node) -> String:
	var result := str(node.text) if node is Label or node is Button else ""
	for child in node.get_children(): result += "\n" + copy_text(child)
	return result

func pointer_ignored(node: Node) -> bool:
	if node is Control and node.mouse_filter != Control.MOUSE_FILTER_IGNORE: return false
	for child in node.get_children():
		if not pointer_ignored(child): return false
	return true

func shot(tag: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/motion_" + tag + ".png")

func test() -> void:
	LocalLog.enabled = false
	for dimensions in [Vector2i(360,640),Vector2i(360,800)]:
		root.size = dimensions
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/motion_profile.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.heist_briefing_seen = true
		game.store.data.successes = 5
		game.store.data.museum_final_job_completed = true
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		game.store.data.duplication.unlocked = true
		root.add_child(game)
		game.ui.set_safe_area_override(Vector4(0,50,0,36))
		await create_timer(0.3).timeout
		for destination in ["locations","shop","collection","cosmetics","settings","stats","duplication","home"]:
			var old = weakref(game.ui.menu)
			game.ui.action_requested.emit(destination)
			check(game.screen == destination and old.get_ref() == game.ui.motion.outgoing, "Navigation keeps the outgoing page until the blend: " + destination)
			check(pointer_ignored(game.ui.motion.outgoing), "Outgoing page cannot receive a second press: " + destination)
			await create_timer(0.10).timeout
			if destination == "shop": await shot("menu_mid_%s" % dimensions.y)
			await create_timer(0.25).timeout
			# First-use shader compilation can delay layout frames on a cold renderer.
			var deadline := Time.get_ticks_msec() + 1000
			while is_instance_valid(game.ui.motion.outgoing) and Time.get_ticks_msec() < deadline:
				await process_frame
			check(old.get_ref() == null and not is_instance_valid(game.ui.motion.outgoing) and is_equal_approx(game.ui.menu.modulate.a,1.0), "Navigation releases the old page cleanly: " + destination)
		game.action("shop")
		game.action("settings")
		game.action("locations")
		game.action("collection")
		await create_timer(0.4).timeout
		check(game.screen == "collection" and not is_instance_valid(game.ui.motion.outgoing), "Rapid navigation settles on the last requested destination")
		game.action("stats")
		check(not copy_text(game.ui.menu).contains("NO FULL CLEAR YET") and not copy_text(game.ui.menu).contains("NORMAL BEST"), "Empty record footnotes are omitted")
		game.store.data.unlocked = ["apartment"]
		game.ui.jobs_index = 3
		game.action("locations")
		check(copy_text(game.ui.menu).contains("PLAY VILLA") and not copy_text(game.ui.menu).contains("Complete 2"), "Locked Jobs use a compact previous-job action")
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		game.ui.jobs_index = 0
		game.ui.locations(game.store)
		await create_timer(0.35).timeout
		game.ui.job_select(game.store,1)
		await create_timer(0.23).timeout
		check(game.ui.jobs_current_card.modulate.a > 0.1 and game.ui.jobs_current_card.scale.x > 0.96, "Incoming card fades in after the old card, without superimposed titles")
		await shot("card_mid_%s" % dimensions.y)
		game.ui.job_select(game.store,2)
		game.ui.job_select(game.store,0)
		await create_timer(0.45).timeout
		check(get_nodes_in_group("jobs_transition_card").is_empty() and game.ui.jobs_index == 0 and game.ui.jobs_current_card.scale == Vector2.ONE, "Rapid swipes leave a single centered card")
		game.ui.start_requested.emit("apartment","normal")
		game.ui.start_requested.emit("house","normal")
		check(game.ui.motion.travelling and game.screen == "locations", "Map loading starts behind an animated curtain")
		await create_timer(0.18).timeout
		check(game.current_location == "apartment" and is_instance_valid(game.run), "Double Play launches only the first requested map")
		check(not game.run.is_physics_processing() and not game.ui.input.enabled and not game.level.player.enabled, "Loading reveal holds simulation and movement")
		var remaining: float = game.run.remaining
		await shot("map_reveal_%s" % dimensions.y)
		await create_timer(0.35).timeout
		check(not game.ui.motion.travelling and not game.ui.motion.curtain.visible and game.run.remaining == remaining and game.run.phase == RunManager.Phase.READY, "Map reveal consumes no play time")
		check(game.ui.input.enabled and game.level.player.enabled and game.run.is_physics_processing(), "Map reveal restores movement and simulation")
		game.ui.action_requested.emit("pause")
		await create_timer(0.32).timeout
		check(game.run.phase == RunManager.Phase.PAUSED and is_equal_approx(game.ui.modal.modulate.a,1.0), "Pause modal settles fully visible")
		await shot("pause_%s" % dimensions.y)
		var old_modal = weakref(game.ui.modal)
		game.ui.action_requested.emit("resume")
		await create_timer(0.2).timeout
		check(game.run.phase == RunManager.Phase.READY and old_modal.get_ref() == null, "Resume removes its fading modal")
		game.run.finish(false)
		await create_timer(0.4).timeout
		check(game.screen == "results" and is_equal_approx(game.ui.menu.modulate.a,1.0), "Failure results settle with fully readable controls")
		await shot("failed_%s" % dimensions.y)
		game.ui.action_requested.emit("locations")
		await create_timer(0.35).timeout
		game.ui.start_requested.emit("house","normal")
		await create_timer(0.18).timeout
		game.action("pause")
		await create_timer(0.35).timeout
		check(game.run.phase == RunManager.Phase.PAUSED and not game.ui.input.enabled and not game.level.player.enabled, "Focus-loss pause during reveal is not undone")
		game.action("resume")
		game.run.finish(true)
		await create_timer(0.4).timeout
		check(game.screen == "results" and game.last_result.success and game.ui.menu.modulate.a == 1.0, "Successful results preserve their reward presentation")
		await shot("success_%s" % dimensions.y)
		game.free()
		await process_frame
	print("SCREEN MOTION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
