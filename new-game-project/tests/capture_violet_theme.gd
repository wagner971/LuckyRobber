extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	LocalLog.enabled=false
	root.size=Vector2i(450,800)
	var suffix := "before" if OS.get_cmdline_user_args().has("--before") else "after"
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new("res://tests/vivid_capture_profile.json")
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	game.store.data.heist_briefing_seen=true
	game.store.data.wallet=6100
	game.store.data.diamonds=29
	game.store.data.unlocked=Balance.LOCATION_ORDER.duplicate()
	game.store.data.museum_final_job_completed=true
	root.add_child(game)
	for page in ["home","shop","locations","garage","cosmetics"]:
		game.open_menu(page)
		await create_timer(0.9).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/violet_%s_%s.png" % [page,suffix])
	for location in ["apartment"]:
		game.start_run(location)
		await create_timer(0.4).timeout
		if is_instance_valid(game.run): game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/violet_%s_%s.png" % [location,suffix])
		game.cleanup_run()
	game.free()
	quit()

