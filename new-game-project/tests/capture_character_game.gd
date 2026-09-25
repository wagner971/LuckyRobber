extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/character_game_" + label + ".png")

func capture() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/character_capture_profile.json")
	game.store.session_only = true
	game.store.data.upgrades = {"strength":5,"grip":20,"carry":20,"capacity":20,"noise":20}
	root.add_child(game)
	game.set_physics_process(false)
	game.start_run("apartment")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.level.player.position = Vector3(0,0,2.4)
	await shot("idle")
	game.run.intention = Vector2.RIGHT
	game.run._physics_process(0.016)
	game.run.intention = Vector2.ZERO
	game.run.target = game.level.items[7]
	game.run.commit_pickup()
	game.level.player.velocity = Vector3(2,0,0)
	game.level.player.visual.rotation.y = 0.3
	for i in range(20): game.level.player._process(0.016)
	await shot("fridge")
	game.free()
	print("IN-GAME CHARACTER CAPTURE COMPLETE")
	quit()

