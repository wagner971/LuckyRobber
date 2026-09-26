extends SceneTree

# QA: renders the Jobs page in the new Bungee/Lilita layout at phone resolution.
func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/jobs_v3_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.wallet = 640
	game.store.data.diamonds = 19
	game.store.data.special_pending = true
	game.store.data.special_location_id = "apartment"
	root.add_child(game)
	game.ui.jobs_index = 0
	game.action("locations")
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/jobs_v3_apartment.png")
	game.ui.jobs_index = 3
	game.action("locations")
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/jobs_v3_locked.png")
	game.free()
	print("JOBS V3 CAPTURE COMPLETE")
	quit()
