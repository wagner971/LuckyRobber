extends SceneTree


var failures := 0


func _initialize() -> void:
	call_deferred("test")


func check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		printerr("FAIL: " + message)
		failures += 1


func find_button(node: Node, label: String) -> Button:
	if node is Button and node.text == label: return node
	for child in node.get_children():
		var found := find_button(child, label)
		if found != null: return found
	return null


func find_label(node: Node, value: String) -> Label:
	if node is Label and node.text == value: return node
	for child in node.get_children():
		var found := find_label(child, value)
		if found != null: return found
	return null


func test() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(720, 1280)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/home_v2_test_profile.json")
	game.store.session_only = true
	root.add_child(game)
	await process_frame
	var backdrop = game.ui.menu.find_child("HomeWarehouseBackdrop", true, false) as TextureRect
	check(backdrop != null and backdrop.texture != null and game.ui.menu.find_child("CameraToonEffect", true, false) == null, "Home uses its nighttime backdrop with no cartoon post-process")
	check(backdrop.texture is ViewportTexture and backdrop.material is ShaderMaterial and (backdrop.material as ShaderMaterial).shader.resource_path.ends_with("home_showcase_composite.gdshader"), "Home background is the same live 3D scene as the player, with a gentle UI vignette")
	var live_viewport := game.ui.menu.find_child("LiveCharacterViewport", true, false) as SubViewport
	check(live_viewport != null and live_viewport.find_child("StreetLampKey", true, false) is DirectionalLight3D and live_viewport.find_child("NightRim", true, false) is DirectionalLight3D and live_viewport.find_child("GarageBounce", true, false) is OmniLight3D, "Home preview uses warm motivated light and a cool rear rim")
	check(live_viewport != null and live_viewport.find_child("FootContactShadow", true, false) is MeshInstance3D, "Thief has a contact shadow on the display platform")
	check(live_viewport.find_child("HomeShowcaseSet", true, false) is HomeShowcaseSet and live_viewport.find_child("PlatformMotes", true, false) is MultiMeshInstance3D, "Home has its own 3D garage and batched rising platform particles")
	check(live_viewport.find_children("PlatformUplight*", "MeshInstance3D", true, false).size() == 2, "Two visible floor projectors frame the thief")
	check(find_button(game.ui.menu, "PLAY") != null and game.ui.menu.find_child("HomeSettings", true, false) is Button, "Home keeps a clear Play action and small Settings access")
	check(find_button(game.ui.menu, "UPGRADES") != null and find_button(game.ui.menu, "COLLECTION") != null and find_button(game.ui.menu, "COSMETICS") != null, "New profile shows the available secondary destinations")
	game.ui.home(game.store)
	check(find_button(game.ui.menu, "COLLECTION") != null, "Trophy Collection remains available")
	check(find_button(game.ui.menu, "PLAY").custom_minimum_size.y > find_button(game.ui.menu, "UPGRADES").custom_minimum_size.y, "Play remains larger than the three Home shortcuts")
	check(find_button(game.ui.menu, "STATS") == null and find_button(game.ui.menu, "TROPHIES · 0/7") == null and find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS") == null, "Stats, duplicate trophy and DEV actions do not clutter Home")
	check(find_label(game.ui.menu, "FIRST JOB") != null and find_button(game.ui.menu, "START ›") == null and find_button(game.ui.menu, "PLAY").tooltip_text == "CHOOSE YOUR NEXT JOB", "Home Play always leads to job selection")
	check(find_button(game.ui.menu, "HOME") == null and find_button(game.ui.menu, "JOBS") == null, "Home uses three shortcuts instead of a duplicate bottom navigation")
	check(game.ui.menu.find_child("UpgradeNotice", true, false) == null, "Unaffordable upgrades have no red dot")
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.wallet = 1250
	game.ui.home(game.store)
	await process_frame
	check(game.ui.menu.find_child("UpgradeNotice", true, false) != null, "Affordable upgrade gets a red dot on the Home shortcut")
	check(find_label(game.ui.menu, "STEAL THE FRIDGE") != null and find_button(game.ui.menu, "UPGRADE ›") != null, "Home target uses the actual next loot and required upgrade")
	root.size = Vector2i(720, 1100)
	game.ui.home(game.store)
	await create_timer(0.12).timeout
	var target_panel := game.ui.menu.find_child("HomeTargetPanel", true, false) as Control
	check(target_panel != null and target_panel.get_global_rect().end.y <= root.get_visible_rect().size.y, "Play, shortcuts and target remain visible on compact portrait")
	check(find_button(game.ui.menu, "COSMETICS").get_global_rect().end.y < target_panel.get_global_rect().position.y, "Compact layout keeps the target below all shortcuts")
	find_button(game.ui.menu, "UPGRADE ›").pressed.emit()
	await process_frame
	check(game.screen == "shop", "Upgrade target opens the dedicated shop")
	game.action("home")
	game.store.data.objectives.apartment.cash = true
	game.store.data.objectives.apartment.signature = true
	# Isolate the van-space gate after satisfying the current speed requirements.
	for key in ["strength", "grip", "carry", "noise"]: game.store.data.upgrades[key] = Balance.required_level(key, "apartment")
	game.ui.home(game.store)
	await process_frame
	check(find_label(game.ui.menu, "STEAL EVERYTHING") != null and find_button(game.ui.menu, "UPGRADE ›") != null, "Final Job first explains the missing van space")
	find_button(game.ui.menu, "UPGRADE ›").pressed.emit()
	await process_frame
	check(game.screen == "shop" and game.ui.shop_selected_key == "capacity", "Van-space target focuses the Van upgrade")
	game.action("home")
	game.store.data.upgrades.capacity = 6
	game.ui.home(game.store)
	await process_frame
	check(find_label(game.ui.menu, "FINAL JOB READY") != null and find_button(game.ui.menu, "PLAY").tooltip_text == "CHOOSE YOUR NEXT JOB" and find_button(game.ui.menu, "START ›") == null, "Ready Final Job does not bypass job selection")
	find_button(game.ui.menu, "PLAY").pressed.emit()
	await create_timer(0.55).timeout
	check(game.screen == "locations" and not is_instance_valid(game.run), "Home Play opens Jobs even with a Final Job ready")
	game.action("home")
	game.action("settings")
	await process_frame
	check(find_button(game.ui.menu, "PROFILE & STATS") != null, "Stats moved into Settings")
	find_button(game.ui.menu, "PROFILE & STATS").pressed.emit()
	await process_frame
	check(game.screen == "stats", "Profile shortcut opens the existing stats page")
	game.action("settings")
	check(find_button(game.ui.menu, "DEV TOOLS ▾") != null and find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS") != null and not find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS").is_visible_in_tree(), "DEV controls start collapsed in Settings")
	find_button(game.ui.menu, "DEV TOOLS ▾").pressed.emit()
	check(find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS").is_visible_in_tree(), "Developer drawer exposes the existing max-all tool")
	find_button(game.ui.menu, "DEV · MAX ALL + UNLOCK ALL LEVELS").pressed.emit()
	await process_frame
	check(Progression.upgrades_maxed(game.store.data) and game.screen == "settings", "Max-all still works from Settings")
	game.ui.development_mode = false
	game.ui.settings_page(game.store, false)
	check(find_button(game.ui.menu, "DEV TOOLS ▾") == null, "Production Settings have no developer drawer")
	game.free()
	await process_frame
	await process_frame
	print("HOME V2: %d failures" % failures)
	quit(1 if failures else 0)
