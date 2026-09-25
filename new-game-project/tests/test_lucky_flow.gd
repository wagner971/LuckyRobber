extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS: " if ok else "FAIL: ")+label)
func run_test() -> void:
	LocalLog.enabled=false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store=SaveStore.new()
	game.store.session_only=true
	game.store.data.tutorial_completed=true
	game.store.data.heist_briefing_seen=true
	game.store.data.unlocked.append("house")
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key]=Balance.max_level(key)
	root.add_child(game)
	game.start_run("house")
	game.run.set_physics_process(false)
	while not game.run.world_prepared: await physics_frame
	var block := LuckyEffects.spawn(game.level,game.level.player.position)
	game.run.phase=RunManager.Phase.ACTIVE
	game.run.remaining=50
	game.run.target=block
	game.run.commit_pickup()
	game.level.player.position=game.level.van.load_position
	game.run.carried.state=LootItem.State.LOADING
	game.run.lucky.id="loud_load"
	game.run.commit_load()
	check(game.run.lucky.collected and game.run.cargo_used==0 and game.run.cargo_value==0,"Block is loaded without using cargo or cash")
	check(game.run.current_noise==4,"Loud Load adds real alarm noise")
	for item in game.level.items:
		if item.data.type_id!="lucky_block":
			game.run.cargo.append(item)
			game.run.cargo_value+=int(item.data.cash_value)
	game.run.lucky.id="haul"
	var earned: int=game.run.cargo_value
	game.run.finish(true)
	check(game.last_result.full_clear and game.last_result.items==Balance.LOCATIONS.house.items.size(),"Full Clear counts standard loot with a bonus block on board")
	check(game.last_result.earned>=roundi(earned*1.5),"Big Haul pays 50% extra loot cash")
	check(not game.store.data.lucky_pending.is_empty() and not game.store.data.lucky_pending.seen,"Success persists a single unrevealed effect")
	var awarded: String=game.store.data.lucky_pending.id
	await create_timer(1.3).timeout
	check(game.ui.gift_reveal is LuckyReveal,"Lucky effect appears after success Results")
	var reveal: LuckyReveal=game.ui.gift_reveal
	reveal.elapsed=2.2
	reveal.update_visual()
	check(reveal.claim.visible and reveal.revealed,"Short reveal reaches Continue")
	reveal.claim.pressed.emit()
	check(game.store.data.lucky_pending.seen and game.store.data.lucky_pending.id==awarded,"Acknowledge keeps the same next-run effect")
	await create_timer(1.3).timeout
	check(is_instance_valid(game.ui.gift_reveal) and not game.ui.gift_reveal is LuckyReveal,"Level-completion gift follows without overlaying Lucky reveal")
	game.ui.gift_reveal.elapsed=4.2
	game.ui.gift_reveal.update_visual()
	game.ui.gift_reveal.claim.pressed.emit()
	game.start_run("house")
	game.run.set_physics_process(false)
	game.level.player.set_physics_process(false)
	while not game.run.world_prepared: await physics_frame
	check(game.run.lucky.id==awarded and not game.store.data.lucky_pending.is_empty(),"Preparing a run keeps effect until movement")
	game.run.intention=Vector2.RIGHT
	game.run._physics_process(0.016)
	check(game.store.data.lucky_pending.is_empty(),"First movement consumes effect")
	game.run.lucky.collected=true
	game.run.finish(false)
	check(game.store.data.lucky_pending.is_empty(),"Busted loses block and does not restore consumed effect")
	game.start_run("house")
	check(game.run.lucky.id=="","Following run returns to standard rules")
	game.cleanup_run()
	game.free()
	await process_frame
	print("LUCKY FLOW SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
