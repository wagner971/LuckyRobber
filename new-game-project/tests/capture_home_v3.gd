extends SceneTree

# QA: renders the Home page at phone resolution (720x1280) and on a short phone.
func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/home_v3_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.wallet = 4850
	game.store.data.diamonds = 33
	game.store.data.lucky_meter = 67
	root.add_child(game)
	game.ui.home(game.store)
	for i in range(14): await process_frame
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/home_v3.png")
	root.size = Vector2i(450, 800)
	game.ui.home(game.store)
	for i in range(14): await process_frame
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/home_v3_narrow.png")
	game.free()
	print("HOME V3 CAPTURE COMPLETE")
	quit()
