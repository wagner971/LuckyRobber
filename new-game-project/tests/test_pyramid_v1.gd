extends "res://tests/route_harness.gd"

# Pyramid (Chapter 2) is verified backward from its Final Job budget:
# loot -> cargo -> noise -> alarm trigger -> final route -> measured time.
const SMART_ROUTE = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # Kept for Castle's inherited route; Pyramid uses the better throne-first finish below.
const THRONE_FIRST_PAIR = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 9] # Pyramid: deep Throne trips alarm, then the lone Sarcophagus near the exit.
const GREEDY_ROUTE = [9, 10, 0, 1, 2, 3, 4, 5, 6, 7, 8] # Big prizes first: alarm long before the end.
var loc = "pyramid"
var summary_name = "PYRAMID V1"
var alarm_remaining = -1.0
var alarm_loaded = -1

func _initialize() -> void: call_deferred("test")

func profile_with(upgrades: Dictionary) -> SaveStore:
	var profile = SaveStore.new("res://tests/pyramid_v1_profile.json")
	profile.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	profile.data.upgrades = upgrades.duplicate()
	return profile

func new_session(location: String, mode: String = "normal", profile: SaveStore = null) -> void:
	await super.new_session(location, mode, profile)
	alarm_remaining = -1.0
	alarm_loaded = -1
	run.feedback.connect(func(kind: String, _message: String):
		if kind == "alarm":
			alarm_remaining = run.remaining
			alarm_loaded = run.cargo.size()
	)

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 16
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	test_budget()
	test_progression()
	await test_alarm_math()
	await test_layout()
	await test_routes_measured()
	var output = FileAccess.open("res://tests/%s_v1_measurements.json" % loc, FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks": checks, "failures": failures, "routes": measurements}, "\t", true, true))
	output.close()
	print("%s SUMMARY: %d checks, %d failures" % [summary_name, checks, failures])
	quit(1 if failures else 0)

func test_budget() -> void:
	var config: Dictionary = Balance.LOCATIONS.pyramid
	check(Balance.LOCATION_ORDER.find("pyramid") == Balance.LOCATION_ORDER.find("museum") + 1, "Pyramid comes right after Museum")
	check(Balance.totals("pyramid") == {"cargo": 50, "value": 10500}, "Pyramid exactly 50 cargo / $10500")
	check(config.expected_cargo == 50 and config.expected_value == 10500 and config.items.size() == 11, "Expected totals and 11 loot instances")
	check(Balance.van_capacity(Balance.required_level("capacity", "pyramid")) >= config.expected_cargo and Balance.van_capacity(Balance.required_level("capacity", "museum")) < config.expected_cargo, "Fits Van L19, below Van MAX 46, no new upgrade")
	check(is_equal_approx(Balance.location_noise("pyramid"), 100.0) and is_equal_approx(Balance.alarm_threshold("pyramid"), 65.0), "100 base Noise, fixed 65 alarm threshold")
	check(config.duration == 60 and Balance.ALARM_WINDOW == 12.0 and Balance.session("pyramid", "normal", {"capacity": 19}).alarm_window == 13.0, "Normal 60s timer and a 13s Pyramid escape window; global alarm remains 12s")
	var rest = 0.0
	for row in config.items:
		if row[1] not in ["golden_throne", "sarcophagus"]: rest += Balance.NOISE[Balance.ITEMS[row[1]].weight_class]
	check(is_equal_approx(rest, 64.0), "Everything but Throne + Sarcophagus = 64 Noise, one under the alarm")
	check(Balance.ITEMS.pharaoh_bust.weight_class == "MEDIUM" and Balance.ITEMS.pharaoh_bust.cargo_space == 5, "Pharaoh Bust is MEDIUM on purpose")
	var ratio = float(Balance.totals("pyramid").value) / float(Balance.totals("museum").value)
	check(ratio > 1.05 and ratio < 1.15, "Pyramid pays a little more than the redesigned Museum finale (x%.3f)" % ratio)
	check(config.special == "sarcophagus" and Balance.ITEMS.sarcophagus.cash_value == 1800, "Signature is the $1800 Sarcophagus")

func test_progression() -> void:
	var museum_loadout := {}
	for key in Balance.UPGRADE_KEYS: museum_loadout[key] = Balance.required_level(key, "museum")
	var profile = profile_with(museum_loadout)
	profile.data.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("pyramid"))
	profile.data.apartment_final_job_completed = true
	for location in Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("museum")):
		profile.data.objectives[location].cash = true
		profile.data.objectives[location].signature = true
	profile.data.objectives.museum.cash = true
	Progression.refresh(profile.data)
	check(not profile.unlocked("pyramid"), "One Museum objective keeps Pyramid locked")
	profile.data.objectives.museum.signature = true
	Progression.refresh(profile.data)
	check(not profile.unlocked("pyramid") and Progression.museum_final_job_unlocked(profile.data), "Two Museum objectives offer Final Job but keep Chapter 2 locked")
	Progression.settle(profile.data, "museum", "FINAL_JOB", {"museum_artifact":1,"time_machine":1}, [], 9700, true, 64.0)
	check(profile.unlocked("pyramid") and profile.data.museum_final_job_completed, "Museum Final Job with Time Machine opens Pyramid")
	check(Balance.purchase_cap("capacity", profile.data) == Balance.TIER_CAPS.capacity[7] and Balance.purchase_cap("strength", profile.data) == Balance.TIER_CAPS.strength[7], "Pyramid tier opens its own Strength and Van caps")
	check(Progression.next_goal(profile.data).contains("PYRAMID") or Progression.next_goal(profile.data).contains("SARCOPHAGUS"), "Next goal points at Pyramid: " + Progression.next_goal(profile.data))
	var restored = SaveStore.new("res://tests/pyramid_v1_profile.json")
	profile.save_progress()
	restored.load_progress()
	check(restored.data.unlocked.has("pyramid") and restored.data.objectives.has("pyramid"), "Pyramid unlock and objectives survive reload")
	check(not Balance.CONTRACTS.has("pyramid.rush"), "Pyramid has no mastery contracts; Laboratory supplies three new medals")

func test_alarm_math() -> void:
	for noise_level in [1, 20]:
		var upgrades = {"strength": Balance.max_level("strength"), "grip": 20, "carry": 20, "capacity": 19, "noise": noise_level}
		for pair_order in [[9, 10], [10, 9]]:
			await new_session(loc, "normal", profile_with(upgrades))
			begin()
			for i in range(9):
				# Stand at the harness approach point so no neighbouring piece is lifted instead.
				run.cancel_interaction()
				world.player.position = approach_point(world.items[i])
				tick(3.0)
				world.player.position = world.van.load_position
				tick(0.4)
			var before = run.current_noise
			check(not run.alarm_active and before < run.alarm_threshold, "Noise L%d: 64-noise loot stays under alarm (%.2f / %.0f)" % [noise_level, before, run.alarm_threshold])
			world.player.position = approach_point(world.items[pair_order[0]])
			tick(4)
			check(run.alarm_active and run.remaining <= run.alarm_window and alarm_loaded == 9, "Noise L%d: %s trips the alarm as penultimate big piece (%.2f)" % [noise_level, world.items[pair_order[0]].data.display_name, run.current_noise])

func test_layout() -> void:
	await new_session(loc, "normal", profile_with(MAXED))
	for item in world.items:
		check(item.model.get_child_count() > 0, "Visible model " + item.data.type_id)
		check(world.valid_drop(item.position, float(item.data.radius)), "Loot clear of walls " + item.instance_id_in_run)
		check(approach_point(item) != Vector3.INF, "Reachable approach " + item.instance_id_in_run)
	var sarcophagus: LootItem = world.items[9]
	var throne: LootItem = world.items[10]
	var path = func(item: LootItem) -> float:
		var lane = -1.15 if item.position.x < 0 else 1.15
		return Vector2(lane, 2.4).distance_to(Vector2(0, 3.6)) + (2.4 - item.position.z) + absf(item.position.x - lane)
	var near: float = path.call(sarcophagus)
	check(sarcophagus.position.x < -2.5 and sarcophagus.position.z > 1.3 and near <= 5.0, "Sarcophagus remains near the left exit (%.2f)" % near)
	await test_lighting()
	check(absf(throne.position.x) < 0.5 and throne.position.z <= -3.5 and path.call(throne) <= 9.5, "Throne sits at the very back on the room axis (%.2f)" % path.call(throne))
	var mask: LootItem = world.items[4]
	var scarab: LootItem = world.items[5]
	check(mask.position.x < -1.7 and scarab.position.x > 1.7 and absf(mask.position.z - throne.position.z) <= 0.8 and absf(scarab.position.z - throne.position.z) <= 0.8, "Mask and Scarab flank the rear Throne")
	var anubis: LootItem = world.items[6]
	check(anubis.position.x < -3.0 and anubis.position.distance_to(sarcophagus.position) < 2.3, "Anubis stands beside the Sarcophagus in the left alcove")
	for i in [2, 3]:
		check(absf(world.items[i].position.x) <= 0.9 and world.items[i].position.z > 0.0, "Treasure chest remains in central paired display: " + world.items[i].instance_id_in_run)

func measure(label: String, upgrades: Dictionary, order: Array) -> Dictionary:
	await new_session(loc, "normal", profile_with(upgrades))
	var ok = await drive_indices(order, label)
	var entry: Dictionary = measurements.back()
	# "cleared" is the physical result; the career full_clear flag also needs the tier loadout.
	entry.merge({"remaining": snappedf(run.remaining, 0.01), "alarm_remaining": snappedf(alarm_remaining, 0.01), "loaded_at_alarm": alarm_loaded, "full_clear": run.result.get("full_clear", false), "cleared": run.result.get("success", false) and run.standard_cargo_count() == world.items.size()})
	print(loc.to_upper() + " %s: success=%s full_clear=%s remaining %.2fs | alarm with %d loaded, %.2fs left" % [label, ok, entry.full_clear, run.remaining, alarm_loaded, alarm_remaining])
	return entry

func test_routes_measured() -> void:
	var base = {"strength": Balance.max_level("strength"), "grip": 1, "carry": 1, "capacity": 19, "noise": 1}
	var target = await measure("pyramid.harness_no_speed", base, THRONE_FIRST_PAIR)
	check(target.cleared, "Full clear possible without speed upgrades (S5 G1 C1 V19 N1)")
	check(target.remaining >= 4.5, "Physical full clear has a playable >=4.5s margin without speed upgrades (%.2fs)" % target.remaining)
	check(target.loaded_at_alarm == 9, "Alarm fires only once 9/11 pieces (~80%% of the heist) are loaded")
	var alt = await measure("pyramid.sarcophagus_first_pair", base, SMART_ROUTE)
	check(alt.cleared or alt.remaining < target.remaining, "Sarcophagus-first finish is harder than the central Throne-first route (%.2fs left)" % alt.remaining)
	var greedy = await measure("pyramid.greedy_prizes_first", base, GREEDY_ROUTE)
	check(not greedy.cleared and greedy.loaded_at_alarm < 9, "Grabbing both big prizes first triggers an early alarm and costs the full clear")
	var helped = await measure("pyramid.grip8_carry8", {"strength": Balance.max_level("strength"), "grip": 8, "carry": 8, "capacity": 19, "noise": 1}, THRONE_FIRST_PAIR)
	check(helped.cleared and helped.remaining > target.remaining, "A few Grip/Carry levels buy extra seconds (%.2fs)" % helped.remaining)
	var maxed = await measure("pyramid.max", MAXED, THRONE_FIRST_PAIR)
	check(maxed.full_clear and maxed.remaining >= 5.5 and maxed.remaining > helped.remaining, "MAX clears with >=5.5s and the largest margin (%.2fs)" % maxed.remaining)

# Dark tomb, torch-lit: every walkable interior spot and every loot piece sits well inside
# a torch's reach, and the sun never lights the interior layer.
func test_lighting() -> void:
	# Every torch shows a flame; only some emit real light. Room fills count as coverage too.
	var lights: Array = []
	for entry in world.torches:
		if entry.light != null: lights.append(entry.light)
	check(world.torches.size() >= 16, loc + " has %d visible torches (%d emit real light)" % [world.torches.size(), lights.size()])
	lights.append_array(world.fill_lights)
	var sun: DirectionalLight3D
	for child in world.get_children():
		if child is DirectionalLight3D: sun = child
	if loc == "castle":
		# Lighting Pass V1: one weak global moonlight reaches inside for cool shape.
		check(sun != null and (sun.light_cull_mask & HeistLevel.INTERIOR_LAYER) and sun.light_energy <= 0.8, "One weak global moonlight (%.2f) shapes the whole castle" % sun.light_energy)
	else:
		check(sun != null and not (sun.light_cull_mask & HeistLevel.INTERIOR_LAYER), "Sun skips the interior layer: inside stays dark")
	var reach = func(point: Vector3) -> float:
		var best = INF
		for light in lights:
			if light.light_cull_mask & HeistLevel.INTERIOR_LAYER:
				best = minf(best, Vector2(point.x, point.z).distance_to(Vector2(light.global_position.x, light.global_position.z)) / (light.omni_range if light is OmniLight3D else light.spot_range))
		return best
	var worst = 0.0
	var worst_point = Vector3.ZERO
	var samples = 0
	for x in range(-48, 49, 3):
		for z in range(-52, 32, 3):
			var point = Vector3(x / 10.0, 0, z / 10.0)
			if not world.inside(point) or not world.valid_drop(point, 0.1): continue
			samples += 1
			var r: float = reach.call(point)
			if r > worst:
				worst = r
				worst_point = point
	check(samples > 150 and worst <= 0.75, "Every interior spot within 75%% of a torch's range (%d samples, worst %.2f at %s)" % [samples, worst, worst_point])
	for item in world.items:
		check(reach.call(item.position) <= 0.7, "Loot lit by a torch " + item.instance_id_in_run)
		check(first_visual(item).layers == HeistLevel.INTERIOR_LAYER, "Loot inside uses the interior layer " + item.instance_id_in_run)
	world.player.position = Vector3(0, 0, 1.0)
	world.update_dynamic_layers()
	check(first_visual(world.player).layers == HeistLevel.INTERIOR_LAYER, "Thief switches to the interior layer inside")
	world.player.position = Vector3(0, 0, 3.65)
	world.update_dynamic_layers()
	check(first_visual(world.player).layers == 1, "Thief is sunlit again outside the breach")

func first_visual(node: Node) -> VisualInstance3D:
	for child in node.get_children():
		if child is VisualInstance3D: return child
		var found = first_visual(child)
		if found != null: return found
	return null
