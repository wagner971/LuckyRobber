extends "res://tests/test_ui_v2.gd"

func test() -> void:
	LocalLog.enabled = false
	var store := SaveStore.new()
	store.session_only = true
	for location in Balance.LOCATION_ORDER:
		var world := HeistLevel.new()
		root.add_child(world)
		world.setup(location, 1)
		check(world.items.all(func(item): return item.loot_highlight == null), location + ": previews have no gameplay highlights")
		var values := []
		for item in world.items: values.append(item.data.duplicate(true))
		var run := RunManager.new()
		root.add_child(run)
		run.set_physics_process(false)
		run.setup(world, store, location, "normal", false)
		while not run.world_prepared: await physics_frame
		var valid := true
		for i in world.items.size():
			var item: LootItem = world.items[i]
			var visual := item.loot_highlight
			valid = valid and visual != null and visual.outline.mesh.get_surface_count() == 1 and visual.outline.visible and item.data == values[i]
		check(valid, location + ": every loot type has a batched visible silhouette; values and physics unchanged")
		var item: LootItem = world.items[0]
		var visual := item.loot_highlight
		visual.update_visual(1, true, true, false)
		check(visual.focus == 1.0, location + ": focus strengthens the contour")
		visual.update_visual(1, false, true, true)
		check(visual.focus == 1.0, location + ": pause freezes focus")
		for state in [LootItem.State.CARRIED, LootItem.State.LOADING, LootItem.State.LOADED]:
			item.state = state
			item.highlight(false)
			check(not visual.visible and not visual.outline.visible and not item.marker.visible, location + ": no lingering marker in state " + str(state))
		item.state = LootItem.State.AVAILABLE
		item.highlight(false)
		check(visual.visible and visual.outline.visible, location + ": dropped loot is readable again")
		item.set_meta("suppress_highlight", true)
		visual.update_visual(0, false, true, false)
		check(not visual.visible and not visual.outline.visible, location + ": Dark Heist suppresses ordinary highlight")
		run.free()
		world.free()
		await process_frame
	# Rare loot keeps its own identity and sweep instead of acquiring the normal color.
	var rare := LootItem.new()
	root.add_child(rare)
	rare.setup("small_tv", "apartment.tv_a")
	rare.apply_rarity(LootRarity.variant("apartment_rare"))
	rare.loot_highlight = LootHighlight.new()
	rare.add_child(rare.loot_highlight)
	rare.loot_highlight.setup(rare)
	check(rare.loot_highlight.accent == LootRarity.COLORS[0] and rare.rarity_marker.meshes[0].material_overlay == rare.rarity_marker.surface, "Rare color and existing sweep preserved")
	rare.set_meta("suppress_highlight", true)
	rare.loot_highlight.update_visual(0, false, true, false)
	check(rare.loot_highlight.visible, "Dark Heist preserves special loot identity")
	rare.loot_highlight.update_visual(0, false, false, false)
	check(not rare.loot_highlight.outline.visible, "Run end removes silhouettes")
	rare.free()
	print("HIGHLIGHT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
