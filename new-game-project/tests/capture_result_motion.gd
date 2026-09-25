extends "res://tests/capture_results_v1.gd"
func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450,800)
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/results_motion_capture_profile.json")
	main.store.session_only = true
	main.store.data.tutorial_completed = true
	root.add_child(main)
	main.store.data.wallet = 9700
	main.store.data.diamonds = 70
	var failed := OS.get_cmdline_user_args().has("--failed")
	main.ui.results(sample({"success":not failed,"earned":0 if failed else 530,"lost":2350 if failed else 0,"items":5,"elapsed":22.0,"alarm_triggered":failed}),main.store,"apartment")
	var folder := "res://tests/failure_motion_frames" if failed else "res://tests/result_motion_frames"
	DirAccess.make_dir_recursive_absolute(folder)
	for i in 64:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(folder+"/frame_%03d.png" % i)
		await create_timer(1.0/16.0).timeout
	main.free()
	print("RESULT MOTION CAPTURE COMPLETE")
	quit()
