extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/laboratory_jobs_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("laboratory") + 1)
	game.store.data.duplication.unlocked = true
	game.store.data.duplication.known = ["lab_microscope"]
	root.add_child(game)
	game.ui.jobs_index = Balance.LOCATION_ORDER.find("laboratory")
	game.action("locations")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/laboratory_jobs_450x800.png")
	game.free()
	print("LABORATORY JOBS CAPTURE COMPLETE")
	quit()
