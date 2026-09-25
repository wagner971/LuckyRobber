extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/onboarding_v2_visual_profile.json")
	game.store.session_only = true
	root.add_child(game)
	game.start_tutorial()
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	game.ui.update_run(game.run, 0)
	await save_frame("res://tests/onboarding_v2_move_450x800.png")
	game.run.onboarding.advance(Onboarding.Step.GET_FIRST_ITEM)
	game.ui.update_run(game.run, 0)
	await save_frame("res://tests/onboarding_v2_tv_450x800.png")
	root.size = Vector2i(720, 1280)
	game.ui.update_run(game.run, 0)
	await save_frame("res://tests/onboarding_v2_tv_720x1280.png")
	game.free()
	print("ONBOARDING V2 CAPTURES COMPLETE")
	quit()

func save_frame(path: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
