extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/electronics_jobs_polish_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.unlocked = ["apartment","house","villa","electronics"]
	game.store.data.apartment_final_job_completed = true
	root.add_child(game)
	game.ui.jobs_index = 3
	game.action("locations")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/electronics_jobs_polish_450x800.png")
	game.free()
	print("ELECTRONICS JOBS CAPTURE COMPLETE")
	quit()
