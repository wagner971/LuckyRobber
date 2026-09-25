extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var args := OS.get_cmdline_user_args()
	var suffix := "before" if args.has("--before") else ("strong" if args.has("--strong") else ("off" if args.has("--off") else ("no_shader" if args.has("--no-shader") else ("no_glow" if args.has("--no-glow") else ("no_adjust" if args.has("--no-adjust") else ("linear" if args.has("--linear") else "after"))))))
	for location in (["apartment", "laboratory"] if args.has("--quick") else ["apartment", "laboratory", "pyramid", "castle"]):
		var game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/scene_polish_profile.json")
		game.store.session_only = true
		game.store.data.tutorial_completed = true
		game.store.data.noise_tutorial_completed = true
		game.store.data.first_job_at = 1
		game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
		game.store.data.museum_final_job_completed = true
		root.add_child(game)
		game.start_run(location)
		if args.has("--off"):
			game.level.set_visual_polish(false)
			game.ui.set_scene_polish(location, false)
		if args.has("--no-shader"): game.ui.set_scene_polish(location, false)
		if args.has("--strong"):
			var material := game.ui.scene_polish.material as ShaderMaterial
			material.set_shader_parameter("beam_strength", 0.12)
			material.set_shader_parameter("edge_strength", 0.25)
		if args.has("--no-glow"): game.level.scene_environment.glow_enabled = false
		if args.has("--no-adjust"): game.level.scene_environment.adjustment_enabled = false
		if args.has("--linear"): game.level.scene_environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		game.run.set_physics_process(false)
		game.level.player.set_physics_process(false)
		await create_timer(0.16).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/scene_polish_%s_%s.png" % [location, suffix])
		game.free()
		await process_frame
	print("SCENE POLISH %s CAPTURE COMPLETE" % suffix)
	quit()
