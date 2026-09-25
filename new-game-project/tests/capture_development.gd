extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/dev_" + label + ".png")

func capture() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/dev_capture_profile.json")
	game.store.session_only = true
	root.add_child(game)
	await shot("fresh")
	game.action("dev_max")
	await shot("max")
	print("DEV VISUAL COMPLETE")
	quit()
