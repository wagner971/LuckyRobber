extends SceneTree

var checks = 0
var failures = 0
var world: HeistLevel
var run: RunManager
var store: SaveStore

func _initialize() -> void:
	call_deferred("test")

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)
	else: print("PASS: " + description)

func sell_pending() -> void:
	# Legacy helper: loot now banks automatically when the van escapes.
	pass

func create_run(location: String = "apartment", maxed: bool = false) -> void:
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	store = SaveStore.new("res://tests/suite_profile.json")
	if maxed: store.data.upgrades = {"strength": 5, "grip": 20, "carry": 20, "capacity": 20, "noise": 20}
	world = HeistLevel.new()
	root.add_child(world)
	world.setup(location, store.data.upgrades.capacity)
	world.player.set_physics_process(false)
	run = RunManager.new()
	root.add_child(run)
	# Baseline economy/routes use standard loot. Random rewards have their own suites.
	run.setup(world, store, location, "normal", false)
	run.set_physics_process(false)
	await physics_frame
	await physics_frame

func tick(seconds: float) -> void:
	for i in range(ceili(seconds * 60)): run._physics_process(1.0 / 60.0)

func begin() -> void:
	run.intention = Vector2.RIGHT
	tick(0.02)
	run.intention = Vector2.ZERO

func stand_by(item: LootItem) -> void:
	# Furniture can support elevated loot; stand on reachable floor beside it.
	var approach = approach_point(item)
	world.player.position = approach if approach != Vector3.INF else Vector3(item.position.x, 0, item.position.z + float(item.data.radius) + 0.25)

func load_item(item: LootItem) -> void:
	run.cancel_interaction()
	stand_by(item)
	tick(3.0)
	world.player.position = world.van.load_position
	tick(0.4)

func test() -> void:
	LocalLog.enabled = false
	Engine.time_scale = 8
	Engine.physics_ticks_per_second = 480
	Engine.max_physics_steps_per_frame = 64
	await create_run()
	stand_by(world.items[0])
	tick(1.0)
	check(run.phase == RunManager.Phase.READY and run.carried == null and run.remaining == 60, "No clock or collection before intentional movement")
	begin()
	tick(0.2)
	var stable = run.target
	tick(0.1)
	check(stable == run.target and run.progress > 0, "Stable nearest pickup target")
	run.intention = Vector2(0.01, 0.01)
	tick(0.1)
	check(run.progress > 0.3, "Small joystick jitter does not cancel pickup")
	run.intention = Vector2.RIGHT
	tick(0.02)
	check(run.target == null and world.items[0].state == LootItem.State.AVAILABLE and run.progress == 0, "Intentional movement resets pickup")
	run.intention = Vector2.ZERO
	tick(1)
	check(run.carried == world.items[0] and run.carried.get_parent() == world.player.carry_anchor, "One visible carried object")
	check(is_equal_approx(run.movement_factor(run.carried), 0.85), "Medium weight changes carry speed")
	var old = run.carried
	var origin = old.global_position
	check(run.drop(), "DROP finds a valid nearby position")
	check(run.carried == null and old.state == LootItem.State.AVAILABLE and old.global_position.distance_to(origin) < 3, "DROP stays nearby, no cash, no duplicate")
	tick(0.5)
	check(run.carried == null, "Drop grace prevents immediate recollection")
	stand_by(old)
	tick(2)
	check(run.carried == old, "Dropped object can be recollected")
	world.player.position = world.van.load_position
	tick(0.1)
	check(run.carried.state == LootItem.State.LOADING, "Loading has an explicit state")
	run.intention = Vector2.LEFT
	tick(0.02)
	check(run.carried.state == LootItem.State.CARRIED and run.cargo.is_empty(), "Movement interrupts loading and keeps object")
	run.intention = Vector2.ZERO
	tick(0.4)
	check(run.carried == null and run.cargo_used == 2 and run.cargo_value == 140, "Load frees hands and updates cargo")
	run.commit_load()
	check(run.cargo.size() == 1 and store.data.wallet == 0 and run.phase == RunManager.Phase.ACTIVE, "No duplicate load, auto escape, or premature banking")
	run.pause()
	var paused_time = run.remaining
	tick(5)
	check(run.remaining == paused_time and run.intention == Vector2.ZERO, "Pause freezes clock and resets intention")
	run.resume()
	run.escape()
	run.escape()
	check(store.data.wallet == 140 and store.data.successes == 1, "Escape banks loot exactly once")
	sell_pending()
	check(store.data.wallet == 140, "No extra item-decision payout remains")
	await create_run()
	check(world.items[7].strength_lock.visible and not world.items[0].strength_lock.visible, "Strength-gated loot has a world lock from the start; available loot does not")
	begin()
	load_item(world.items[0])
	var wallet = store.data.wallet
	run.remaining = 0.001
	tick(0.02)
	run.escape()
	check(run.phase == RunManager.Phase.FINISHED and store.data.wallet == wallet and not run.result.success and run.result.lost == 140, "Timeout beats escape and loses loaded loot")
	await create_run()
	begin()
	stand_by(world.items[7])
	tick(2)
	check(run.carried == null and run.block_reason(world.items[7]) == "STRENGTH 2 REQUIRED", "Fridge locked by Strength")
	run.cargo_used = 7
	check(run.block_reason(world.items[0]) == "NOT ENOUGH VAN SPACE", "Insufficient van space blocks pickup")
	run.cargo_used = 8
	world.player.position = world.van.load_position
	tick(0.2)
	check(run.phase == RunManager.Phase.ACTIVE and run.can_escape(), "Full van stays active until explicit escape")
	run.cargo_used = 0
	world.items[7].position = Vector3(-1.2, 0.08, 0)
	world.items[0].position = Vector3(-1.8, 0.08, 0)
	world.player.position = Vector3(-1.0, 0, 0)
	run.cancel_interaction()
	run.select_target()
	check(run.target == world.items[0], "Ineligible closest object does not block eligible target")
	run.cancel_interaction()
	# Apartment's real Kitchen/Bath spine sits at x=0, spanning z:[-3.65,0.4].
	# Player and item are on opposite sides at the same z, close enough to be
	# in pickup range by distance alone — only the spine's own collision can
	# block the ray or the pickup here.
	world.items[0].position = Vector3(0.5, 0.08, -1.0)
	world.player.position = Vector3(-0.5, 0, -1.0)
	await physics_frame
	check(not world.accessible(world.items[0]), "Wall ray blocks pickup through partition")
	run.select_target()
	check(run.target != world.items[0], "Occluded target cannot be selected")
	var drop_point = world.drop_position(world.items[7])
	check(drop_point != Vector3.INF and world.valid_drop(drop_point, world.items[7].data.radius), "Drop position avoids walls and map limits")
	test_economy()
	test_input()
	await test_collision()
	await test_success_progression()
	await test_routes()
	await test_replays()
	await test_ui()
	print("TEST SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func test_economy() -> void:
	var save = SaveStore.new("res://tests/save_roundtrip.json")
	save.data.wallet = 1600
	check(not save.purchase("strength", false) and save.data.wallet == 1600, "Upgrades blocked during rounds")
	check(save.purchase("strength", true) and save.data.wallet == 250 and save.data.upgrades.strength == 2, "Strength purchase costs exactly $1350")
	check(not save.purchase("strength", true) and save.data.wallet == 250, "Insufficient funds never go negative")
	check(save.save_progress(), "Atomic save succeeds")
	var readback = SaveStore.new(save.path)
	readback.load_progress()
	check(readback.data == save.data, "Save/load roundtrip")
	var damaged = FileAccess.open(save.path, FileAccess.WRITE)
	damaged.store_string("{broken")
	damaged.close()
	readback.load_progress()
	check(readback.data.wallet == 250 and readback.notice.contains("backup"), "Corrupted save recovers backup")
	var invalid = save.validate({"wallet": -9, "upgrades": {"strength": 900, "grip": "bad"}, "trophies": ["bust", "bust", "bad"]})
	check(invalid.wallet == 0 and invalid.upgrades.strength == 5 and invalid.upgrades.grip == 1 and invalid.trophies.size() == 1, "Save validation clamps levels, wallet and duplicate trophies")
	check(invalid.trophies == ["duck"], "Existing Golden Bust trophy becomes Rubber Duck")
	var untouched = run.upgrades.duplicate()
	run.upgrades = {"strength": 1, "grip": 1, "carry": 1, "capacity": 1, "noise": 1}
	var speed = run.movement_factor(world.items[7])
	run.upgrades.strength = 3
	check(run.movement_factor(world.items[7]) == speed, "Strength does not change carry speed")
	run.upgrades.grip = 4
	check(run.movement_factor(world.items[7]) == speed and is_equal_approx(Balance.grip_speed(4), 1.36), "Grip affects pickup only")
	run.upgrades.carry = 20
	check(is_equal_approx(run.movement_factor(world.items[7]), 1.38 * 0.9607843137) and is_equal_approx(run.movement_factor(world.items[1]), 1.38 * 0.9934640523) and is_equal_approx(run.movement_factor(null), 1.38), "Carry speed raises walking speed and recovers every weight penalty")
	run.upgrades = untouched
	save.data.wallet = 2000000
	save.data.apartment_final_job_completed = true
	save.data.museum_final_job_completed = true
	save.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	for key in Balance.COSTS:
		for i in range(20): save.purchase(key, true)
		check(save.data.upgrades[key] == Balance.COSTS[key].size() + 1 and not save.purchase(key, true), "MAX enforced for " + key)
	var missing = SaveStore.new("res://tests/does_not_exist.json")
	missing.load_progress()
	check(missing.data.wallet == 0, "Missing save initializes cleanly")

func test_input() -> void:
	var input = MoveInput.new()
	root.add_child(input)
	input.enabled = true
	var press = InputEventScreenTouch.new()
	press.index = 3
	press.pressed = true
	press.position = Vector2(200, 500)
	input._gui_input(press)
	var drag = InputEventScreenDrag.new()
	drag.index = 3
	drag.position = Vector2(278, 578)
	input._input(drag)
	check(is_equal_approx(input.direction.length(), 1), "Touch diagonal speed is normalized")
	var other = InputEventScreenTouch.new()
	other.index = 4
	other.pressed = false
	input._input(other)
	check(input.pointer == 3, "Other touch cannot release active pointer")
	drag.position = press.position + Vector2(2, 2)
	input._input(drag)
	check(input.direction == Vector2.ZERO, "Returning joystick to neutral stops movement")
	press.pressed = false
	input._input(press)
	check(input.pointer == -1 and input.direction == Vector2.ZERO, "Touch release resets input")
	var mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.position = Vector2(200, 500)
	input._gui_input(mouse)
	var motion = InputEventMouseMotion.new()
	motion.position = Vector2(280, 500)
	input._input(motion)
	check(input.direction == Vector2.RIGHT and input.pointer == -2, "Mouse drag emulates floating joystick")
	input.reset()
	check(input.direction == Vector2.ZERO and input.pointer == -1, "Focus reset clears active pointer")
	input.free()

func test_collision() -> void:
	await create_run()
	begin()
	# Apartment's real Living/Kitchen-Bath partition sits at z=0.4, solid for
	# x outside the [-1.4,1.4] doorway gap. x=-2.5 is inside the solid segment,
	# so walking north from open Living floor must stop at the wall face.
	world.player.position = Vector3(-2.5, 0, 1.0)
	for i in range(30):
		await physics_frame
		run.intention = Vector2.UP
		run._physics_process(1.0 / 60)
		world.player._physics_process(1.0 / 60)
	check(world.player.position.z > 0.3, "CharacterBody collides with partition")
	world.player.position = Vector3(-1.9, 0, 2.6)
	run.intention = Vector2.ZERO
	tick(1)
	for i in range(30):
		await physics_frame
		run.intention = Vector2.UP
		run._physics_process(1.0 / 60)
		world.player._physics_process(1.0 / 60)
	check(world.player.position.z < 1.8, "Picking up loot leaves no invisible collider")

func test_success_progression() -> void:
	await create_run("apartment", true)
	begin()
	load_item(world.items[7])
	load_item(world.items[8])
	run.escape()
	check(store.data.objectives.apartment == {"cash": true, "signature": true, "full_clear": false} and not store.unlocked("house") and Progression.final_job_unlocked(store.data), "Two Apartment objectives unlock Final Job, not Suburban directly")
	check(store.data.trophies == ["flamingo"] and store.data.wallet == 420, "Escaped trophy joins collection and its items bank")
	sell_pending()
	var permanent = store.data.duplicate(true)
	await create_run("apartment", true)
	store.data = permanent
	begin()
	load_item(world.items[8])
	run.escape()
	check(store.data.trophies.size() == 1 and store.data.wallet == 500, "Repeated trophy remains ordinary paid loot without duplicate collection")
	sell_pending()
	check(store.data.wallet == 500, "Repeated loot does not pay twice")
	await create_run("apartment", true)
	begin()
	load_item(world.items[8])
	run.remaining = 0
	run.escape()
	check(store.data.trophies.is_empty() and store.data.objectives.apartment == {"cash": false, "signature": false, "full_clear": false}, "Failed run grants no trophies or objectives")

func go_to(point: Vector3) -> bool:
	# Braking distance grows with the square of walk speed; slow down earlier at high Carry levels.
	var slowdown := 0.12 * pow(Balance.walk_factor(run.upgrades.carry), 2)
	for i in range(900):
		var difference = Vector2(point.x - world.player.position.x, point.z - world.player.position.z)
		if difference.length() < 0.08:
			run.intention = Vector2.ZERO
			return true
		if run.phase == RunManager.Phase.FINISHED: return false
		await physics_frame
		run.intention = difference.normalized() * minf(1.0, difference.length() / slowdown)
		run._physics_process(1.0 / 60)
		world.player._physics_process(1.0 / 60)
	return false

func physical_wait(seconds: float) -> void:
	run.intention = Vector2.ZERO
	for i in range(ceili(seconds * 60)):
		await physics_frame
		run._physics_process(1.0 / 60)
		world.player._physics_process(1.0 / 60)

func route_item(item: LootItem) -> bool:
	var lane = -1.15 if item.position.x < 0 else 1.15
	var approach = approach_point(item)
	if approach == Vector3.INF:
		printerr("No accessible approach for ", item.data.type_id)
		return false
	var z = approach.z
	if world.location_id == "electronics":
		# Follow the actual shop aisles. Open showroom routes can be diagonal;
		# service stock still has to pass through the central partition opening.
		var stops: Array[Vector3] = [Vector3(0,0,2.4)]
		if item.position.z < -2.67:
			stops.append(Vector3(lane,0,-3.20))
		elif item.position.x > 0 and item.data.type_id == "small_tv":
			stops.append(Vector3(1.52,0,-0.9))
		elif item.position.x > 0:
			stops.append(Vector3(1.6,0,1.55))
		for stop in stops:
			if not await go_to(stop): return false
		if not await go_to(approach): return false
		await physical_wait(Balance.pickup_time(float(item.data.pickup_duration),run.upgrades.grip)+0.25)
		if run.carried != item:
			printerr("STORE pickup failed: ",item.data.type_id," at ",world.player.position," target ",run.nearby_text)
			return false
		stops.reverse()
		for stop in stops:
			if not await go_to(stop): return false
		if not await go_to(world.van.load_position): return false
		await physical_wait(0.4)
		return run.carried == null
	if not await go_to(Vector3(0, 0, 2.4)): return false
	if not await go_to(Vector3(lane, 0, 2.4)): return false
	if world.location_id == "villa":
		var door_z = -5.55 if item.position.z < -3.1 else 0.3
		var room_x = -2.25 if item.position.x < 0 else 2.25
		if not await go_to(Vector3(lane, 0, door_z)): return false
		if not await go_to(Vector3(room_x, 0, door_z)): return false
		if not await go_to(approach): return false
		await physical_wait(Balance.pickup_time(float(item.data.pickup_duration), run.upgrades.grip) + 0.25)
		if run.carried != item:
			printerr("ROUTE pickup failed: ", item.data.type_id, " at ", world.player.position, " target ", run.nearby_text)
			return false
		if not await go_to(Vector3(room_x, 0, door_z)): return false
		if not await go_to(Vector3(lane, 0, door_z)): return false
		if not await go_to(Vector3(lane, 0, 2.4)): return false
		if not await go_to(Vector3(0, 0, 3.6)): return false
		await physical_wait(0.4)
		return run.carried == null
	if not await go_to(Vector3(lane, 0, z)): return false
	if not await go_to(approach): return false
	await physical_wait(Balance.pickup_time(float(item.data.pickup_duration), run.upgrades.grip) + 0.25)
	if run.carried != item:
		printerr("ROUTE pickup failed: ", item.data.type_id, " at ", world.player.position, " target ", run.nearby_text)
		return false
	if not await go_to(Vector3(lane, 0, z)): return false
	if not await go_to(Vector3(lane, 0, 2.4)): return false
	var loading_point = world.van.load_position if world.location_id in ["house", "pirate_ship", "vikings", "english_pub", "prehistoric"] else Vector3(0, 0, 3.6)
	if not await go_to(loading_point): return false
	await physical_wait(0.4)
	return run.carried == null

func approach_point(item: LootItem) -> Vector3:
	var best = Vector3.INF
	var best_distance = INF
	var lane = -1.15 if item.position.x < 0 else 1.15
	var villa_room_origin = Vector3(-2.25 if item.position.x < 0 else 2.25, 0.5, -5.55 if item.position.z < -3.1 else 0.3)
	# Respect nearest-eligible targeting. Walk around neighboring loot, never force-pick.
	for gap in [0.35, 0.15, 0.05]:
		for step in range(24):
			var angle = TAU * float(step) / 24
			var point = item.position + Vector3(sin(angle), 0, cos(angle)) * (float(item.data.radius) + gap)
			point.y = 0
			if not world.valid_drop(point, 0.24): continue
			var lane_point = villa_room_origin if world.location_id == "villa" else Vector3(lane, 0.5, point.z)
			var space_state = world.get_world_3d().direct_space_state
			if not space_state.intersect_ray(PhysicsRayQueryParameters3D.create(lane_point, point + Vector3.UP * 0.5, 1)).is_empty(): continue
			if not space_state.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.5, item.position + Vector3.UP * 0.5, 1)).is_empty(): continue
			var nearest = true
			for other in world.items:
				if other == item or other.state != LootItem.State.AVAILABLE or run.block_reason(other) != "": continue
				if other.edge_distance(point) < gap + 0.12:
					nearest = false
					break
			if not nearest: continue
			var distance = absf(point.x - lane) + 3.6 - point.z
			if distance < best_distance:
				best_distance = distance
				best = point
	return best

func test_routes() -> void:
	for location in ["apartment", "house"]:
		await create_run(location, true)
		var total_cargo = 0
		var total_value = 0
		var completed = true
		for item in world.items:
			total_cargo += int(item.data.cargo_space)
			total_value += int(item.data.cash_value)
			if not await route_item(item):
				completed = false
				break
		check(total_cargo == (17 if location == "apartment" else 23) and total_value == (1210 if location == "apartment" else 2140), "Configured totals for " + location)
		run.escape()
		check(completed and run.result.get("full_clear", false) and run.elapsed < 60, "PHYSICAL full clear " + location + " in %.2fs" % run.elapsed)
		if completed:
			check(store.data.wallet == total_value + 250 and store.data.records.normal.has(location), "First clear banks loot and its bonus " + location)
			sell_pending()
			check(store.data.wallet == total_value + 250, "Full haul pays its configured value once " + location)
			var saved = store.data.duplicate(true)
			await create_run(location, true)
			store.data = saved
			begin()
			for item in world.items: load_item(item)
			run.escape()
			check(run.result.bonus == 0 and store.data.wallet == total_value * 2 + 250, "Unique full-clear bonus never repeats " + location)
			sell_pending()
			check(store.data.wallet == total_value * 2 + 250, "Second haul pays once " + location)
	await create_run()
	var completed = true
	for index in [0, 2, 1]:
		if not await route_item(world.items[index]): completed = false
	run.escape()
	check(completed and run.result.get("success", false) and store.data.wallet >= 250, "Physical first run banks three objects in %.2fs" % run.elapsed)
	sell_pending()
	check(store.data.wallet >= 250, "First three objects pay useful starting cash")

func test_replays() -> void:
	if is_instance_valid(run): run.free()
	if is_instance_valid(world): world.free()
	await process_frame
	var baseline = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for i in range(10):
		await create_run()
		begin()
		load_item(world.items[0])
		if i % 2 == 0: run.escape()
		else: run.abandon()
		run.free()
		world.free()
		await process_frame
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) == baseline, "Ten runs release all level, loot, tween and manager nodes")

func test_ui() -> void:
	var ui = GameUI.new()
	root.add_child(ui)
	var profile = SaveStore.new("res://tests/ui_profile.json")
	for size in [Vector2i(720, 1280), Vector2i(720, 1600)]:
		root.size = size
		ui.locations(profile)
		await process_frame
		await process_frame
		check(ui.menu.size.x <= root.size.x + 1, "Menu fits portrait %s" % size)
		ui.show_run()
		await process_frame
		check(ui.timer.get_global_rect().position.y >= 0 and ui.drop_button.get_global_rect().end.y <= root.size.y, "HUD safe bounds at %s" % size)
	ui.free()
	await process_frame
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/integration_profile.json")
	main.store.data.tutorial_completed = true
	main.store.data.noise_tutorial_completed = true
	main.store.data.heist_briefing_seen = true
	root.add_child(main)
	main.start_run("apartment")
	await process_frame
	await process_frame
	main.run.set_physics_process(false)
	main.level.player.set_physics_process(false)
	var key = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.keycode = KEY_W
	key.pressed = true
	main.ui.input.keyboard_ready = true
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	check(main.ui.input.movement() == Vector2.UP, "W keyboard input maps up the screen")
	key.pressed = false
	Input.parse_input_event(key.duplicate())
	Input.flush_buffered_events()
	check(main.ui.input.movement() == Vector2.ZERO, "Keyboard release stops immediately")
	key.physical_keycode = KEY_RIGHT
	key.keycode = KEY_RIGHT
	key.pressed = true
	Input.parse_input_event(key.duplicate())
	Input.flush_buffered_events()
	check(main.ui.input.movement() == Vector2.RIGHT, "Arrow key maps right")
	key.pressed = false
	Input.parse_input_event(key.duplicate())
	Input.flush_buffered_events()
	main.run.intention = Vector2.RIGHT
	main.run._physics_process(0.02)
	var press = InputEventMouseButton.new()
	press.position = Vector2(200, 500)
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	root.push_input(press, true)
	var motion = InputEventMouseMotion.new()
	motion.position = Vector2(280, 500)
	root.push_input(motion, true)
	check(main.ui.input.pointer == -2 and main.ui.input.direction.x > 0, "Viewport routes mouse drag to joystick")
	press.pressed = false
	press.position = motion.position
	root.push_input(press, true)
	main._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var time_before = main.run.remaining
	main.run._physics_process(20)
	check(main.run.phase == RunManager.Phase.PAUSED and main.run.remaining == time_before and main.ui.input.pointer == -1, "Background pauses gameplay and clears pointer")
	main._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(main.run.phase == RunManager.Phase.PAUSED, "Return from background requires explicit RESUME")
	main.action("resume")
	check(main.run.phase == RunManager.Phase.ACTIVE and main.run.intention == Vector2.ZERO, "RESUME restores play without stale input")
	await process_frame
	await process_frame
	var pause_button = main.ui.pause_button
	press.position = pause_button.get_global_rect().get_center()
	press.pressed = true
	root.push_input(press, true)
	check(main.ui.input.pointer == -1, "UI press is consumed and never starts movement")
	press.pressed = false
	root.push_input(press, true)
	check(main.run.phase == RunManager.Phase.PAUSED, "Pause button works through viewport event routing")
	main.action("resume")
	main._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(main.run.phase == RunManager.Phase.PAUSED and not quit_on_go_back, "Back notification pauses instead of auto quitting")
	main.action("abandon")
	check(main.screen == "results" and main.store.data.failures == 1, "ABANDON reaches result screen and loses run")
	main.action("locations")
	check(main.screen == "locations" and main.run == null, "Result can return to location select")
	main.free()


