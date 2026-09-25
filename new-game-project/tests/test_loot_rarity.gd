extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition: failures += 1
	print(("PASS " if condition else "FAIL ") + label)

func run_test() -> void:
	LocalLog.enabled = false
	var counts := {"RARE": 0, "EPIC": 0, "LEGENDARY": 0, "NONE": 0}
	for i in range(1000):
		var choice := LootRarity.choose("apartment", (float(i) + 0.5) / 1000.0)
		counts["NONE" if choice.is_empty() else choice.tier] += 1
	check(counts == {"RARE": 150, "EPIC": 40, "LEGENDARY": 10, "NONE": 800}, "Exact 15/4/1 percent run chances")
	check(LootRarity.all_ids().size() == Balance.LOCATION_ORDER.size() * 3, "Three curated discoveries per location")
	for location in Balance.LOCATION_ORDER:
		for tier in LootRarity.TIERS:
			var choice := LootRarity.variant(location + "_" + tier.to_lower())
			check(not choice.is_empty() and LootRarity.base_type(choice) != "", "Valid replacement: " + location + " " + tier)
	var base := LootItem.new()
	root.add_child(base)
	base.setup("small_tv", "apartment.tv_a")
	check(base.rarity_marker == null, "Normal loot has no rarity VFX")
	var physical := base.data.duplicate(true)
	base.apply_rarity(LootRarity.variant("apartment_rare"))
	check(base.data.type_id == physical.type_id and base.data.cargo_space == physical.cargo_space and base.data.weight_class == physical.weight_class and base.data.required_strength == physical.required_strength, "Replacement preserves cargo, weight, Strength and type")
	check(base.data.cash_value == 600 and base.data.display_name == "GILDED TV", "Replacement updates value and identity")
	check(is_instance_valid(base.rarity_marker), "Rarity is visible in the world")
	var visual := base.rarity_marker
	check(visual.meshes.size() > 0 and visual.meshes[0].material_overlay == visual.surface, "Rim and sweep cover the rare model")
	visual.elapsed = 0.22
	visual.update_visual(0, false, true, false)
	check(float(visual.surface.get_shader_parameter("sweep_visible")) > 0.9, "A narrow sweep appears inside its short window")
	visual.update_visual(0.7, false, true, false)
	check(float(visual.surface.get_shader_parameter("sweep_visible")) == 0, "Sweep ends instead of flashing continuously")
	var stopped_at := visual.elapsed
	visual.update_visual(1, true, true, true)
	check(visual.elapsed == stopped_at, "Pause freezes the visual clock")
	visual.update_visual(0.2, true, true, false)
	check(visual.proximity > 0.9, "Approaching softly increases the rim")
	visual.update_visual(0, false, false, false)
	check(not visual.visible and visual.meshes[0].material_overlay == null, "Pickup removes the floor glow and extra rendering pass")
	visual.update_visual(0, false, true, false)
	check(visual.visible and visual.meshes[0].material_overlay == visual.surface, "Dropped rare loot restores its effect")
	var old_save := SaveStore.new().defaults()
	old_save.schema_version = 12
	old_save.wallet = 420
	var clean := SaveStore.new().validate(old_save)
	check(clean.schema_version == 13 and clean.wallet == 420 and clean.rare_loot.is_empty(), "Existing saves migrate with money intact")
	var found := SaveStore.new().defaults()
	found.rare_loot = ["apartment_rare", "apartment_rare", "unknown"]
	check(SaveStore.new().validate(found).rare_loot == ["apartment_rare"], "Collection validates persistent discoveries")
	var level := HeistLevel.new()
	root.add_child(level)
	level.setup("apartment", 1)
	var store := SaveStore.new("res://tests/rarity_profile.json")
	store.session_only = true
	var run := RunManager.new()
	root.add_child(run)
	run.setup(level, store, "apartment", "normal")
	run.set_physics_process(false)
	var collectible: LootItem = level.items[0]
	if collectible.rare_id == "": collectible.apply_rarity(LootRarity.variant("apartment_rare"))
	run.cargo.append(collectible)
	run.cargo_used = int(collectible.data.cargo_space)
	run.cargo_value = int(collectible.data.cash_value)
	run.phase = RunManager.Phase.ACTIVE
	run.finish(true)
	check(store.data.rare_loot == [collectible.rare_id] and run.result.new_rare_loot == [collectible.rare_id], "Escape permanently records the replaced slot")
	check(run.result.loot_types == ["small_tv"] and run.result.items == 1 and not run.result.full_clear, "Objectives still count the original slot")
	var ui := GameUI.new()
	root.add_child(ui)
	ui.collection(store)
	check(is_instance_valid(ui.menu), "Collection renders a discovered rare model")
	var failed_store := SaveStore.new("res://tests/rarity_failed_profile.json")
	failed_store.session_only = true
	var failed := RunManager.new()
	root.add_child(failed)
	failed.setup(level, failed_store, "apartment", "normal")
	failed.set_physics_process(false)
	failed.cargo.append(collectible)
	failed.cargo_value = int(collectible.data.cash_value)
	failed.phase = RunManager.Phase.ACTIVE
	failed.finish(false)
	check(failed_store.data.rare_loot.is_empty(), "Busted run never unlocks rare loot")
	var final_level := HeistLevel.new()
	root.add_child(final_level)
	final_level.setup("apartment", 6)
	var final_run := RunManager.new()
	root.add_child(final_run)
	final_run.setup(final_level, store, "apartment", "FINAL_JOB")
	final_run.set_physics_process(false)
	var final_has_rarity := false
	for item in final_level.items:
		if item.rare_id != "": final_has_rarity = true
	check(not final_has_rarity, "Final Job uses standard slots only")
	base.queue_free()
	print("RARITY CHECKS %d; FAILURES %d" % [checks, failures])
	quit(0 if failures == 0 else 1)
