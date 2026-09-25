extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/villa_polish_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.upgrades = {"strength":3,"grip":7,"carry":7,"capacity":9,"noise":7}
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.store.data.first_job_at = 1
	root.add_child(game)
	game.start_run("villa")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.level.player.position = Vector3(-2.6,0,0.3)
	await shot("lounge")
	game.level.player.position = Vector3(3.1,0,0.4)
	await shot("study")
	game.level.player.position = Vector3(3.2,0,-5.6)
	await shot("bath")
	game.level.player.position = Vector3(-2.75,0,-6.4)
	await shot("music")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(0,0,3.6)
	await shot("narrow")
	game.free()
	await process_frame
	root.size = Vector2i(960,800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("villa",1)
	level.camera.position = Vector3(9,14,18)
	level.camera.look_at(Vector3(0,0,-1.3))
	level.camera.size = 18.0
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/villa.png")
	level.free()
	print("VILLA POLISH CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/villa_polish_%s.png" % label)
