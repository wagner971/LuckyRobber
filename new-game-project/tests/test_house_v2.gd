extends SceneTree

func _initialize() -> void:
	call_deferred("test")

func test() -> void:
	var failures := 0
	var level := HeistLevel.new()
	root.add_child(level)
	level.setup("house", 7)
	var kinds: Array[String] = []
	var unique_kinds := {}
	var placed := {}
	for item in level.items:
		kinds.append(item.data.type_id)
		unique_kinds[item.data.type_id] = true
		placed[item.data.type_id] = item
	if kinds.size() != 8 or kinds.size() != unique_kinds.size():
		printerr("FAIL: House loot types repeat")
		failures += 1
	else: print("PASS: Eight distinct House loot types")
	for expected in ["small_tv", "tool_cabinet", "bathtub", "sofa", "fridge", "toilet", "rubber_duck", "chair"]:
		if not kinds.has(expected):
			printerr("FAIL: Missing " + expected)
			failures += 1
	if kinds.has("small_safe") or kinds.has("monitor") or kinds.has("printer") or kinds.has("golden_bust"):
		printerr("FAIL: Removed loot remains in House")
		failures += 1
	if Balance.TROPHIES.has("bust") or Balance.TROPHIES.get("duck", {}).get("type_id", "") != "rubber_duck" or placed.rubber_duck.trophy_id != "duck":
		printerr("FAIL: House trophy is not the bathroom duck")
		failures += 1
	if Balance.CONTRACTS["house.client_order"].order.get("rubber_duck", 0) != 1:
		printerr("FAIL: House client order still requests the bust")
		failures += 1
	if Balance.LOCATIONS.house.special != "sofa" or Balance.CONTRACTS["house.client_order"].order.get("sofa", 0) != 1:
		printerr("FAIL: House goals still point to removed loot")
		failures += 1
	if placed.has("rubber_duck") and not (placed.rubber_duck.position.x < -4.0 and placed.rubber_duck.position.z < -2.0):
		printerr("FAIL: Duck is not in the bathroom")
		failures += 1
	if placed.has("toilet") and not (placed.toilet.position.x > -1.0 and placed.toilet.position.z < -3.5 and is_equal_approx(placed.toilet.model.rotation.y, -PI / 2)):
		printerr("FAIL: Toilet is not against the bathroom right wall, facing left")
		failures += 1
	if placed.has("small_tv") and not (placed.small_tv.position.z < -2.0 and absf(placed.small_tv.position.x - placed.sofa.position.x) < 0.3):
		printerr("FAIL: TV does not face the sofa")
		failures += 1
	if placed.has("fridge") and placed.fridge.position.x < 3.5:
		printerr("FAIL: Fridge has not moved to the kitchen right side")
		failures += 1
	var has_rear_wall := false
	var has_parked_car := false
	var has_kitchen_lower_wall := false
	var has_lounge_divider := false
	for rect in level.walls:
		if absf(rect.position.y + 7.85) < 0.15 and rect.size.x > 10: has_rear_wall = true
		if rect.has_point(Vector2(-3.16, 5.14)): has_parked_car = true
		if rect.has_point(Vector2(3.2, 0.4)): has_kitchen_lower_wall = true
		if rect.has_point(Vector2(3.2, -1.6)): has_lounge_divider = true
	if not has_rear_wall or not has_parked_car or not level.has_node("SuburbanHouseArt"):
		printerr("FAIL: Long House or garage car missing")
		failures += 1
	if has_kitchen_lower_wall or not has_lounge_divider:
		printerr("FAIL: Wrong kitchen wall removed")
		failures += 1
	print("HOUSE V2: %d failures" % failures)
	level.free()
	quit(1 if failures else 0)
