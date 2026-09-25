extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("test")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + label)

func fresh() -> SaveStore:
	var store := SaveStore.new("res://tests/lucky_loop_profile.json")
	store.session_only = true
	return store

func test() -> void:
	LocalLog.enabled = false
	seed(7)
	var store := fresh()
	var data := store.data
	check(data.lucky_meter == 0 and data.lucky_tokens == 0 and data.lucky_owned.is_empty() and data.upgrade_tokens == 0, "New profile starts with an empty meter, no tokens and nothing owned")
	# Meter math
	check(LuckyMeter.gain_for({"success": false}) == LuckyMeter.FAILURE_GAIN, "A bust still adds a little meter")
	check(LuckyMeter.gain_for({"success": true, "items": 4, "new_objectives": [], "full_clear": false}) == LuckyMeter.BASE_SUCCESS + 4, "Success pays base plus one per item")
	check(LuckyMeter.gain_for({"success": true, "items": 30, "new_objectives": ["x"], "full_clear": true}) == LuckyMeter.BASE_SUCCESS + LuckyMeter.MAX_ITEM_GAIN + LuckyMeter.OBJECTIVE_GAIN + LuckyMeter.FULL_CLEAR_GAIN, "Item gain is capped; objectives and full clears add fixed bonuses")
	var runs := 0
	var awarded := false
	while not awarded and runs < 20:
		var outcome := LuckyMeter.settle(data, {"success": true, "items": 6, "new_objectives": [], "full_clear": false})
		awarded = outcome.awarded
		runs += 1
	check(awarded and runs == 5, "Five ordinary heists fill the meter and award a block (got %d)" % runs)
	check(not data.lucky_pending.is_empty() and not data.lucky_pending.seen and data.lucky_pending.source == "meter", "Meter block waits for its reveal like a heist block")
	check(data.lucky_tokens == int(data.lucky_pending.tokens) and data.lucky_tokens >= 1, "The block pays Lucky Tokens the moment it is granted")
	check(data.lucky_meter == 5, "Overflow carries into the next charge")
	# A second full charge waits while a block is still pending
	data.lucky_meter = 99
	var blocked := LuckyMeter.settle(data, {"success": true, "items": 1, "new_objectives": [], "full_clear": false})
	check(not blocked.awarded and data.lucky_meter == LuckyMeter.TARGET, "A full meter holds at 100 while a reveal is pending")
	data.lucky_pending = {}
	var released := LuckyMeter.settle(data, {"success": false})
	check(released.awarded and data.lucky_meter == LuckyMeter.FAILURE_GAIN, "The held charge pays out on the next settled run")
	# Tokens: positive vs negative outcomes
	check(LuckyMeter.tokens_for("magnet") == 1 and LuckyMeter.tokens_for("noise") == 2, "Unlucky outcomes pay double tokens")
	# Shop
	data.lucky_pending = {}
	data.lucky_tokens = 3
	check(not LuckyShop.can_buy(data, "load_gold"), "Four-token reward is out of reach with three tokens")
	check(LuckyShop.buy(data, "block_gold") and data.lucky_tokens == 0 and LuckyShop.owned(data, "block_gold") and LuckyShop.equipped(data, "block_skin") == "block_gold", "Buying a block skin owns and equips it")
	check(not LuckyShop.can_buy(data, "block_gold"), "Permanent rewards are bought once")
	check(LuckyShop.block_color(data) == Color("f2b930"), "Equipped skin drives the block colour")
	check(LuckyShop.equip(data, "block_gold") and LuckyShop.equipped(data, "block_skin") == "", "Tapping an equipped skin unequips it")
	data.lucky_tokens = 30
	check(LuckyShop.buy(data, "upgrade_token") and LuckyShop.buy(data, "upgrade_token") and data.upgrade_tokens == 2, "Upgrade tokens stack and stay buyable")
	check(LuckyShop.buy(data, "diamonds_5") and data.diamonds == 5, "Diamond pack pays out immediately")
	check(LuckyShop.buy(data, "suit_lucky") and "suit_lucky" in data.cosmetics.owned and store.equip_cosmetic("suit_lucky", true), "Lucky suit joins the wardrobe and can be equipped")
	check(LuckyShop.buy(data, "vehicle_lucky") and "van_lucky" in data.cosmetics.owned, "Lucky van joins the wardrobe")
	check(not LuckyShop.buy(data, "missing"), "Unknown rewards are refused")
	# Upgrade token spends a free level and respects caps
	data.upgrades.grip = 1
	data.wallet = 0
	var used := store.purchase("grip", true)
	check(used and data.upgrades.grip == 2 and data.upgrade_tokens == 1 and data.wallet == 0, "A free upgrade token buys a level without cash")
	data.upgrades.grip = Balance.purchase_cap("grip", data)
	check(not store.purchase("grip", true) and data.upgrade_tokens == 1, "Tokens cannot bypass tier caps")
	# Persistence
	var disk := SaveStore.new("res://tests/lucky_loop_disk.json")
	disk.data = data.duplicate(true)
	disk.data.lucky_meter = 42
	disk.data.lucky_tokens = 7
	disk.save_progress()
	var back := SaveStore.new(disk.path)
	back.load_progress()
	check(back.data.lucky_meter == 42 and back.data.lucky_tokens == 7 and back.data.upgrade_tokens == 1 and back.data.lucky_owned == ["block_gold"] and back.data.lucky_equipped.block_skin == "", "Meter, tokens, ownership and equips survive a reload")
	var invalid := back.validate({"lucky_meter": 999, "lucky_tokens": -4, "lucky_owned": ["block_gold", "nope", "block_gold"], "lucky_equipped": {"block_skin": "block_neon"}, "upgrade_tokens": 3})
	check(invalid.lucky_meter == LuckyMeter.TARGET and invalid.lucky_tokens == 0 and invalid.lucky_owned == ["block_gold"] and invalid.lucky_equipped.block_skin == "" and invalid.upgrade_tokens == 3, "Validation clamps the meter, drops unknown rewards and unequips unowned skins")
	# Full run settlement through the round authority
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = fresh()
	game.store.data.tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.lucky_meter = 90
	root.add_child(game)
	game.start_run("apartment")
	game.run.set_physics_process(false)
	while not game.run.world_prepared: await physics_frame
	game.run.phase = RunManager.Phase.ACTIVE
	game.run.remaining = 30
	game.run.cargo.append(game.level.items[0])
	game.run.cargo_value = 140
	game.run.finish(true)
	check(game.last_result.has("lucky_meter") and game.last_result.lucky_meter.awarded and not game.store.data.lucky_pending.is_empty(), "Escaping with a nearly full meter grants a Lucky Block on Results")
	check(game.store.data.last_location == "apartment", "The last heist is remembered for PLAY NOW")
	game.free()
	print("LUCKY LOOP: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
