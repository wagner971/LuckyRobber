extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/strength_powerup_capture_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.wallet = 3000
	root.size = Vector2i(450,800)
	root.add_child(game)
	game.open_menu("shop")
	await create_timer(0.25).timeout
	game.buy("strength")
	await create_timer(0.36).timeout
	await shot("strength_powerup_450x800")
	root.size = Vector2i(360,640)
	await create_timer(0.10).timeout
	await shot("strength_powerup_360x640")
	await create_timer(0.70).timeout
	game.free()
	print("STRENGTH POWER-UP CAPTURES COMPLETE")
	quit()
