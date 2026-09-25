extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/location_identity_" + label + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/visual_location_identity_profile.json")
	main.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 20, "noise": 20}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	root.add_child(main)
	main.start_run("apartment")
	main.run.set_physics_process(false)
	await shot("apartment")
	main.action("abandon")
	main.start_run("house")
	main.run.set_physics_process(false)
	await shot("house")
	main.action("abandon")
	print("LOCATION IDENTITY CAPTURES COMPLETE")
	quit()
