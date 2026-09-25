class_name RunManager
extends Node

signal feedback(kind: String, message: String)
signal ended(result: Dictionary)
signal cash_loaded(amount: int)
enum Phase { READY, ACTIVE, PAUSED, FINISHED }
var phase = Phase.READY
var phase_before_pause = Phase.READY
var level: HeistLevel
var store: SaveStore
var location_id = "apartment"
var remaining = 60.0
var elapsed = 0.0
var carried: LootItem
var target: LootItem
var cargo: Array[LootItem] = []
var cargo_used = 0
var cargo_value = 0
var progress = 0.0
var progress_duration = 1.0
var intention = Vector2.ZERO
var nearby_text = ""
var tutorial = "DRAG TO MOVE"
var last_warning_second = 11
var previous_block = ""
var result: Dictionary = {}
var mode = "normal"
var rules: Dictionary = {}
var upgrades: Dictionary = {}
var current_noise = 0.0
var alarm_threshold = 0.0
var alarm_active = false
var alarm_warning_sent = false
var time_when_alarm_triggered = -1.0
var alarm_window = Balance.ALARM_WINDOW
var started = false
var onboarding: Onboarding
var noise_lesson = false
var noise_hint_time = 0.0
var lucky: LuckyRun
var world_prepared := false
var random_encounters := true

func setup(world: HeistLevel, save: SaveStore, location: String, session_mode: String = "normal", allow_random_encounters: bool = true) -> void:
	random_encounters = allow_random_encounters
	level = world
	level.player.run_state = self
	level.van.cargo_landed.connect(func():
		var weight: String = level.van.last_impact_weight
		feedback.emit("wham", "" if weight == "LIGHT" else ("THUNK" if weight == "MEDIUM" else ("WHAM!!" if weight == "VERY_HEAVY" else "WHAM!")))
	)
	store = save
	location_id = location
	mode = session_mode
	upgrades = store.data.upgrades.duplicate()
	rules = Balance.session(location, mode, upgrades, store.data.special_type)
	lucky = LuckyRun.new()
	lucky.setup(self)
	remaining = rules.duration
	alarm_window = rules.alarm_window
	current_noise = 0.0
	alarm_threshold = Balance.alarm_threshold(location)
	alarm_active = false
	alarm_warning_sent = false
	time_when_alarm_triggered = -1.0
	if (mode == "normal" or lucky.id in ["golden","lucky_house"]) and not level.training_layout and random_encounters:
		var rare_choice: Dictionary = lucky.rarity()
		for item in level.items:
			if not rare_choice.is_empty() and item.instance_id_in_run == location_id + "." + str(rare_choice.slot):
				item.apply_rarity(rare_choice)
				break
	for item in level.items:
		item.noise_generated_this_run = false
		item.set_strength_lock(int(upgrades.strength))
	process_physics_priority = -10
	noise_lesson = mode == "normal" and not store.data.noise_tutorial_completed
	prepare_lucky_world.call_deferred()

func prepare_lucky_world() -> void:
	await get_tree().physics_frame
	if not is_instance_valid(level): return
	if not level.training_layout:
		var spawn_block := random_encounters and LuckyEffects.spawns(randf())
		var points: Array[Vector3] = []
		if spawn_block or lucky.id == "route": points = LuckyEffects.floor_points(level)
		lucky.prepare_world(points,spawn_block)
	for item in level.items:
		item.loot_highlight = LootHighlight.new()
		item.add_child(item.loot_highlight)
		item.loot_highlight.setup(item)
	world_prepared = true

func enable_tutorial(replay: bool = false) -> void:
	assert(location_id == "apartment" and level.training_layout and phase == Phase.READY)
	onboarding = Onboarding.new()
	add_child(onboarding)
	onboarding.setup(self, replay)
	rules = rules.duplicate(true)
	rules.duration = 90.0
	remaining = 90.0
	rules.capacity = 6
	noise_lesson = false
	noise_hint_time = 0

func capacity() -> int:
	return rules.capacity

func van_is_full() -> bool:
	return cargo_used >= capacity()

func movement_factor(item: LootItem) -> float:
	return lucky.movement(item)

func _physics_process(delta: float) -> void:
	if not world_prepared:
		level.player.move_input = Vector2.ZERO
		return
	var rarity_target: LootItem = label_item()
	for item in level.items:
		if is_instance_valid(item.loot_highlight):
			item.loot_highlight.update_visual(delta, item == rarity_target, phase != Phase.FINISHED and item.state in [LootItem.State.AVAILABLE, LootItem.State.PICKING_UP], phase == Phase.PAUSED)
		if item.has_meta("lucky_label"):
			item.get_meta("lucky_label").visible = item.state in [LootItem.State.AVAILABLE,LootItem.State.PICKING_UP]
		if is_instance_valid(item.rarity_marker):
			item.rarity_marker.update_visual(delta, item == rarity_target, phase != Phase.FINISHED and item.state in [LootItem.State.AVAILABLE, LootItem.State.PICKING_UP], phase == Phase.PAUSED)
	if phase in [Phase.PAUSED, Phase.FINISHED]:
		level.player.move_input = Vector2.ZERO
		return
	var moving = intention.length() > Balance.INPUT_DEADZONE
	if is_instance_valid(level.security): level.security.tick(delta,self)
	level.player.move_input = intention.limit_length() if moving else Vector2.ZERO
	level.player.speed_factor = movement_factor(carried)
	if onboarding != null:
		onboarding.tick(delta)
		if onboarding.step == Onboarding.Step.MOVE: return
	noise_hint_time = maxf(0, noise_hint_time - delta)
	if phase == Phase.READY:
		if not moving and onboarding == null: return
		if not lucky.begin():
			level.player.move_input = Vector2.ZERO
			return
		phase = Phase.ACTIVE
		started = true
		if mode == SpecialJobs.MODE:
			SpecialJobs.begin(store.data, location_id)
			store.save_progress()
		tutorial = "STOP NEAR AN OBJECT TO PICK IT UP"
		LocalLog.event("run_started", {"location": location_id, "mode": mode, "upgrades": upgrades.duplicate()})
	if onboarding == null: remaining = maxf(0.0, remaining - delta)
	elapsed += delta
	if remaining <= 0 and not lucky.extra_life():
		finish(false)
		return
	if onboarding == null and remaining <= 10 and ceili(remaining) < last_warning_second:
		last_warning_second = ceili(remaining)
		feedback.emit("tick", "")
	for item in level.items: item.cooldown = maxf(0, item.cooldown - delta)
	lucky.tick(delta,moving)
	if lucky.id == "vacuum" and carried != null and lucky.load_range(): return
	if moving or level.player.velocity.length() > 0.08:
		cancel_interaction()
		nearby_text = carried.data.display_name if carried != null else ("VAN FULL · ESCAPE!" if van_is_full() else "STOP TO PICK UP")
		return
	if carried != null:
		if lucky.load_range():
			carried.state = LootItem.State.LOADING
			progress_duration = lucky.load_duration()
			progress += delta
			nearby_text = "LOADING " + carried.data.display_name
			if progress >= progress_duration: commit_load()
		else:
			nearby_text = "CARRYING " + carried.data.display_name
		return
	if target == null: select_target()
	if target != null:
		if target.edge_distance(level.player.global_position) > Balance.PICKUP_RANGE or not level.accessible(target):
			cancel_interaction()
			return
		progress_duration = lucky.pickup_duration(Balance.pickup_time(float(target.data.pickup_duration), upgrades.grip))
		progress += delta
		nearby_text = "%s  ·  $%d  ·  %d CARGO" % [target.data.display_name, target.data.cash_value, target.data.cargo_space]
		if progress >= progress_duration: commit_pickup()

func select_target() -> void:
	var nearest = INF
	var blocked: LootItem
	var blocked_distance = INF
	nearby_text = "RETURN TO THE VAN" if cargo_used > 0 else "STOP NEAR AN OBJECT"
	for item in level.items:
		item.highlight(false)
		if item.state != LootItem.State.AVAILABLE or item.cooldown > 0: continue
		if onboarding != null and not onboarding.permits_pickup(item): continue
		var distance = item.edge_distance(level.player.global_position)
		if distance > Balance.PICKUP_RANGE or not level.accessible(item): continue
		if block_reason(item) != "":
			if distance < blocked_distance:
				blocked = item
				blocked_distance = distance
			continue
		if distance < nearest:
			nearest = distance
			target = item
	if target != null:
		target.state = LootItem.State.PICKING_UP
		target.highlight(true)
		previous_block = ""
	elif blocked != null:
		nearby_text = blocked.data.display_name + " · " + block_reason(blocked)
		if previous_block != nearby_text:
			feedback.emit("blocked", block_reason(blocked))
			previous_block = nearby_text
	else: previous_block = ""
	if van_is_full() and target == null: nearby_text = "VAN FULL · ESCAPE!"

func block_reason(item: LootItem) -> String:
	if item.data.type_id == "lucky_block": return ""
	if int(item.data.required_strength) > int(upgrades.strength): return "STRENGTH %d REQUIRED" % item.data.required_strength
	if int(item.data.cargo_space) + cargo_used > capacity(): return "NOT ENOUGH VAN SPACE"
	return ""

func cancel_interaction() -> void:
	if target != null:
		target.state = LootItem.State.AVAILABLE
		target.highlight(false)
		target = null
	if carried != null and carried.state == LootItem.State.LOADING: carried.state = LootItem.State.CARRIED
	progress = 0

func commit_pickup() -> void:
	if phase != Phase.ACTIVE or remaining <= 0 or carried != null or target == null: return
	if onboarding != null and not onboarding.permits_pickup(target): return
	if block_reason(target) != "":
		cancel_interaction()
		return
	carried = target
	target = null
	if carried.data.type_id == "toilet": level.splash(carried.global_position)
	carried.state = LootItem.State.CARRIED
	carried.set_strength_lock(int(upgrades.strength))
	carried.highlight(false)
	var pickup_origin := carried.global_position
	carried.reparent(level.player.carry_anchor, false)
	carried.position = Vector3.ZERO
	if lucky.id == "magnet":
		carried.position = level.player.carry_anchor.to_local(pickup_origin)
		carried.create_tween().tween_property(carried,"position",Vector3.ZERO,0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	carried.rotation = Vector3.ZERO
	carried.model.rotation = Vector3.ZERO
	if carried.has_meta("lucky_label"): carried.get_meta("lucky_label").hide()
	if carried.rare_id != "":
		if is_instance_valid(carried.rarity_marker): carried.rarity_marker.update_visual(0, false, false, false)
		feedback.emit("rare_found", "%s LOOT FOUND!|%s · $%d" % [LootRarity.variant(carried.rare_id).tier, carried.data.display_name, int(carried.data.cash_value)])
	carried.pickup_pop()
	level.player.visual.picked_up()
	progress = 0
	tutorial = "TAKE IT TO THE VAN"
	feedback.emit("pickup", carried.data.display_name + "! TAKE IT TO THE VAN")
	LocalLog.event("item_picked_up", {"item": carried.data.type_id, "id": carried.instance_id_in_run})
	add_pickup_noise(carried)
	if onboarding != null: onboarding.picked_up(carried)
	if noise_lesson:
		noise_lesson = false
		noise_hint_time = 4.0
		store.data.noise_tutorial_completed = true
		store.save_progress()
		if not store.session_only: LocalLog.onboarding_event("noise_tutorial_shown", {"profile": store.path, "location": location_id, "elapsed": elapsed})

func add_pickup_noise(item: LootItem) -> void:
	if onboarding != null: return
	if phase != Phase.ACTIVE or remaining <= 0 or item != carried or item.noise_generated_this_run: return
	item.noise_generated_this_run = true
	if item.data.type_id == "lucky_block": return
	var added: float = Balance.pickup_noise(item.data.weight_class, upgrades.strength, upgrades.noise)
	if item.get_meta("cursed",false): added += 35
	add_noise(added)

func add_noise(amount: float) -> void:
	if onboarding != null or phase != Phase.ACTIVE or remaining <= 0: return
	var added := lucky.noise(amount)
	if added <= 0: return
	current_noise += added
	feedback.emit("noise", "+%d NOISE" % roundi(added))
	LocalLog.event("noise_added", {"location": location_id, "mode": mode, "added": added, "total": current_noise, "threshold": alarm_threshold})
	if current_noise >= alarm_threshold and not alarm_active:
		alarm_active = true
		time_when_alarm_triggered = elapsed
		remaining = minf(remaining, alarm_window)
		tutorial = "ALARM! RETURN TO THE VAN · ESCAPE"
		feedback.emit("alarm", "ALARM! POLICE IN %ds" % ceili(remaining))
		LocalLog.event("alarm_triggered", {"location": location_id, "mode": mode, "active_time": elapsed, "remaining": remaining, "noise": current_noise, "threshold": alarm_threshold})
	elif not alarm_active and not alarm_warning_sent and current_noise >= alarm_threshold * Balance.ALARM_WARNING_FACTOR:
		alarm_warning_sent = true
		feedback.emit("noise_warning", "+%d NOISE · ! ALARM CLOSE" % roundi(added))
		LocalLog.event("alarm_warning", {"location": location_id, "mode": mode, "noise": current_noise, "threshold": alarm_threshold})

func commit_load() -> void:
	if phase != Phase.ACTIVE or remaining <= 0 or carried == null: return
	if carried.state != LootItem.State.LOADING or not lucky.load_range(): return
	if cargo_used + int(carried.data.cargo_space) > capacity(): return
	var item = carried
	carried = null
	item.state = LootItem.State.LOADED
	cargo.append(item)
	cargo_used += int(item.data.cargo_space)
	cargo_value += int(item.data.cash_value)
	level.van.display_cargo(item, cargo.size() - 1,0.08 if lucky.id == "quick_load" else 0.26)
	level.player.visual.loaded()
	progress = 0
	tutorial = "ESCAPE BEFORE TIME RUNS OUT"
	if item.data.type_id == "lucky_block":
		lucky.collected = true
		feedback.emit("rare_found","LUCKY BLOCK SECURED!|Escape to reveal your next-run effect")
	else: feedback.emit("load", "VAN +$%d" % item.data.cash_value)
	if lucky.id == "loud_load": add_noise(4)
	if van_is_full(): feedback.emit("full", "VAN FULL · ESCAPE!")
	LocalLog.event("item_loaded", {"item": item.data.type_id, "id": item.instance_id_in_run, "cargo": cargo_used, "value": cargo_value})
	if onboarding != null: onboarding.loaded()
	if int(item.data.cash_value)>0: cash_loaded.emit(int(item.data.cash_value))

func drop() -> bool:
	if phase != Phase.ACTIVE or carried == null or remaining <= 0: return false
	var point = level.drop_position(carried)
	if point == Vector3.INF:
		feedback.emit("blocked", "MOVE A LITTLE TO DROP HERE")
		return false
	var item = carried
	carried = null
	item.reparent(level, false)
	item.position = point
	item.rotation = Vector3.ZERO
	item.state = LootItem.State.AVAILABLE
	if is_instance_valid(item.rarity_marker): item.rarity_marker.show()
	item.set_strength_lock(int(upgrades.strength))
	item.cooldown = 1.25
	progress = 0
	feedback.emit("drop", "DROPPED " + item.data.display_name)
	LocalLog.event("item_dropped", {"item": item.data.type_id, "id": item.instance_id_in_run})
	if onboarding != null: onboarding.dropped()
	return true

func can_escape() -> bool:
	if onboarding != null and not onboarding.permits_escape(): return false
	return phase == Phase.ACTIVE and carried == null and level.van.in_zone(level.player.global_position)

# Read-only candidate selection for the contextual label while moving. Eligibility
# and distance match the existing auto-pickup selector; blocked items are fallback.
func label_item() -> LootItem:
	if phase in [Phase.PAUSED, Phase.FINISHED] or carried != null: return null
	if onboarding != null and onboarding.guide_item() != null: return onboarding.guide_item()
	if target != null: return target
	var nearest: LootItem
	var blocked: LootItem
	var best = INF
	var blocked_best = INF
	for item in level.items:
		if item.state != LootItem.State.AVAILABLE or item.cooldown > 0: continue
		if onboarding != null and not onboarding.permits_pickup(item): continue
		var distance = item.edge_distance(level.player.global_position)
		if distance > Balance.PICKUP_RANGE or not level.accessible(item): continue
		if block_reason(item) != "":
			if distance < blocked_best:
				blocked = item
				blocked_best = distance
		elif distance < best:
			nearest = item
			best = distance
	return nearest if nearest != null else (null if van_is_full() else blocked)

func escape() -> void:
	if phase != Phase.ACTIVE: return
	if remaining <= 0:
		finish(false)
	elif can_escape(): finish(true)

func pause() -> void:
	if phase not in [Phase.READY, Phase.ACTIVE]: return
	phase_before_pause = phase
	phase = Phase.PAUSED
	level.player.enabled = false
	level.van.pause_visuals(true)
	intention = Vector2.ZERO
	level.player.move_input = Vector2.ZERO
	level.player.velocity = Vector3.ZERO
	cancel_interaction()

func resume() -> void:
	if phase != Phase.PAUSED: return
	intention = Vector2.ZERO
	phase = phase_before_pause
	# Pause owns the movement lock, including a pause entered during map reveal.
	# The transition may have held the player disabled when the briefing opened.
	level.player.enabled = true
	level.van.pause_visuals(false)

func abandon() -> void:
	if phase != Phase.FINISHED: finish(false, true)

func loaded_counts() -> Dictionary:
	var counts: Dictionary = {}
	for item in cargo:
		if item.data.type_id != "lucky_block": counts[item.data.type_id] = counts.get(item.data.type_id, 0) + 1
	return counts

func standard_cargo_count() -> int:
	var count := 0
	for item in cargo:
		if item.data.type_id != "lucky_block": count += 1
	return count

func contract_progress() -> String:
	if mode in ["normal", SpecialJobs.MODE, "FINAL_JOB"]: return ""
	var c: Dictionary = Balance.CONTRACTS[rules.contract_id]
	if c.order.is_empty(): return "%s · $%d / $%d" % [c.name, cargo_value, c.threshold]
	var counts = loaded_counts()
	var parts = PackedStringArray()
	for id in c.order: parts.append("%s %d/%d" % [Balance.ITEMS[id].display_name, mini(counts.get(id, 0), c.order[id]), c.order[id]])
	return " · ".join(parts)

func finish(success: bool, abandoned: bool = false) -> void:
	if phase == Phase.FINISHED: return
	if success and onboarding != null and not onboarding.permits_escape(): return
	success = success and remaining > 0
	phase = Phase.FINISHED
	level.van.pause_visuals(false)
	level.player.enabled = false
	level.player.velocity = Vector3.ZERO
	intention = Vector2.ZERO
	cancel_interaction()
	if onboarding != null:
		result = onboarding.settle(success)
		feedback.emit("success" if success else "failure", "")
		ended.emit(result)
		return
	var full_clear = success and standard_cargo_count() == Balance.LOCATIONS[location_id].items.size() and Progression.powerups_ready(store.data, location_id)
	var changes = {"bonus": 0, "contract_bonus": 0, "rush_bonus": 0, "new_objectives": [], "new_trophies": [], "new_cosmetics": [], "unlocked_locations": [], "contract_met": false}
	var escaped_types: Array = []
	var new_rare_loot: Array = []
	if success:
		var trophies: Array = []
		for item in cargo:
			if item.data.type_id == "lucky_block": continue
			if item.trophy_id != "": trophies.append(item.trophy_id)
			escaped_types.append(item.data.type_id)
			if item.rare_id != "" and item.rare_id not in store.data.rare_loot:
				store.data.rare_loot.append(item.rare_id)
				new_rare_loot.append(item.rare_id)
		changes = Progression.settle(store.data, location_id, mode, loaded_counts(), trophies, cargo_value, full_clear, elapsed, rules.get("special_type", SpecialJobs.DEFAULT_TYPE))
		if lucky.id == "haul" and float(standard_cargo_count())/Balance.LOCATIONS[location_id].items.size()>0.75:
			var haul_bonus := roundi(cargo_value*0.5)
			store.data.wallet += haul_bonus
			changes.bonus += haul_bonus
		if lucky.collected: LuckyMeter.award_block(store.data, "heist")
		# Every escaped object banks immediately and unlocks its blueprint
		# for the automatic duplication lab.
		Duplication.register_heist(store.data, location_id, escaped_types)
		store.data.successes += 1
		if int(store.data.get("first_job_at", 0)) == 0: store.data.first_job_at = int(Time.get_unix_time_from_system())
		store.data.mode_stats[mode].successes += 1
	else:
		store.data.failures += 1
		store.data.mode_stats[mode].failures += 1
	var special_unlocked = SpecialJobs.finish(store.data, mode, location_id, started)
	var meter := LuckyMeter.settle(store.data, {"success": success, "items": standard_cargo_count(), "new_objectives": changes.new_objectives, "full_clear": full_clear})
	store.data.last_location = location_id
	var saved = store.save_progress()
	var lost = cargo_value + (int(carried.data.cash_value) if carried != null else 0)
	result = changes.duplicate(true)
	result.merge({"success": success, "abandoned": abandoned, "mode": mode, "earned": cargo_value + changes.bonus + changes.contract_bonus + changes.rush_bonus if success else 0, "loot_value": cargo_value, "loot_types": escaped_types.duplicate(), "new_rare_loot": new_rare_loot, "pending_loot": 0, "lost": lost if not success else 0, "items": standard_cargo_count(), "lost_items": standard_cargo_count() + (1 if carried != null and carried.data.type_id != "lucky_block" else 0) if not success else 0, "elapsed": elapsed, "full_clear": full_clear and mode in ["normal", SpecialJobs.MODE, "FINAL_JOB"], "saved": saved, "special_unlocked": special_unlocked, "special_type": rules.get("special_type", "")})
	result.merge({"lucky_meter": meter, "lucky_collected": lucky.collected})
	result.merge({"final_noise": current_noise, "alarm_threshold": alarm_threshold, "alarm_triggered": alarm_active, "time_when_alarm_triggered": time_when_alarm_triggered, "remaining_time_at_escape": remaining if success else 0.0})
	if is_instance_valid(level.security):
		result.merge({"security_detections":level.security.detections,"security_time_lost":level.security.time_lost})
	LocalLog.event("run_ended", {"location": location_id, "mode": mode, "success": success, "result": "escaped" if success else "busted", "contract_met": changes.contract_met, "active_time": elapsed, "cash_escaped_with": cargo_value if success else 0, "cargo": cargo_used, "items": standard_cargo_count(), "noise_control_level": upgrades.noise, "final_noise": current_noise, "alarm_threshold": alarm_threshold, "alarm_triggered": alarm_active, "time_when_alarm_triggered": time_when_alarm_triggered, "remaining_time_at_escape": remaining if success else 0.0, "upgrade_levels": upgrades.duplicate()})
	feedback.emit("success" if success else "failure", "")
	ended.emit(result)
