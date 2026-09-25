extends SceneTree

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/menu_motion_profile.json")
	game.store.session_only = true
	game.store.data.wallet = 1250
	game.store.data.cosmetics.owned = ["set_midnight","suit_plum","van_mint"]
	root.add_child(game)
	await process_frame
	game.ui.set_previews_active(true)
	var preview = get_nodes_in_group("menu_character_previews")[0]
	preview.set_process(false)
	DirAccess.make_dir_recursive_absolute("res://tests/menu_frames")
	for frame in range(75):
		if frame == 25: game.store.equip_cosmetic("set_midnight",true)
		if frame == 50:
			game.store.equip_cosmetic("van_mint",true)
			game.store.equip_cosmetic("suit_plum",true)
		preview._process(1.0/25.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/menu_frames/frame_%03d.png" % frame)
	game.free()
	print("LIVE MENU MOTION CAPTURE COMPLETE")
	quit()
