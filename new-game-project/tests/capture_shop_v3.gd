extends SceneTree

# QA: renders the Upgrades page in the Bungee/Lilita layout at 720x1280 and 450x800.
func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/shop_v3_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.wallet = 2640
	game.store.data.diamonds = 19
	root.add_child(game)
	game.action("shop")
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/shop_v3.png")
	root.size = Vector2i(450, 800)
	game.action("shop")
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/shop_v3_narrow.png")
	game.free()
	print("SHOP V3 CAPTURE COMPLETE")
	quit()
