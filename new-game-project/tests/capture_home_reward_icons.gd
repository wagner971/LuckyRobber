extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	LocalLog.enabled=false
	var game=load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	root.size=Vector2i(450,800)
	root.add_child(game)
	for resolution in [Vector2i(450,800),Vector2i(360,800)]:
		root.size=resolution
		game.ui.home(game.store)
		await create_timer(0.7).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/home_reward_icons_%d.png" % resolution.x)
	game.free()
	await process_frame
	quit()
