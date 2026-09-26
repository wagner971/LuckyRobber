extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run_test")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + message)

func run_test() -> void:
	LocalLog.enabled = false
	var store := SaveStore.new("res://tests/vehicle_profile.json")
	store.session_only = true
	store.data.wallet = 1000000
	store.data.diamonds = 42
	var upgrades: Dictionary = store.data.upgrades.duplicate(true)
	# Prices follow each vehicle's rarity (Balance.RARITY_PRICES).
	var prices := [8000,15000,15000,50000,50000,120000,120000,120000]
	var details := ["BlackWindow","BedRail","BoxRib","ArmorPanel","PanoramaGlass","HearseGlass","PirateSkull","PharaohCrown"]
	var van := LootVan.new()
	root.add_child(van)
	van.setup(6)
	var anchor := van.cargo_anchor
	var cargo := Node3D.new()
	anchor.add_child(cargo)
	var transform := van.model.transform
	var load_point: Vector3 = van.load_position
	for i in range(Balance.VEHICLE_ORDER.size()):
		var id: String = Balance.VEHICLE_ORDER[i]
		var config: Dictionary = Balance.COSMETICS[id]
		var day := PlayRewards.shop_pool().find(id) * 86400
		check(Balance.cosmetic_price(id) == prices[i] and Balance.RARITY_PRICES[config.rarity] == prices[i], id + " is priced by its rarity")
		check(not store.purchase_cosmetic(id,false,day,true), "No in-run purchase: " + id)
		var wallet: int = store.data.wallet
		check(store.purchase_cosmetic(id,true,day,true), "Featured purchase succeeds: " + id)
		check(store.data.wallet == wallet-prices[i] and store.data.diamonds == 42, "Only the exact cash price is deducted: " + id)
		check(store.data.cosmetics.equipped.van == id and not store.purchase_cosmetic(id,true,day,true), "Equipped once, cannot buy twice: " + id)
		van.set_vehicle(config.vehicle_style)
		check(not VehicleModels.parts(van.model,details[i]).is_empty(), "Distinct model detail: " + id)
		check(van.cargo_anchor == anchor and cargo.get_parent() == anchor and van.model.transform == transform and van.load_position == load_point, "Cargo and loading orientation preserved: " + id)
		if id == "vehicle_pickup":
			var hinges := VehicleModels.parts(van.model,"RearDoorHinge")
			check(hinges.size() == 2 and not hinges[0].visible and not hinges[1].visible, "Pickup removes both tall cargo doors")
			var sides := VehicleModels.parts(van.model,"CargoSide")
			check(sides.size() == 2 and is_equal_approx((sides[0].mesh as BoxMesh).size.y,0.5) and is_equal_approx((sides[1].mesh as BoxMesh).size.y,0.5), "Pickup has two lowered sides")
	check(store.data.upgrades == upgrades, "Cosmetics never modify upgrades or capacity")
	store.session_only = false
	check(store.save_progress(), "Vehicle ownership saves")
	var reloaded := SaveStore.new(store.path)
	reloaded.load_progress()
	check(reloaded.data.cosmetics.owned == store.data.cosmetics.owned and reloaded.data.cosmetics.equipped.van == "vehicle_pharaoh", "Vehicles and equipped skin survive relaunch")
	check(reloaded.equip_cosmetic("vehicle_black",true), "Owned vehicle can be equipped outside its daily offer")
	var blocked := SaveStore.new()
	blocked.data.wallet = 1000000
	blocked.read_only = true
	var before := blocked.data.duplicate(true)
	check(not blocked.purchase_cosmetic("vehicle_black",true,0,true) and blocked.data == before, "Save failure rolls back charge, ownership and equip")
	van.set_vehicle("")
	check(VehicleModels.parts(van.model,"PharaohCrown").is_empty() and van.cargo_anchor == anchor, "Default shell restored without losing cargo")
	van.free()
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.wallet = 1000000
	root.add_child(game)
	game.open_menu("cosmetics")
	var offer := ""
	for id in PlayRewards.today_shop():
		if id in Balance.VEHICLE_ORDER: offer = id; break
	if offer != "":
		game.action("vehicle_preview:" + offer)
		check(game.screen == "vehicle", "Today's Shop opens the vehicle preview")
		game.cosmetic_action(offer,"buy")
		check(game.store.data.cosmetics.equipped.van == offer and game.ui.vehicle_buy.disabled, "Preview purchase equips the vehicle and updates the UI")
	else:
		game.store.data.cosmetics.owned.append("vehicle_pickup")
		game.store.equip_cosmetic("vehicle_pickup",true)
	game.start_run("apartment")
	await physics_frame
	check(game.level.van.vehicle_style == Balance.COSMETICS[game.store.data.cosmetics.equipped.van].vehicle_style, "Equipped shell appears in the actual heist")
	game.cleanup_run()
	game.free()
	await process_frame
	for suffix in ["", ".bak", ".tmp", ".daily"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path + suffix))
	print("VEHICLE SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
