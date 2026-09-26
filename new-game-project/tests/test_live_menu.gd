extends "res://tests/test_ui_v2.gd"

var game: Node
var test_finished := false

# Fail-safe: any missing button/node reports a failed check and quits with a
# non-zero status instead of letting a null dereference (e.g. a stale button
# label after a UI text change) abort the test() coroutine silently and leave
# the SceneTree idling/rendering forever with no one left to call quit().
func fail_fast(reason: String) -> void:
	if test_finished: return
	test_finished = true
	check(false, reason)
	print("LIVE MENU SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1)

func get_button(label: String) -> Button:
	var b = find_button(game.ui.root, label)
	if b == null:
		fail_fast("Missing button '%s' on screen '%s' — aborting instead of crashing on a null reference." % [label, game.screen])
	return b

func press_button(label: String) -> void:
	var b = get_button(label)
	if b != null: b.pressed.emit()

func find_subviewports(node: Node, out: Array) -> void:
	if node is SubViewport: out.append(node)
	for child in node.get_children(): find_subviewports(child, out)

func preview() -> MenuCharacterPreview:
	for node in get_nodes_in_group("menu_character_previews"):
		if node is MenuCharacterPreview and not node.is_queued_for_deletion() and node.is_visible_in_tree(): return node
	return null

func shot(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	game.ui.set_previews_active(true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/menu_"+label+".png")

func new_game(reload_data: bool = false) -> Node:
	var node = load("res://scenes/main.tscn").instantiate()
	node.store = SaveStore.new("res://tests/live_menu_profile.json")
	if reload_data: node.store.load_progress()
	else:
		node.store.data.tutorial_completed = true
		node.store.data.noise_tutorial_completed = true
		node.store.data.successes = 4
		node.store.data.first_job_at = 1
		node.store.data.wallet = 42500
		node.store.data.cosmetics.owned = ["suit_plum","set_midnight","set_sunrise","van_mint","van_coral"]
	root.add_child(node)
	return node

func test() -> void:
	var watchdog := create_timer(60.0)
	watchdog.timeout.connect(func():
		if not test_finished: fail_fast("Watchdog: test() did not finish within 60s (unhandled error or a stuck await).")
	)
	LocalLog.enabled = false
	game = new_game()
	await process_frame
	game.ui.set_previews_active(true)
	var hero = preview()
	check(game.screen == "home" and hero != null and hero.actor is ThiefVisual, "Home starts with actual live blocky player model")
	check(hero.viewport.own_world_3d and hero.viewport.get_texture() == hero.texture.texture, "Home displays isolated live3D viewport, no sprite")
	check(find_button(game.ui.menu,"PLAY") != null and game.ui.menu.find_child("HomeSettings",true,false) is Button, "Home exposes dominant PLAY and real Settings")
	var time_before = hero.actor.clock
	await create_timer(0.12).timeout
	check(hero.actor.clock > time_before and hero.rendered_frames > 0, "Menu actor visibly animates while waiting")
	check(hero.viewport.size.x <= 576 and hero.viewport.size.y <= 1152, "Full-screen Home render resolution bounded for mobile")
	await shot("home")
	for dimensions in [Vector2i(720,1280),Vector2i(720,1600),Vector2i(720,1100)]:
		root.size = dimensions
		await process_frame
		await process_frame
		var play = get_button("PLAY")
		if play == null: return
		check(play.get_global_rect().end.y <= game.ui.root.size.y and game.ui.menu.size.x <= game.ui.root.size.x + 1, "Home PLAY fits portrait " + str(dimensions))
	root.size = Vector2i(450,800)
	await process_frame
	# Home's own button is "LOCKER" (it used to say "COLLECTION" before the
	# nav-bar COLLECTION->trophies routing fix; that label now belongs to the
	# persistent nav bar's real Trophy Collection tab, tested further below).
	press_button("LOCKER")
	await process_frame
	hero = preview()
	check(game.screen == "cosmetics" and hero != null and hero.presentation == "collection", "Collection has a dedicated visible live preview")
	var same_actor = hero.actor
	var skin = hero.actor.head.get_child(0).material_override.albedo_color
	game.cosmetic_action("suit_plum","equip")
	check(hero.actor == same_actor and hero.actor.tint_parts[0].material_override.albedo_color == Color("945bca"), "EquipA updates SAME preview actor immediately")
	check(hero.actor.head.get_child(0).material_override.albedo_color == skin, "Outfit tint preserves skin and face")
	check(all_text(game.ui.menu).contains("EQUIPPED · PLUM SUIT"), "Collection selection clearly identifies current outfit")
	await shot("collection_plum")
	game.cosmetic_action("set_midnight","equip")
	check(hero.actor.tint_parts[0].material_override.albedo_color == Color("5481ba") and hero.van.model.get_child(1).material_override.albedo_color == Color("5481ba"), "EquipB updates both character and van through existing set rules")
	var saved = SaveStore.new(game.store.path)
	saved.load_progress()
	check(saved.data.cosmetics.equipped.set == "set_midnight", "OutfitB saved immediately")
	game.cosmetic_action("van_mint","equip")
	check(hero.actor.tint_parts[0].material_override.albedo_color == hero.actor.original_tints[0] and hero.van.model.get_child(1).material_override.albedo_color == Color("70dabc"), "Individual van clears set, restores original suit, applies mint")
	game.cosmetic_action("suit_plum","equip")
	check(hero.actor.tint_parts[0].material_override.albedo_color == Color("945bca") and hero.van.model.get_child(1).material_override.albedo_color == Color("70dabc"), "Independent suit and van can combine without desync")
	game.cosmetic_action("","reset")
	check(hero.actor.tint_parts[0].material_override.albedo_color == hero.actor.original_tints[0] and hero.van.model.get_child(1).material_override.albedo_color == Color("ffbd59"), "Original look resets SAME rig and van, no stale colors")
	game.cosmetic_action("set_midnight","equip")
	await shot("collection_midnight")
	var expected_color = hero.actor.tint_parts[0].material_override.albedo_color
	game.action("shop")
	await process_frame
	check(preview() != null and preview().presentation == "upgrades" and preview().actor.tint_parts[0].material_override.albedo_color == expected_color, "Upgrades reuses live appearance and component")
	await shot("upgrades")
	game.action("home")
	await process_frame
	check(preview().actor.tint_parts[0].material_override.albedo_color == expected_color, "Home reflects equippedB after menu navigation")
	await shot("home_midnight")
	var before_progress = game.store.data.duplicate(true)
	game.ui.set_previews_active(false)
	hero = preview()
	time_before = hero.actor.clock
	await create_timer(0.1).timeout
	check(hero.actor.clock == time_before and hero.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED, "Background suspends menu animation and rendering")
	game.ui.set_previews_active(true)
	await create_timer(0.08).timeout
	check(hero.actor.clock > time_before, "Foreground resumes menu preview")
	check(game.store.data == before_progress, "Presentation does not change wallet, scheduler or progression")
	# Real pointer input is intentionally blocked during the menu reveal.
	await create_timer(0.32).timeout
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = hero.get_global_rect().get_center()
	press.pressed = true
	root.push_input(press,true)
	press.pressed = false
	root.push_input(press,true)
	check(game.ui.input.pointer == -1 and game.screen == "home", "3D hero clicks cannot start joystick or gameplay")
	var play_button = get_button("PLAY")
	if play_button == null: return
	press.position = play_button.get_global_rect().get_center()
	press.pressed = true
	root.push_input(press,true)
	press.pressed = false
	root.push_input(press,true)
	await process_frame
	for frame in range(120):
		if preview() == null: break
		await process_frame
	check(game.screen == "locations" and preview() == null, "Real viewport click on PLAY opens Jobs and releases preview")
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(game.screen == "home", "Android Back from Jobs returns Home")
	game.action("locations")
	SpecialJobs.make_pending(game.store.data,"apartment")
	game.action("locations")
	await shot("jobs_special")
	press_button("PLAY  ▶")
	for frame in range(120):
		if game.run != null: break
		await process_frame
	check(game.run != null and game.run.mode == "normal" and game.level.player.visual.tint_parts[0].material_override.albedo_color == expected_color and game.level.van.model.get_child(1).material_override.albedo_color == expected_color, "Gameplay player and van match menu outfitB exactly")
	check(get_nodes_in_group("menu_character_previews").is_empty(), "No menu preview nodes remain during gameplay")
	for frame in range(120):
		if not game.ui.motion.travelling: break
		await process_frame
	game.action("locations")
	game.store.save_progress()
	game.free()
	await process_frame
	game = new_game(true)
	await process_frame
	check(game.store.data.cosmetics.equipped.set == "set_midnight" and preview().actor.tint_parts[0].material_override.albedo_color == expected_color, "New game instance reloads outfitB into Home preview")
	await shot("home_pending")
	game.action("settings")
	check(find_button(game.ui.menu,"SOUND · ON") != null or find_button(game.ui.menu,"SOUND · OFF") != null, "Settings has a functional audio control")
	var old_muted = game.sound_muted
	game.action("toggle_sound")
	check(game.sound_muted != old_muted and AudioServer.is_bus_mute(0) == game.sound_muted, "Settings changes actual audio state")
	var remembered = game.sound_muted
	game.load_preferences()
	check(game.sound_muted == remembered, "Sound preference persists separately from progression")
	game.action("toggle_sound")
	game.action("stats")
	check(all_text(game.ui.menu).contains("ESCAPES") and all_text(game.ui.menu).contains("OBJECTIVES"), "Stats displays actual saved progress")
	game.action("home")
	for frame in range(120):
		if not is_instance_valid(game.ui.motion.outgoing): break
		await process_frame
	await process_frame
	var count = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for i in range(8):
		for destination in ["cosmetics","shop","locations","home"]:
			game.action(destination)
			await process_frame
	for frame in range(120):
		if not is_instance_valid(game.ui.motion.outgoing): break
		await process_frame
	await process_frame
	check(get_nodes_in_group("menu_character_previews").size() == 1, "Repeated navigation keeps exactly one preview")
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) == count, "32menu transitions release old models, viewports and signals")
	game.free()
	await process_frame
	check(get_nodes_in_group("menu_character_previews").is_empty(), "Preview lifecycle ends cleanly with main scene")

	# --- COLLECTION/COSMETICS navigation fix + trophy notification regression ---
	game = new_game()
	await process_frame
	press_button("LOCKER")
	await process_frame
	check(game.screen == "cosmetics", "COSMETICS still opens the cosmetics screen separately (B)")
	press_button("COLLECTION")
	await process_frame
	check(game.screen == "collection" and all_text(game.ui.menu).contains("TROPHY SHELF"), "Persistent nav COLLECTION opens the trophy shelf (A)")
	check(game.screen == "collection", "Collection itself is now the trophy shelf")
	var viewports: Array = []
	find_subviewports(game.ui.menu, viewports)
	check(viewports.size() == Balance.TROPHIES.size(), "Trophy shelf builds one 3D preview per trophy")
	var always_on = 0
	for vp in viewports:
		if vp.render_target_update_mode == SubViewport.UPDATE_ALWAYS: always_on += 1
	check(always_on == 0, "No trophy preview stays continuously UPDATE_ALWAYS (I)")
	press_button("JOBS")
	await process_frame
	check(game.screen == "locations", "Trophy Collection nav bar can leave the screen, not a dead end (C)")
	game.action("home")
	await process_frame

	var wallet_before = game.store.data.wallet
	var trophies_before = game.store.data.trophies.duplicate()
	var fake_result = {
		"success": true, "abandoned": false, "mode": "normal",
		"earned": 0, "loot_value": 0, "rush_bonus": 0, "lost": 0,
		"items": 0, "elapsed": 1.0, "full_clear": false, "bonus": 0,
		"new_objectives": [], "new_trophies": ["Pink Flamingo"],
		"unlocked_locations": [], "contract_met": false, "contract_bonus": 0,
		"new_cosmetics": [], "special_unlocked": false, "special_type": "",
		"tutorial": false, "saved": true,
	}
	game.on_ended(fake_result)
	check(not is_instance_valid(game.ui.trophy_modal), "Results keeps the trophy out of a blocking popup")
	await create_timer(0.9).timeout
	await process_frame
	check(not is_instance_valid(game.ui.trophy_modal), "Reward count-up finishes without a trophy popup (D)")
	var modal_text = all_text(game.ui.menu)
	check(modal_text.contains("NEW TROPHY") and modal_text.contains("PINK FLAMINGO"), "Trophy is integrated into Results")
	var trophy_previews: Array = []
	find_subviewports(game.ui.menu, trophy_previews)
	check(trophy_previews.size() >= 1, "Result trophy uses a live 3D model")
	check(game.store.data.wallet == wallet_before and game.store.data.trophies == trophies_before, "Showing the notification does not touch wallet or trophy data (H)")
	game.action("trophies")
	await process_frame
	check(game.screen == "trophies" and not is_instance_valid(game.ui.trophy_modal), "Trophy Collection remains accessible (E)")

	game.action("home")
	await process_frame
	var repeat_result = fake_result.duplicate(true)
	repeat_result.new_trophies = []
	game.on_ended(repeat_result)
	await process_frame
	check(not all_text(game.ui.menu).contains("NEW TROPHY"), "Re-acquiring an already-owned trophy does not show NEW TROPHY again (F)")
	game.on_ended(fake_result)
	game.action("home")
	await create_timer(0.9).timeout
	check(not is_instance_valid(game.ui.trophy_modal), "Leaving Results cancels its pending trophy reveal")

	game.store.data.trophies.append("duck")
	game.store.save_progress()
	var reloaded = SaveStore.new(game.store.path)
	reloaded.load_progress()
	check("duck" in reloaded.data.trophies, "Trophy ownership survives save/load (G)")

	game.free()
	await process_frame

	test_finished = true
	print("LIVE MENU SUMMARY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
