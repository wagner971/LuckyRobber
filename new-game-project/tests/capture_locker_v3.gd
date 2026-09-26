extends SceneTree

# QA: renders the Locker at 720x1280 (top and scrolled to the collection) and 450x800.
func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/locker_v3_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.first_job_at = 1
	game.store.data.wallet = 9640
	game.store.data.diamonds = 19
	game.store.data.cosmetics.owned = ["suit_plum", "van_mint", "vehicle_black"]
	game.store.data.cosmetics.equipped.van = "vehicle_black"
	root.add_child(game)
	game.action("cosmetics")
	for i in range(10): await process_frame
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/locker_v3_top.png")
	game.ui.locker_scroll.scroll_vertical = 880
	for i in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/locker_v3_collection.png")
	root.size = Vector2i(450, 800)
	game.action("cosmetics")
	for i in range(10): await process_frame
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/locker_v3_narrow.png")
	game.free()
	print("LOCKER V3 CAPTURE COMPLETE")
	quit()
