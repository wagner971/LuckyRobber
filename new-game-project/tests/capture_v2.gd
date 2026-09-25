extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/v2_" + label + ".png")

func capture() -> void:
	LocalLog.enabled = false
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/visual_v2_profile.json")
	root.add_child(main)
	await shot("fresh_menu")
	main.action("shop")
	await shot("shop")
	main.store.data.upgrades.grip = 4
	main.store.data.upgrades.carry = 4
	main.action("shop")
	await shot("tier_cap")
	main.store.data.upgrades = {"strength":5,"grip":20,"carry":20,"capacity":20,"noise":20}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	main.start_run("museum")
	main.run.set_physics_process(false)
	await shot("safe")
	main.run.phase = RunManager.Phase.ACTIVE
	main.run.current_noise = main.run.alarm_threshold * 0.76
	await shot("warning")
	main.run.current_noise = main.run.alarm_threshold - 1
	main.run.target = main.level.items[0]
	main.run.target.state = LootItem.State.PICKING_UP
	main.run.commit_pickup()
	await shot("alarm")
	main.run.carried = null
	main.level.player.position = main.level.van.load_position
	await shot("escape")
	root.size = Vector2i(450,1000)
	await shot("alarm_9x20")
	main.action("pause")
	await shot("pause")
	main.action("abandon")
	main.action("shop")
	await shot("max_shop")
	var scroll = main.ui.menu.get_child(0).get_child(0)
	scroll.scroll_vertical = 1500
	await shot("max_noise")
	print("V2 VISUAL CAPTURES COMPLETE")
	quit()
