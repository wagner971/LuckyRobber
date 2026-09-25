extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await create_timer(0.42).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/daily_wheel_capture_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	root.add_child(game)
	await shot("daily_wheel_home_450x800")
	game.open_menu("daily_wheel")
	await shot("daily_wheel_450x800")
	root.size = Vector2i(360, 640)
	game.open_menu("daily_wheel")
	await shot("daily_wheel_360x640")
	var prize: Dictionary = game.store.claim_daily_spin(int(Time.get_unix_time_from_system()), 40)
	game.ui.animate_daily_spin(prize, game.store)
	await create_timer(3.7).timeout
	await shot("daily_wheel_reward_360x640")
	game.free()
	print("DAILY WHEEL CAPTURES COMPLETE")
	quit()
