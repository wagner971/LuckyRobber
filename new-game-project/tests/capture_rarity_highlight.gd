extends SceneTree

func _initialize() -> void: call_deferred("capture")

func shot(label: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/rarity_highlight_" + label + ".png")

func capture() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var world := HeistLevel.new()
	root.add_child(world)
	world.setup("apartment", 6)
	var store := SaveStore.new()
	store.session_only = true
	store.data.upgrades = {"strength": 5, "grip": 5, "carry": 5, "capacity": 6, "noise": 5}
	var run := RunManager.new()
	root.add_child(run)
	# Fixed baseline for this visual fixture; no random second prop.
	run.setup(world, store, "apartment", "FINAL_JOB")
	run.mode = "normal"
	run.set_physics_process(false)
	world.player.set_physics_process(false)
	var loot: LootItem
	for item in world.items:
		if item.data.type_id == "pink_flamingo": loot = item
	loot.apply_rarity(LootRarity.variant("apartment_legendary"))
	var ui := GameUI.new()
	root.add_child(ui)
	ui.show_run()
	ui.update_run(run, 0)
	await shot("far")
	world.player.global_position = loot.global_position + Vector3(-0.72, 0, 0.25)
	loot.rarity_marker.update_visual(0.25, true, true, false)
	ui.update_run(run, 0)
	await shot("near")
	print("NEAR: ", loot.edge_distance(world.player.global_position), " accessible=", world.accessible(loot), " selected=", run.label_item(), " visible=", ui.guidance.label_panel.visible, " rect=", ui.guidance.label_panel.get_global_rect(), " guidance=", ui.guidance.size)
	for label in [ui.guidance.rarity_label, ui.guidance.name_label, ui.guidance.detail_label, ui.guidance.requirement]: print(label.text, " size ", label.size, " min ", label.get_combined_minimum_size())
	ui.update_run(run, 0)
	await shot("near_settled")
	loot.rarity_marker.elapsed = 0.325
	loot.rarity_marker.update_visual(0, true, true, false)
	await shot("sweep")
	root.size = Vector2i(360, 800)
	await process_frame
	ui.update_run(run, 0)
	await shot("narrow")
	ui.hud.hide()
	world.player.hide()
	world.camera.size = 3.1
	world.camera.position = loot.global_position + Vector3(-2.0, 2.2, 3.5)
	world.camera.look_at(loot.global_position + Vector3(0, 0.6, 0))
	loot.rarity_marker.elapsed = 1.5
	loot.rarity_marker.update_visual(0, true, true, false)
	await shot("detail_idle")
	loot.rarity_marker.elapsed = 0.325
	loot.rarity_marker.update_visual(0, true, true, false)
	await shot("detail_sweep")
	print("RARITY CAPTURES COMPLETE")
	quit()
