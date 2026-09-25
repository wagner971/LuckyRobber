extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func shot(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/v1_" + name + ".png")

func capture() -> void:
	LocalLog.enabled = false
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/visual_v1_profile.json")
	root.add_child(main)
	await shot("fresh_menu")
	main.action("shop")
	await shot("shop")
	main.store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 20, "noise": 20}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	for location in Balance.LOCATION_ORDER:
		main.start_run(location)
		await shot(location)
	main.store.data.objectives.museum.cash = true
	main.store.data.objectives.museum.signature = true
	main.ui.contracts_page(main.store, "museum")
	await shot("contracts")
	main.start_run("museum", "client_order")
	await shot("contract_hud")
	main.run.set_physics_process(false)
	main.run.phase = RunManager.Phase.ACTIVE
	main.run.target = main.level.items[0]
	main.run.target.state = LootItem.State.PICKING_UP
	main.run.commit_pickup()
	await shot("artifact_carry")
	main.run.abandon()
	await shot("contract_result")
	main.store.data.wallet = 40000
	main.store.purchase_cosmetic("set_midnight", true, 0)
	main.store.equip_cosmetic("set_midnight", true)
	main.action("cosmetics")
	await shot("cosmetics")
	main.start_run("apartment")
	await shot("cosmetic_applied")
	main.action("locations")
	main.store.data.trophies = Balance.TROPHIES.keys()
	main.ui.collection(main.store)
	await shot("trophies")
	root.size = Vector2i(450, 1000)
	main.start_run("museum", "small_van")
	await shot("portrait_9x20")
	main.action("pause")
	await shot("pause_9x20")
	main.action("abandon")
	await shot("result_9x20")
	for location in Balance.LOCATION_ORDER:
		for id in Balance.OBJECTIVE_IDS: main.store.data.objectives[location][id] = true
	for id in Balance.CONTRACTS: main.store.data.contracts[id] = true
	Progression.refresh(main.store.data)
	main.action("locations")
	await shot("mastery_complete")
	print("V1 VISUAL CAPTURES COMPLETE")
	quit()

