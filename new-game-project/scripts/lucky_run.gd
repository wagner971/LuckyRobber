class_name LuckyRun
extends RefCounted
var run: RunManager
var id := ""
var second_used := false
var slipped := false
var walk_time := 0.0
var shoe_clock := 0.0
var block: LootItem
var collected := false
var consume_failed := false

func setup(owner_run: RunManager) -> void:
	run = owner_run
	if run.level.training_layout: return
	id = str(run.store.data.get("lucky_pending",{}).get("id",""))
	if not run.store.data.get("lucky_pending",{}).get("seen",true): id = ""
	match id:
		"bottomless": run.rules.capacity = 99999
		"tiny": run.rules.capacity = floori(run.rules.capacity*0.7)
		"time": run.rules.duration += 20
		"short": run.rules.duration -= 15
		"delay": run.rules.alarm_window += 8
		"rush": run.rules.alarm_window -= 4
		"strength": run.upgrades.strength = Balance.max_level("strength")
		"weak": run.upgrades.strength = maxi(0,run.upgrades.strength-1)
		"ghost":
			for child in run.level.player.get_children():
				if child is CollisionShape3D and child.shape is CapsuleShape3D: child.shape.radius = 0.15
		"dark":
			run.level.scene_environment.ambient_light_energy *= 0.78
			for child in run.level.get_children():
				if child is DirectionalLight3D: child.light_energy *= 0.88

func begin() -> bool:
	if id == "": return true
	var pending: Dictionary = run.store.data.lucky_pending.duplicate(true)
	run.store.data.lucky_pending = {}
	if not run.store.save_progress():
		run.store.data.lucky_pending = pending
		if not consume_failed: run.feedback.emit("blocked","SAVE FAILED · REOPEN THE JOB")
		consume_failed = true
		return false
	return true

func rarity() -> Dictionary:
	if id == "bad_luck": return {}
	if id == "golden": return LootRarity.variant(run.location_id+("_rare" if randf()<0.7 else "_epic"))
	return LootRarity.choose(run.location_id,randf()/(5.0 if id == "lucky_house" else 1.0))

func prepare_world(points: Array[Vector3], spawn_block: bool) -> void:
	var ordinary: Array[LootItem] = []
	for item in run.level.items:
		if item.rare_id == "": ordinary.append(item)
	if not ordinary.is_empty() and id in ["jackpot","curse"]:
		var item: LootItem = ordinary.pick_random()
		if id == "jackpot": item.data.cash_value *= 5
		else: item.set_meta("cursed",true)
		item.data.display_name = ("JACKPOT x5 · " if id=="jackpot" else "CURSED · ")+item.data.display_name
		mark(item,"JACKPOT x5" if id=="jackpot" else "CURSED +35 NOISE",Color("ffd459") if id=="jackpot" else Color("d683ff"),false)
	if id == "vision":
		for item in run.level.items:
			if item.rare_id != "": mark(item,item.data.display_name,Color("fff08b"),true)
	if id == "route" and not points.is_empty():
		ordinary.sort_custom(func(a,b): return a.data.cash_value>b.data.cash_value)
		for item in ordinary:
			if item.position.y > 0.3: continue
			var best := item.position
			for point in points:
				if not LuckyEffects.fits(run.level,point,float(item.data.radius)): continue
				var clear := true
				for other in run.level.items:
					if other != item and other.edge_distance(point)<float(item.data.radius)+0.25: clear=false; break
				if not clear: continue
				if point.distance_to(run.level.van.load_position)>best.distance_to(run.level.van.load_position)+0.3: best = point
			if best != item.position:
				item.position = best
				break
	if spawn_block and not points.is_empty():
		var indoor: Array[Vector3] = []
		var loot_bounds := Rect2(Vector2(run.level.items[0].position.x,run.level.items[0].position.z),Vector2.ZERO)
		for item in run.level.items: loot_bounds = loot_bounds.expand(Vector2(item.position.x,item.position.z))
		loot_bounds = loot_bounds.grow(0.35)
		for point in points:
			if loot_bounds.has_point(Vector2(point.x,point.z)) and point.distance_to(run.level.van.load_position)>3 and LuckyEffects.fits(run.level,point,0.4): indoor.append(point)
		var tint := LuckyShop.block_color(run.store.data)
		block = LuckyEffects.spawn(run.level,indoor.pick_random() if not indoor.is_empty() else points.pick_random(),tint)
		mark(block,"LUCKY BLOCK",tint.lightened(0.3),true)
		run.feedback.emit("lucky_spawn","LUCKY BLOCK ON THE MAP · GRAB IT!")
	for item in run.level.items:
		if item.data.type_id == "lucky_block": continue
		if id == "dark": item.set_meta("suppress_highlight",true)
		var factor := 2.0 if id=="double_cash" else (1.25 if id=="cash_rain" else (0.75 if id=="cheap" else 1.0))
		item.data.cash_value = roundi(item.data.cash_value*factor)

func mark(item: LootItem, text: String, color: Color, through: bool) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 24
	label.pixel_size = 0.009
	label.position.y = 2.3
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = through
	item.add_child(label)
	item.set_meta("lucky_label",label)
	if id == "jackpot":
		var visual := RarityVisual.new()
		item.add_child(visual)
		visual.setup(item,{"tier":"RARE","color":color})
		item.rarity_marker = visual

func movement(item: LootItem) -> float:
	var factor := Balance.walk_factor(run.upgrades.carry)
	if item != null:
		var weight: String = item.data.weight_class
		if id == "feather": weight = "LIGHT"
		if id == "world":
			var classes := ["LIGHT","MEDIUM","HEAVY","VERY_HEAVY"]
			weight = classes[mini(3,classes.find(weight)+1)]
		factor *= Balance.carry_factor(weight,run.upgrades.carry)
		if id == "hands" or (id == "panic" and run.alarm_active): factor *= 0.8
	if id == "speed": factor *= 1.3
	if id == "slow": factor *= 0.7
	if id == "sticky" and run.elapsed>4.5 and fmod(run.elapsed,5.0)<0.5: factor *= 0.45
	return factor

func pickup_duration(base: float) -> float: return 0 if id=="instant" else base*(1.5 if id=="butter" else 1.0)
func load_duration() -> float: return 0 if id=="quick_load" else Balance.LOAD_DURATION+(1.0 if id=="door" else 0.0)
func load_range() -> bool:
	return run.level.van.in_zone(run.level.player.global_position) or (id=="vacuum" and run.level.player.global_position.distance_to(run.level.van.load_position)<=2)
func noise(value: float) -> float: return 0 if id=="silent" else value*(2 if id=="noise" else 1)

func tick(delta: float, moving: bool) -> void:
	if run.carried != null and moving:
		walk_time += delta
		if id=="shoes" and run.carried.data.weight_class in ["HEAVY","VERY_HEAVY"]:
			shoe_clock += delta
			if shoe_clock>=3: shoe_clock=0; run.add_noise(2)
		if id=="slippery" and not slipped and walk_time>=8:
			if run.drop(): slipped=true; run.feedback.emit("drop","SLIPPERY LOOT · PICK IT BACK UP")
	if id=="vacuum" and run.carried!=null and load_range():
		run.carried.state = LootItem.State.LOADING
		run.progress_duration = load_duration()
		run.nearby_text = "LOADING " + run.carried.data.display_name
		run.progress += delta
		if run.progress>=load_duration(): run.commit_load()
	if id=="magnet" and run.carried==null:
		for item in run.level.items:
			if item.state not in [LootItem.State.AVAILABLE,LootItem.State.PICKING_UP] or item.cooldown>0 or item.global_position.distance_to(run.level.player.global_position)>2: continue
			if run.block_reason(item)!="" or not run.level.accessible(item): continue
			run.cancel_interaction()
			run.target=item
			run.commit_pickup()
			break

func extra_life() -> bool:
	if id!="second" or second_used: return false
	second_used=true
	run.remaining=7
	run.feedback.emit("alarm","SECOND CHANCE · 7 SECONDS!")
	return true

