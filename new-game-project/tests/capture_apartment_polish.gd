extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/apartment_polish_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.successes = 4
	game.store.data.first_job_at = 1
	root.add_child(game)
	game.start_run("apartment")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.level.player.position = Vector3(-1.3,0,1.6)
	await shot("lounge")
	game.level.player.position = Vector3(-1.1,0,-1.75)
	await shot("kitchen")
	game.level.player.position = Vector3(1.9,0,-1.2)
	await shot("bath")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(0,0,3.65)
	await shot("narrow")
	game.free()
	await process_frame
	root.size = Vector2i(960,800)
	var level = HeistLevel.new()
	root.add_child(level)
	level.setup("apartment",1)
	level.camera.position = Vector3(7,10,15)
	level.camera.look_at(Vector3(0,0,0.65))
	level.camera.size = 11.4
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://assets/ui/jobs/apartment.png")
	level.free()
	print("APARTMENT POLISH CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/apartment_polish_%s.png" % label)
