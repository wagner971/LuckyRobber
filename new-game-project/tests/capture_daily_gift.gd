extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/daily_gift_capture_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	root.size = Vector2i(450, 800)
	root.add_child(game)
	await shot("daily_gift_ready_450x800")
	game.ui.home_gift_button.pressed.emit()
	await shot("daily_gift_reward_450x800")
	await create_timer(2.25).timeout
	await shot("daily_gift_claimed_450x800")
	root.size = Vector2i(360, 640)
	game.ui.home(game.store)
	await shot("daily_gift_claimed_360x640")
	game.free()
	print("DAILY GIFT CAPTURES COMPLETE")
	quit()
