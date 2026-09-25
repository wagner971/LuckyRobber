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
	var store := SaveStore.new("res://tests/level_gifts_profile.json")
	store.session_only = true
	for key in Balance.UPGRADE_KEYS: store.data.upgrades[key] = Balance.max_level(key)
	check(not store.data.has("getaway_progress"),"Three-escape tracker removed from profiles")
	for location in Balance.LOCATION_ORDER:
		var counts := {}
		for item in Balance.LOCATIONS[location].items: counts[item[1]] = counts.get(item[1],0)+1
		var normal := Progression.settle(store.data,location,"normal",counts,[],int(Balance.LOCATIONS[location].expected_value),false,30)
		check(normal.level_gift.is_empty(),"Partial escape does not award a level gift: "+location)
		var mode := "FINAL_JOB" if location in ["apartment","museum"] else "normal"
		var complete := Progression.settle(store.data,location,mode,counts,[],int(Balance.LOCATIONS[location].expected_value),true,30)
		check(not complete.level_gift.is_empty() and store.data.level_gifts.has(location),"First location completion awards one gift: "+location)
		var rarity: int = store.data.level_gifts[location].rarity
		var repeat := Progression.settle(store.data,location,mode,counts,[],int(Balance.LOCATIONS[location].expected_value),true,30)
		check(repeat.level_gift.is_empty() and store.data.level_gifts[location].rarity == rarity,"Replay cannot reroll or award another gift: "+location)
	check(store.data.cosmetics.equipped.van == "" and store.data.diamonds == 0,"Prototype gifts do not grant diamonds or equip placeholder skins")
	store.session_only = false
	check(store.save_progress(),"Level gifts save with progression")
	var reloaded := SaveStore.new(store.path)
	reloaded.load_progress()
	check(reloaded.data.level_gifts == store.data.level_gifts and not LevelGifts.pending(reloaded.data).is_empty(),"Interrupted reveal resumes with the same saved rarity")
	var legacy := store.defaults()
	legacy.schema_version = 14
	legacy.wallet = 8765
	legacy.getaway_progress = 2
	legacy.erase("level_gifts")
	var file := FileAccess.open(store.path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	reloaded.load_progress()
	check(reloaded.data.wallet == 8765 and not reloaded.data.has("getaway_progress") and FileAccess.file_exists(store.path+".schema14.bak"),"Migration keeps cash and removes the old streak without a payout")
	var production := SaveStore.new()
	production.session_only = true
	check(not production.claim_daily_gift(200000).is_empty() and production.claim_daily_gift(200000).is_empty(),"Production daily gift retains its 24-hour limit")
	check(not production.claim_daily_spin(200000,0).is_empty() and production.claim_daily_spin(200000,0).is_empty(),"Production wheel retains one spin per UTC day")
	production.dev_rewards_unlimited = true
	for i in range(4):
		check(not production.claim_daily_gift(200000).is_empty() and not production.claim_daily_spin(200000,0).is_empty(),"DEV repeat gift and spin %d" % i)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	root.add_child(game)
	game.action("daily_gift")
	check(is_instance_valid(game.ui.gift_reveal) and game.ui.gift_reveal.daily,"Daily reward opens a 3D gift")
	var daily: GiftReveal = game.ui.gift_reveal
	var cash: int = game.store.data.wallet
	game.action("daily_gift")
	check(game.store.data.wallet == cash,"Double tap cannot claim through an active reveal")
	daily.elapsed = 1.9
	daily.update_visual()
	daily.claim.pressed.emit()
	check(is_instance_valid(game.ui.gift_reveal) and not game.ui.gift_reveal.daily,"DEV daily claim follows with the prototype level gift")
	var reveal: GiftReveal = game.ui.gift_reveal
	reveal.elapsed = 3.9
	reveal.update_visual()
	check(not reveal.revealed and reveal.question.visible and not reveal.claim.visible,"Rarity keeps cycling until three seconds after card emergence")
	reveal.elapsed = 4.1
	reveal.update_visual()
	check(reveal.revealed and not reveal.question.visible and reveal.claim.visible,"Final rarity and continue appear after three seconds")
	reveal.claim.pressed.emit()
	check(not is_instance_valid(game.ui.gift_reveal) and game.store.data.level_gifts.is_empty(),"DEV preview closes without consuming a location gift")
	game.development_mode = false
	game.store.dev_rewards_unlimited = false
	game.store.data.heist_briefing_seen = true
	game.store.data.unlocked.append("house")
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.max_level(key)
	game.start_run("house")
	await physics_frame
	game.run.started = true
	game.run.remaining = 30
	for item in game.level.items: game.run.cargo.append(item)
	game.run.cargo_value = int(Balance.LOCATIONS.house.expected_value)
	game.run.finish(true)
	check(game.last_result.level_gift.location == "house" and game.store.data.level_gifts.has("house"),"Actual full-clear settlement grants and saves the location gift")
	await create_timer(1.3).timeout
	check(is_instance_valid(game.ui.gift_reveal) and not game.ui.gift_reveal.daily,"Level gift opens after Results cash count-up")
	game.ui.gift_reveal.elapsed = 4.2
	game.ui.gift_reveal.update_visual()
	game.ui.gift_reveal.claim.pressed.emit()
	check(game.store.data.level_gifts.house.seen and LevelGifts.pending(game.store.data).is_empty(),"Acknowledging a real gift clears only the pending presentation")
	game.cleanup_run()
	game.free()
	await process_frame
	for suffix in ["", ".bak", ".tmp", ".daily", ".schema14.bak"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path+suffix))
	print("LEVEL GIFTS SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
