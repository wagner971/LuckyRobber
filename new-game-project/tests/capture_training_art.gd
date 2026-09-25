extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/training_art_visual.json")
	game.store.session_only = true
	root.add_child(game)
	game.start_tutorial()
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	await shot("entrance")
	game.run.onboarding.advance(Onboarding.Step.GET_FIRST_ITEM)
	await shot("tv")
	game.level.player.position = Vector3(1.1,0,0.55)
	game.run.onboarding.advance(Onboarding.Step.GET_SECOND_ITEM)
	await shot("workbench")
	game.level.player.position = Vector3(0,0,3.65)
	await shot("van")
	root.size = Vector2i(320,712)
	game.level.player.position = Vector3(-1.9,0,2.15)
	game.run.onboarding.advance(Onboarding.Step.MOVE)
	await shot("narrow")
	game.free()
	print("TRAINING ART CAPTURE COMPLETE")
	quit()

func shot(label: String) -> void:
	await create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/training_art_%s.png" % label)
