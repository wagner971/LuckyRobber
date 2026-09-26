extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ")+label)
func run_test() -> void:
	LocalLog.enabled = false
	check(LuckyEffects.CATALOG.size()==40,"Forty effects")
	check(LuckyEffects.spawns(0) and LuckyEffects.spawns(0.299999) and not LuckyEffects.spawns(0.30),"Exact 30% spawn boundary")
	var positives := 0
	for key in LuckyEffects.CATALOG:
		if LuckyEffects.positive(key): positives+=1
	check(positives==20,"Twenty positive, twenty negative")
	var store := SaveStore.new("res://tests/lucky_test_profile.json")
	store.session_only = true
	store.data.heist_briefing_seen = true
	for key in Balance.UPGRADE_KEYS: store.data.upgrades[key] = Balance.max_level(key)
	var world := HeistLevel.new()
	root.add_child(world)
	world.setup("apartment",20)
	var run := RunManager.new()
	root.add_child(run)
	run.set_physics_process(false)
	run.setup(world,store,"apartment")
	while not run.world_prepared: await physics_frame
	var points := LuckyEffects.floor_points(world)
	check(points.size()>10,"Reachable spawn positions found")
	var baseline := Balance.session("apartment","normal",store.data.upgrades,store.data.special_type)
	var item: LootItem = world.items[0]
	for id in LuckyEffects.CATALOG:
		store.data.lucky_pending={"id":id,"seen":true}
		run.rules=baseline.duplicate(true)
		run.upgrades=store.data.upgrades.duplicate(true)
		run.lucky=LuckyRun.new()
		run.lucky.setup(run)
		run.remaining=60
		run.phase=RunManager.Phase.ACTIVE
		run.alarm_active=false
		run.current_noise=0
		run.carried=null
		run.target=null
		run.elapsed=0
		var original: Dictionary = item.data.duplicate(true)
		match id:
			"speed","slow": check(is_equal_approx((run.lucky.movement(null)/Balance.walk_factor(run.upgrades.carry)),1.3 if id=="speed" else 0.7),id+" movement modifier")
			"silent","noise":
				run.add_noise(5)
				check(run.current_noise==(0 if id=="silent" else 10),id+" affects real noise")
			"instant","butter": check(run.lucky.pickup_duration(2)==(0 if id=="instant" else 3),id+" pickup duration")
			"bottomless","tiny": check(run.capacity()==(99999 if id=="bottomless" else floori(baseline.capacity*0.7)),id+" cargo")
			"time","short": check(run.rules.duration==baseline.duration+(20 if id=="time" else -15),id+" start clock")
			"delay","rush": check(run.rules.alarm_window==baseline.alarm_window+(8 if id=="delay" else -4),id+" alarm clock")
			"strength","weak": check(run.upgrades.strength==(Balance.max_level("strength") if id=="strength" else Balance.max_level("strength")-1),id+" temporary strength")
			"quick_load","door": check(is_equal_approx(run.lucky.load_duration(),0 if id=="quick_load" else Balance.LOAD_DURATION+1),id+" load duration")
			"golden","bad_luck","lucky_house":
				var valid := true
				for i in range(100):
					var rare := run.lucky.rarity()
					if id=="bad_luck" and not rare.is_empty(): valid=false
					elif id!="bad_luck" and rare.is_empty(): valid=false
					elif id=="golden" and rare.tier not in ["RARE","EPIC"]: valid=false
				check(valid,id+" rarity rules")
			"second": check(run.lucky.extra_life() and run.remaining==7 and not run.lucky.extra_life(),"Second chance once")
			"feather","world","hands","panic":
				item.data.weight_class="MEDIUM"
				run.alarm_active=id=="panic"
				var weight := "LIGHT" if id=="feather" else ("HEAVY" if id=="world" else "MEDIUM")
				var expected: float = Balance.carry_factor(weight,run.upgrades.carry)*(0.8 if id in ["hands","panic"] else 1)
				check(is_equal_approx((run.lucky.movement(item)/Balance.walk_factor(run.upgrades.carry)),expected),id+" carry modifier")
			"sticky":
				run.elapsed=5.1
				check((run.lucky.movement(null)/Balance.walk_factor(run.upgrades.carry))==0.45,"Sticky slowdown")
				run.elapsed=5.6
				check((run.lucky.movement(null)/Balance.walk_factor(run.upgrades.carry))==1,"Sticky recovery")
			"ghost":
				var reduced := false
				for child in world.player.get_children():
					if child is CollisionShape3D and child.shape is CapsuleShape3D: reduced=is_equal_approx(child.shape.radius,0.15)
				check(reduced,"Ghost collision capsule")
			"vacuum":
				world.player.position=world.van.load_position+Vector3(1.8,0,0)
				check(run.lucky.load_range() and not world.van.in_zone(world.player.position),"Vacuum extends actual load radius")
			"magnet":
				world.player.position=item.position+Vector3(0,0,0.8)
				item.state=LootItem.State.AVAILABLE
				run.lucky.tick(0.016,true)
				check(run.carried!=null,"Magnet collects while moving")
				if run.carried!=null:
					run.carried.reparent(world,false)
					run.carried.position=Vector3(1,0,1)
					run.carried.state=LootItem.State.AVAILABLE
					run.carried=null
			"double_cash","cash_rain","cheap":
				run.lucky.prepare_world([],false)
				check(item.data.cash_value==roundi(original.cash_value*(2 if id=="double_cash" else (1.25 if id=="cash_rain" else 0.75))),id+" real item cash")
			"jackpot","curse","vision","dark","route":
				run.lucky.prepare_world(points,false)
				var found := false
				for candidate in world.items:
					if id=="jackpot" and candidate.data.display_name.begins_with("JACKPOT"): found=true
					if id=="curse" and candidate.get_meta("cursed",false): found=true
					if id=="vision" and (candidate.rare_id=="" or candidate.has_meta("lucky_label")): found=true
					if id=="dark" and candidate.get_meta("suppress_highlight",false): found=true
					if id=="route" and points.has(candidate.position): found=true
				check(found,id+" world treatment")
			"shoes":
				run.carried=item
				item.data.weight_class="HEAVY"
				run.lucky.tick(3.1,true)
				check(run.current_noise==2,"Heavy footsteps generate periodic noise")
			"slippery":
				run.carried=item
				world.player.position=Vector3(0,0,2)
				run.lucky.tick(8.1,true)
				check(run.lucky.slipped and run.carried==null,"Slippery drops carried item once")
		item.data=original
		check(store.data.upgrades.strength==Balance.max_level("strength"),"Permanent upgrades unchanged: "+id)
	# Final Job deliberately has no protection against curses.
	run.mode="FINAL_JOB"
	run.rules=baseline.duplicate(true)
	store.data.lucky_pending={"id":"tiny","seen":true}
	run.lucky.setup(run)
	check(run.capacity()==floori(baseline.capacity*0.7),"Tiny Van is unchanged in Final Job")
	store.data.upgrades.strength=1
	run.upgrades=store.data.upgrades.duplicate()
	store.data.lucky_pending={"id":"weak","seen":true}
	run.lucky.setup(run)
	check(run.upgrades.strength==0,"Weak Thief removes a level even at Strength 1")
	check(run.lucky.begin() and store.data.lucky_pending.is_empty(),"Effect consumed at actual start")
	# Optional block never modifies full clear, cash, cargo or blueprint counts.
	var block := LuckyEffects.spawn(world,Vector3.ZERO)
	run.cargo.clear()
	for candidate in world.items:
		if candidate.data.type_id!="lucky_block": run.cargo.append(candidate)
	run.cargo.append(block)
	check(run.standard_cargo_count()==Balance.LOCATIONS.apartment.items.size() and not run.loaded_counts().has("lucky_block"),"Optional block excluded from completion and blueprint counts")
	check(block.data.cash_value==0 and block.data.cargo_space==0,"Block has no cash/cargo cost")
	store.data.lucky_pending={"id":"curse","seen":false}
	store.session_only=false
	check(store.save_progress(),"Pending effect saved")
	var reload := SaveStore.new(store.path)
	reload.load_progress()
	check(reload.data.lucky_pending==store.data.lucky_pending,"Same outcome survives interrupted reveal")
	check(reload.validate({"lucky_pending":{"id":"invalid","seen":true}}).lucky_pending.is_empty(),"Invalid effect sanitized")
	run.free()
	world.free()
	await process_frame
	# Every map supplies reachable floor positions for the optional block.
	for location in Balance.LOCATION_ORDER:
		world=HeistLevel.new()
		root.add_child(world)
		world.setup(location,20)
		await physics_frame
		await physics_frame
		points=LuckyEffects.floor_points(world)
		check(not points.is_empty(),"Connected spawn floor: "+location)
		var route_run := RunManager.new()
		root.add_child(route_run)
		route_run.set_physics_process(false)
		store.session_only=true
		store.data.lucky_pending={"id":"route","seen":true}
		route_run.setup(world,store,location,"normal",false)
		var positions := []
		for candidate in world.items: positions.append(candidate.position)
		while not route_run.world_prepared: await physics_frame
		var moved := false
		for i in range(world.items.size()):
			if world.items[i].position!=positions[i]: moved=true
		check(moved,"Bad Route relocates loot: "+location)
		route_run.free()
		world.free()
		await process_frame
	for suffix in ["",".bak",".tmp",".daily"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path+suffix))
	print("LUCKY BLOCKS SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
