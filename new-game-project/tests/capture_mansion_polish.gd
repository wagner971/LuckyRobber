extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/mansion_polish_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.upgrades = {"strength":3,"grip":7,"carry":7,"capacity":9,"noise":7}
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.first_job_at = 1
	root.add_child(game)
	game.start_run("mansion")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.level.player.position = Vector3(-3.7,0,0.5)
	await shot("lounge")
	game.level.player.position = Vector3(-4.8,0,-3.5)
	await shot("library")
	game.level.player.position = Vector3(4.3,0,-2.0)
	await shot("bath")
	game.level.player.position = Vector3(4.6,0,-6.1)
	await shot("suite")
	game.level.player.position = Vector3(3.4,0,-8.7)
	await shot("music")
	game.level.player.position = Vector3(-3.4,0,-8.0)
	await shot("gallery")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(0,0,3.6)
	await shot("narrow")
	game.free()
	await process_frame
	root.size = Vector2i(960,800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("mansion",1)
	level.camera.position = Vector3(10,17,20)
	level.camera.look_at(Vector3(0,0,-2.3))
	level.camera.size = 20.5
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/mansion.png")
	level.free()
	print("MANSION POLISH CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/mansion_polish_%s.png" % label)
