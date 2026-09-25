extends "res://tests/test_pyramid_v1.gd"

# Dracula's Castle (Chapter 2), verified backward from its budget like Pyramid.
# Rows 0-8 are the 61-Noise loot, row 9 the Vampire Throne (alarm), row 10 the Coffin.

func _initialize() -> void:
	loc = "castle"
	summary_name = "DRACULA'S CASTLE V1"
	call_deferred("test")

func test_budget() -> void:
	var config: Dictionary = Balance.LOCATIONS.castle
	check(Balance.LOCATION_ORDER.find("castle") == Balance.LOCATION_ORDER.find("pyramid") + 1, "Dracula's Castle comes right after Pyramid")
	check(Balance.totals("castle") == {"cargo": 44, "value": 10900}, "Castle exactly 44 cargo / $10900")
	check(config.expected_cargo == 44 and config.expected_value == 10900 and config.items.size() == 11, "Expected totals and 11 loot instances")
	check(is_equal_approx(Balance.location_noise("castle"), 97.0) and is_equal_approx(Balance.alarm_threshold("castle"), 63.05), "97 base Noise, 63.05 alarm threshold")
	check(config.duration == 60 and Balance.session("castle", "normal", {"capacity": 19}).alarm_window == 12.0, "Normal 60s timer and 12s alarm")
	var rest = 0.0
	for row in config.items:
		if row[1] not in ["vampire_throne", "dracula_coffin"]: rest += Balance.NOISE[Balance.ITEMS[row[1]].weight_class]
	check(is_equal_approx(rest, 61.0), "Everything but Throne + Coffin = 61 Noise, under 63.05")
	check(rest * 0.81 + 18.0 * 0.81 >= Balance.alarm_threshold("castle"), "Noise MAX still trips the alarm on the Throne (%.2f)" % (rest * 0.81 + 18.0 * 0.81))
	check(config.items[9][1] == "vampire_throne" and config.items[10][1] == "dracula_coffin", "Route order ends Throne -> Coffin")
	check(Balance.ITEMS.dracula_coffin.cash_value == 2000 and config.special == "dracula_coffin", "Coffin is the $2000 main WTF piece")

func test_progression() -> void:
	var pyramid_loadout := {}
	for key in Balance.UPGRADE_KEYS: pyramid_loadout[key] = Balance.required_level(key, "pyramid")
	var profile = profile_with(pyramid_loadout)
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("castle"))
	profile.data.apartment_final_job_completed = true
	profile.data.museum_final_job_completed = true
	for location in Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("pyramid")):
		profile.data.objectives[location].cash = true
		profile.data.objectives[location].signature = true
	profile.data.objectives.pyramid.cash = true
	Progression.refresh(profile.data)
	check(not profile.unlocked("castle"), "One Pyramid objective keeps the Castle locked")
	check(Progression.next_goal(profile.data).contains("PYRAMID"), "Next goal still points at Pyramid first")
	profile.data.objectives.pyramid.signature = true
	Progression.refresh(profile.data)
	check(profile.unlocked("castle"), "Two Pyramid objectives open Dracula's Castle")
	check(Progression.next_goal(profile.data).contains("DRACULA"), "Next goal moves to the Castle: " + Progression.next_goal(profile.data))
	var only_coffin = Progression.settle(profile.data, "castle", "normal", {"dracula_coffin": 1}, [], 2000, false, 20.0)
	check(not profile.data.objectives.castle.signature and only_coffin.new_objectives.is_empty(), "Coffin alone does not complete objective 2")
	Progression.settle(profile.data, "castle", "normal", {"vampire_throne": 1, "dracula_coffin": 1}, [], 3700, false, 30.0)
	check(profile.data.objectives.castle.signature and not profile.data.objectives.castle.cash, "Throne + Coffin in one run completes objective 2 only")
	Progression.settle(profile.data, "castle", "normal", {}, [], 4000, false, 30.0)
	check(profile.data.objectives.castle.cash, "Escaping with $4000 completes objective 1")

func test_layout() -> void:
	await new_session(loc, "normal", profile_with(MAXED))
	for item in world.items:
		check(item.model.get_child_count() > 0, "Visible model " + item.data.type_id)
		check(world.valid_drop(item.position, float(item.data.radius)), "Loot clear of walls " + item.instance_id_in_run)
		check(approach_point(item) != Vector3.INF, "Reachable approach " + item.instance_id_in_run)
	var path = func(item: LootItem) -> float:
		var lane = -1.15 if item.position.x < 0 else 1.15
		return Vector2(lane, 2.4).distance_to(Vector2(0, 3.6)) + (2.4 - item.position.z) + absf(item.position.x - lane)
	var throne: LootItem = world.items[9]
	var coffin: LootItem = world.items[10]
	check(path.call(coffin) <= 4.0, "Coffin waits in the Crypt next to the breach (%.2f)" % path.call(coffin))
	check(path.call(throne) <= 8.0 and throne.position.z < -2.0, "Throne on the axis near the top wall of a shallow Throne Chamber (%.2f)" % path.call(throne))
	await test_lighting()
	var real = world.torches.filter(func(entry): return entry.light != null).size()
	check(real <= 10 and world.fill_lights.size() == 5, "Lighting pass: %d real torch lights of %d torches, one faint fill per room + moonlit forecourt" % [real, world.torches.size()])
	var directional = 0
	var shadowed = 0
	for node in world.find_children("*", "Light3D", true, false):
		if node is DirectionalLight3D: directional += 1
		elif node.shadow_enabled: shadowed += 1
	check(directional == 1 and shadowed == 0, "Mobile budget: 1 directional moonlight, %d shadowed local lights" % shadowed)
	check(world.contact_blobs.size() >= 7, "Contact shadows under %d big loot pieces" % world.contact_blobs.size())
	for entry in world.contact_blobs:
		check(entry[0] is MeshInstance3D and entry[0].get_child_count() == 0 and entry[0].cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Contact shadow is visual only, no collision")
	for fill in world.fill_lights:
		check(fill.omni_range >= 4.0 and fill.light_energy <= 1.8 and not fill.shadow_enabled, "Room fill is broad and faint")
	for entry in world.torches:
		if entry.light is OmniLight3D and world.inside(entry.light.global_position):
			check(entry.light.omni_range >= 2.0 and entry.light.omni_range <= 3.2 and entry.light.light_energy <= 1.3, "Interior torch is a short, low accent (%.1f)" % entry.light.omni_range)

func test_routes_measured() -> void:
	var base = {"strength": 5, "grip": 1, "carry": 1, "capacity": 19, "noise": 1}
	var target = await measure("castle.harness_no_speed", base, SMART_ROUTE)
	check(target.cleared, "Full clear possible without speed upgrades (S5 G1 C1 V19 N1)")
	check(target.remaining >= 4.0 and target.remaining <= 6.5, "Harness leaves 4-6s after full clear without speed upgrades (%.2fs)" % target.remaining)
	check(target.loaded_at_alarm == 9, "Alarm fires on the Throne, with 9/11 pieces loaded")
	var coffin_first = await measure("castle.coffin_before_throne", base, THRONE_FIRST_PAIR)
	check(coffin_first.remaining < target.remaining, "Coffin before Throne is the harder finish (%.2fs)" % coffin_first.remaining)
	var greedy = await measure("castle.greedy_prizes_first", base, GREEDY_ROUTE)
	check(not greedy.cleared and greedy.loaded_at_alarm < 9, "Grabbing Throne + Coffin first triggers an early alarm and costs the full clear")
	var helped = await measure("castle.grip8_carry8", {"strength": 5, "grip": 8, "carry": 8, "capacity": 19, "noise": 1}, SMART_ROUTE)
	check(helped.cleared and helped.remaining >= target.remaining, "A few Grip/Carry levels buy extra seconds (%.2fs)" % helped.remaining)
	var maxed = await measure("castle.max", MAXED, SMART_ROUTE)
	check(maxed.full_clear and maxed.remaining >= helped.remaining, "MAX clears with the largest margin (%.2fs)" % maxed.remaining)
