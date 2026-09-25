extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(360,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.wallet = 1600
	root.add_child(game)
	game.open_menu("shop")
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/strength_noise_shop.png")
	game.free()
	await process_frame
	quit()
