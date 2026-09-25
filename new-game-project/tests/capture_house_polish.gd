extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/house_polish_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.upgrades = {"strength":2,"grip":4,"carry":4,"capacity":6,"noise":4}
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.first_job_at = 1
	root.add_child(game)
	game.start_run("house")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.level.player.position = Vector3(-2.8,0,0.2)
	await shot("garage")
	game.level.player.position = Vector3(1.4,0,0.7)
	await shot("kitchen")
	game.level.player.position = Vector3(-2.0,0,-4.5)
	await shot("bath")
	game.level.player.position = Vector3(1.3,0,-5.0)
	await shot("lounge")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(0,0,5.3)
	await shot("narrow")
	game.free()
	await process_frame
	root.size = Vector2i(960,800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("house",1)
	level.camera.position = Vector3(9,14,18)
	level.camera.look_at(Vector3(0,0,0.7))
	level.camera.size = 15.5
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/house.png")
	level.free()
	print("HOUSE POLISH CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/house_polish_%s.png" % label)
