extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run_test")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ")+message)
func run_test() -> void:
	LocalLog.enabled = false
	var store := SaveStore.new("res://tests/garage_profile.json")
	store.session_only = true
	check(store.data.garage_owned.is_empty(),"Fresh profile starts with no purchased decor")
	check(not store.purchase_garage("sofa",true),"Insufficient cash cannot buy decor")
	store.data.wallet = 200000
	store.data.diamonds = 50
	var upgrades: Dictionary = store.data.upgrades.duplicate(true)
	var prices := [2000,4000,7500,12000,15000,25000,40000,50000]
	var room := GarageDecor.new()
	root.add_child(room)
	room.build([])
	check(room.props.get_child_count() == 0 and room.has_node("StarterTable"),"Starter garage contains only base furnishing")
	for i in range(GarageDecor.CATALOG.size()):
		var id: String = GarageDecor.CATALOG.keys()[i]
		check(GarageDecor.CATALOG[id].price == prices[i],"Exact requested price: "+id)
		check(not store.purchase_garage(id,false),"No mid-heist purchase: "+id)
		var cash: int = store.data.wallet
		check(store.purchase_garage(id,true) and store.data.wallet == cash-prices[i],"Atomic cash purchase: "+id)
		check(not store.purchase_garage(id,true),"No duplicate charge: "+id)
	room.build(store.data.garage_owned)
	check(room.props.get_child_count() == 7,"All seven furniture models placed once; floor handled separately")
	check(store.data.upgrades == upgrades and store.data.diamonds == 50,"Decor never changes stats or diamonds")
	store.session_only = false
	check(store.save_progress(),"Garage ownership saves")
	var restored := SaveStore.new(store.path)
	restored.load_progress()
	check(restored.data.garage_owned == store.data.garage_owned,"All purchases survive relaunch")
	var legacy := store.defaults()
	legacy.schema_version = 13
	legacy.erase("garage_owned")
	legacy.wallet = 12345
	var file := FileAccess.open(store.path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	restored.load_progress()
	check(restored.data.wallet == 12345 and restored.data.garage_owned.is_empty() and FileAccess.file_exists(store.path+".schema13.bak"),"Schema 13 migrates with preserved cash and a backup")
	var blocked := SaveStore.new()
	blocked.data.wallet = 50000
	blocked.read_only = true
	var snapshot := blocked.data.duplicate(true)
	check(not blocked.purchase_garage("sofa",true) and blocked.data == snapshot,"Failed save rolls back cash and decor")
	check(store.validate({"garage_owned":["sofa","sofa","bad",12]}).garage_owned == ["sofa"],"Malformed ownership is sanitized")
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new()
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.wallet = 50000
	root.add_child(game)
	game.action("collection")
	check(game.screen == "garage" and game.ui.garage_live_preview.garage.props.get_child_count() == 0,"Collection opens the starter Garage")
	game.ui.garage_selected = "sofa"
	game.ui.refresh_garage_selection(game.store)
	check(game.screen == "garage" and game.ui.garage_live_preview.garage.props.has_node("Decor_sofa") and game.store.data.garage_owned.is_empty(),"Shop preview does not grant ownership")
	game.action("garage_buy:sofa")
	check(game.store.data.wallet == 48000 and game.ui.garage_buy.disabled,"Real UI purchase charges once and marks placed")
	game.action("home")
	var home_preview: MenuCharacterPreview
	for preview in get_nodes_in_group("menu_character_previews"):
		if preview is MenuCharacterPreview and preview.presentation == "home" and preview.is_visible_in_tree(): home_preview = preview
	check(is_instance_valid(home_preview) and not is_instance_valid(home_preview.garage) and is_instance_valid(home_preview.home_set),"Original Home podium is restored and separate from Garage")
	game.action("garage")
	check(game.ui.garage_live_preview.garage.props.has_node("Decor_sofa"),"Purchased furniture remains in Garage when returning")
	game.free()
	room.free()
	await process_frame
	for suffix in ["", ".bak", ".tmp", ".daily", ".schema13.bak"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path+suffix))
	print("GARAGE SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
