extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/electronics_polish_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.upgrades = {"strength":3,"grip":7,"carry":7,"capacity":9,"noise":7}
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.first_job_at = 1
	root.add_child(game)
	game.start_run("electronics")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.level.player.position = Vector3(-3.2,0,0.8)
	await shot("arcade")
	game.level.player.position = Vector3(2.0,0,-0.65)
	await shot("displays")
	game.level.player.position = Vector3(0,0,-3.8)
	await shot("service")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(0,0,3.6)
	await shot("narrow")
	game.free()
	await process_frame
	root.size = Vector2i(960,800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("electronics",1)
	level.camera.position = Vector3(8,13,17)
	level.camera.look_at(Vector3(0,0,0.0))
	level.camera.size = 17.5
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/electronics.png")
	level.free()
	print("ELECTRONICS POLISH CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/electronics_polish_%s.png" % label)
