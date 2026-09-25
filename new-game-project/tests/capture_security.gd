extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(path: String) -> void:
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/security_visual.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.successes = 4
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(game)
	for location in SecurityPatrol.LOCATIONS:
		game.action("locations")
		game.start_run(location)
		game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		game.run.phase = RunManager.Phase.ACTIVE
		game.level.player.position = Vector3(0,0,-1.0)
		game.level.security.clock = 4
		game.level.security.move_sensors(0.1)
		game.level.security.refresh_cones(false)
		await shot("res://tests/security_"+location+".png")
		if location == "electronics":
			var sensor: Dictionary = game.level.security.sensors[0]
			for frame in range(70):
				var pivot: Node3D = sensor.pivot
				game.level.player.position = Vector3(pivot.position.x,0,pivot.position.z)+Vector3(sin(pivot.rotation.y),0,cos(pivot.rotation.y))*1.2
				game.level.security.tick(1.0/60,game.run)
			await shot("res://tests/security_suspicion.png")
			for frame in range(60):
				game.level.security.tick(1.0/60,game.run)
			await shot("res://tests/security_spotted.png")
	game.free()
	print("SECURITY CAPTURES COMPLETE")
	quit()
