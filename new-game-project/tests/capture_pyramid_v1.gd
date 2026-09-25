extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/visual_pyramid_profile.json")
	main.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 19, "noise": 1}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(main)
	main.start_run("pyramid")
	main.run.set_physics_process(false)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/pyramid_v1.png")
	main.action("abandon")
	print("PYRAMID CAPTURE COMPLETE")
	quit()
