extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(path: String) -> void:
	await create_timer(0.7).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/english_pub_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.successes = 4
	game.store.data.museum_final_job_completed = true
	game.store.data.apartment_final_job_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.upgrades = {"strength":5,"grip":13,"carry":13,"capacity":20,"noise":10}
	root.add_child(game)
	game.ui.jobs_index = Balance.LOCATION_ORDER.find("english_pub")
	game.action("locations")
	await shot("res://tests/english_pub_jobs.png")
	game.start_run("english_pub")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("res://tests/english_pub_gameplay.png")
	game.level.player.position = Vector3(1.2,0,-6.1)
	await shot("res://tests/english_pub_bow.png")
	game.action("locations")
	root.size = Vector2i(360,800)
	await shot("res://tests/english_pub_jobs_tall.png")
	game.free()
	print("PUB UI CAPTURED")
	quit()
