extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.objectives.museum = {"cash": true, "signature": true, "full_clear": true}
	game.store.data.museum_final_job_completed = true
	root.add_child(game)
	for location in ["apartment", "laboratory", "castle"]:
		game.start_run(location)
		await create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/highlight_" + location + ".png")
		game.cleanup_run()
		await process_frame
	root.size = Vector2i(360,800)
	game.start_run("apartment", "normal", true)
	await create_timer(0.7).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/highlight_training_narrow.png")
	game.cleanup_run()
	game.free()
	await process_frame
	quit()
