extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func find_button(node: Node, title: String) -> Button:
	if node is Button and node.text == title: return node
	for child in node.get_children():
		var found := find_button(child, title)
		if found != null: return found
	return null

func find_buttons(node: Node, title: String, output: Array[Button]) -> void:
	if node is Button and node.text == title: output.append(node)
	for child in node.get_children(): find_buttons(child, title, output)

func find_dot(node: Node, index: int) -> Button:
	if node is Button and node.is_in_group("jobs_page_dot") and node.get_meta("location_index", -1) == index: return node
	for child in node.get_children():
		var found := find_dot(child, index)
		if found != null: return found
	return null

func count_dots(node: Node) -> int:
	var count := 1 if node.is_in_group("jobs_page_dot") else 0
	for child in node.get_children(): count += count_dots(child)
	return count

func group_children(node: Node, group_name: String) -> Array[Node]:
	var found: Array[Node] = []
	if node.is_in_group(group_name): found.append(node)
	for child in node.get_children(): found.append_array(group_children(child, group_name))
	return found

func all_text(node: Node) -> String:
	var result := str(node.text) + "\n" if node is Label or node is Button else ""
	for child in node.get_children(): result += all_text(child)
	return result

func count_previews(node: Node) -> int:
	var count := 1 if node is TextureRect and node.is_in_group("jobs_hero_image") else 0
	for child in node.get_children(): count += count_previews(child)
	return count

func contains_scroll(node: Node) -> bool:
	if node is ScrollContainer: return true
	for child in node.get_children():
		if contains_scroll(child): return true
	return false

func find_preview(node: Node) -> TextureRect:
	if node is TextureRect and node.is_in_group("jobs_hero_image"): return node
	for child in node.get_children():
		var found := find_preview(child)
		if found != null: return found
	return null

func capture(label: String, settle: bool = true) -> void:
	if DisplayServer.get_name() == "headless": return
	if settle: await create_timer(0.40).timeout
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/jobs_" + label + ".png")

func run_test() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/jobs_v1_profile.json")
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.heist_briefing_seen = true
	game.store.data.first_job_at = 1 # Existing profile before staged feature unlocks.
	game.store.notice = "DEV MODE · Fresh start every launch"
	root.add_child(game)
	game.action("locations")
	await process_frame
	var ui_text := all_text(game.ui.menu)
	check(find_preview(game.ui.menu).get_parent().tooltip_text == "APARTMENT" and ui_text.contains("STEAL THE FRIDGE"), "Jobs opens on visual Apartment with a concrete next target")
	check(count_previews(game.ui.menu) == 1 and not ui_text.contains("9 OBJECTS") and not ui_text.contains("MASTERY CONTRACTS"), "One location preview is in focus without old technical list")
	check(not contains_scroll(game.ui.menu), "Jobs uses discrete pages without a free-scrolling container")
	check(find_button(game.ui.menu, "PLAY  ▶") != null, "Normal run remains directly playable")
	check(count_dots(game.ui.menu) == 7 and find_dot(game.ui.menu, 0).get_meta("active", false), "Chapter 1 shows seven dots with Apartment active")
	check(find_button(game.ui.menu, "APT") == null and find_button(game.ui.menu, "HOUSE") == null, "Active location name is not duplicated in bottom tabs")
	var objective_icons := group_children(game.ui.menu, "jobs_objective_icon")
	var stat_icons := group_children(game.ui.menu, "jobs_stat_icon")
	check(group_children(game.ui.menu, "jobs_objective_slot").size() == 3 and objective_icons.size() == 3 and objective_icons.all(func(icon): return icon.custom_minimum_size.x >= 46), "Three objective notes use clear icons")
	check(stat_icons.size() == 3 and stat_icons.all(func(icon): return icon.custom_minimum_size.x >= 32) and ui_text.contains("LOOT") and ui_text.contains("ITEMS") and ui_text.contains("TIME"), "Loot, item count, and time have labelled icons")
	check(group_children(game.ui.menu, "jobs_capacity_bar").size() == 1 and ui_text.contains("VAN SPACE"), "Van capacity is shown as its own progress bar")
	check(find_button(game.ui.menu, "‹") == null and find_button(game.ui.menu, "›") == null and not ui_text.contains("01 / 06"), "Carousel uses swipe and dots without duplicate arrows or chapter index")
	check(group_children(game.ui.menu, "jobs_nav_icon").size() == 4, "Jobs navigation shows four pictograms above the labels")
	check(not ui_text.contains("DEV MODE"), "Developer notice stays out of the Jobs presentation")
	check(find_button(game.ui.menu, "COLLECTION").get_global_rect().end.y <= game.ui.root.size.y, "Jobs navigation fits the default portrait window")
	await capture("apartment")
	var hero_rect = find_preview(game.ui.menu).get_parent().get_global_rect()
	var touch = InputEventMouseButton.new()
	touch.button_index = MOUSE_BUTTON_LEFT
	touch.position = hero_rect.get_center() + Vector2(80, 0)
	touch.pressed = true
	root.push_input(touch, true)
	touch.position = hero_rect.get_center() - Vector2(80, 0)
	touch.pressed = false
	root.push_input(touch, true)
	await process_frame
	check(game.ui.jobs_index == 1, "Real pointer swipe on hero preview changes the selected job")
	game.ui.jobs_index = 0
	game.action("locations")
	game.ui.jobs_preview_input(make_swipe(true, Vector2(210, 210)), game.store)
	game.ui.jobs_preview_input(make_swipe(false, Vector2(230, 320)), game.store)
	check(game.ui.jobs_index == 0, "Vertical gesture does not turn the carousel")
	find_dot(game.ui.menu, 2).pressed.emit()
	find_dot(game.ui.menu, 3).pressed.emit()
	check(game.ui.jobs_index == 3 and all_text(game.ui.menu).contains("ELECTRONICS STORE") and find_dot(game.ui.menu, 3).get_meta("active", false), "Dots select and track the intended job")
	game.ui.jobs_index = 0
	game.action("locations")
	await process_frame
	await process_frame
	find_dot(game.ui.menu, 1).pressed.emit()
	await process_frame
	await process_frame
	await process_frame
	check(game.ui.jobs_transition != null and game.ui.jobs_transition.is_running() and game.ui.jobs_current_card.modulate.a < 1.0, "Carousel animates the incoming card instead of swapping instantly")
	var swap_layer: Control = get_nodes_in_group("jobs_transition_card").front()
	var incoming: PanelContainer = game.ui.jobs_current_card
	var outgoing: PanelContainer = swap_layer.get_child(0)
	check(swap_layer.clip_contents and outgoing.clip_contents and incoming.clip_contents and incoming.get_parent().clip_contents, "Outgoing and incoming card contents stay clipped")
	check(incoming.scale.x >= 0.959 and incoming.scale.x <= 1.001 and ((swap_layer.visible and incoming.modulate.a <= 0.01) or not swap_layer.visible), "Only one card is readable during the clipped swap")
	check(incoming.get_global_rect().intersection(outgoing.get_global_rect()).size.x > incoming.size.x * 0.85, "Cards overlap throughout the swap without an empty gap")
	await capture("swipe_mid", false)
	await create_timer(0.19).timeout
	check(incoming.modulate.a >= 0.3 and (not is_instance_valid(outgoing) or outgoing.modulate.a < 0.01), "Incoming card takes focus smoothly without ghosted text")
	await capture("swipe_half", false)
	await process_frame
	ui_text = all_text(game.ui.menu)
	check(ui_text.contains("SUBURBAN HOUSE") and find_button(game.ui.menu, "PLAY APARTMENT") != null and find_button(game.ui.menu, "PLAY  ▶") == null and not ui_text.contains("OBJECTIVES"), "Locked House offers a direct return to the previous job without technical footnotes")
	var locked_material := find_preview(game.ui.menu).material as ShaderMaterial
	check(group_children(game.ui.menu, "jobs_stat_icon").is_empty() and locked_material.get_shader_parameter("locked") == 1.0, "Locked location desaturates its preview and hides stats")
	await capture("house_locked")
	if DisplayServer.get_name() == "headless": await create_timer(0.40).timeout
	check(get_nodes_in_group("jobs_transition_card").is_empty(), "Outgoing card is released after the swipe animation")
	check(is_equal_approx(game.ui.jobs_current_card.scale.x, 1.0) and is_equal_approx(game.ui.jobs_current_card.modulate.a, 1.0) and is_zero_approx(game.ui.jobs_current_card.position.x), "Selected card settles centered at full scale and brightness")
	find_dot(game.ui.menu, 2).pressed.emit()
	game.ui.job_select(game.store, 0)
	await create_timer(0.45).timeout
	check(game.ui.jobs_index == 0 and count_previews(game.ui.menu) == 1 and get_nodes_in_group("jobs_transition_card").is_empty(), "Rapid tab changes still snap to one centered card")
	game.store.data.objectives.apartment.cash = true
	game.store.data.objectives.apartment.signature = true
	game.store.data.upgrades.capacity = 1
	game.ui.jobs_index = 0
	game.action("locations")
	await process_frame
	ui_text = all_text(game.ui.menu)
	check(find_button(game.ui.menu, "PLAY  ▶") != null and find_button(game.ui.menu, "UPGRADE VAN · NEED 17 CARGO") == null and ui_text.contains("VAN: 8/17"), "Insufficient cargo keeps Play primary and explains the lock on the crown objective")
	check(group_children(game.ui.menu, "jobs_target_panel").is_empty() and ui_text.contains("STEAL EVERYTHING"), "Full-clear objective replaces the duplicate Next Target panel")
	await capture("van_blocked")
	find_button(game.ui.menu, "PLAY  ▶").pressed.emit()
	await create_timer(0.55).timeout
	check(game.screen == "run" and game.current_mode == "normal", "Primary Play still starts a normal heist when the Final Job is blocked")
	game.cleanup_run()
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.required_level(key, "apartment")
	game.store.data.upgrades.capacity = 10
	game.ui.jobs_index = 0
	game.action("locations")
	await process_frame
	check(find_button(game.ui.menu, "PLAY FINAL JOB  ▶") != null and find_button(game.ui.menu, "PLAY NORMAL") != null, "Playable Final Job is the primary action; Normal remains secondary")
	check(find_button(game.ui.menu, "PLAY FINAL JOB  ▶").custom_minimum_size.y > find_button(game.ui.menu, "PLAY NORMAL").custom_minimum_size.y, "Final Job CTA is larger than secondary actions")
	await capture("final_ready")
	SpecialJobs.make_pending(game.store.data, "apartment")
	game.action("locations")
	await process_frame
	check(find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%") != null and find_button(game.ui.menu, "PLAY NORMAL") != null, "Special Job appears as a small secondary action")
	check(find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%").get_global_rect().end.y < find_button(game.ui.menu, "COLLECTION").get_global_rect().position.y, "Special and Final Job actions stay above navigation")
	await capture("special")
	find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%").pressed.emit()
	await create_timer(0.55).timeout
	check(game.screen == "run" and game.current_mode == SpecialJobs.MODE, "Special Job chip starts its existing mode")
	game.cleanup_run()
	game.store.data.objectives.apartment.full_clear = true
	game.store.data.apartment_final_job_completed = true
	game.action("locations")
	await process_frame
	check(group_children(game.ui.menu, "jobs_target_panel").is_empty() and not all_text(game.ui.menu).contains("BEAT YOUR BEST TIME"), "Completed location hides an empty Next Target panel")
	game.ui.jobs_index = Balance.LOCATION_ORDER.find("pyramid")
	game.action("locations")
	await process_frame
	ui_text = all_text(game.ui.menu)
	check(ui_text.contains("CHAPTER 2 LOCKED") and ui_text.contains("PYRAMID") and ui_text.contains("COMPLETE MUSEUM TO UNLOCK THIS CHAPTER") and count_dots(game.ui.menu) == 1, "Chapter 2 shows the Museum completion requirement")
	check(group_children(game.ui.menu, "jobs_chapter_lock_screen").size() == 1 and find_button(game.ui.menu, "GO TO MUSEUM") != null and find_button(game.ui.menu, "PLAY  ▶") == null, "Pyramid has a dedicated locked screen and no Play action")
	check(not ui_text.contains("DRACULA'S CASTLE") and not ui_text.contains("OBJECTIVES"), "Locked chapter omits future locations and gameplay details")
	await capture("chapter_2_teaser")
	find_button(game.ui.menu, "GO TO MUSEUM").pressed.emit()
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("museum"), "Locked chapter action returns to Museum")
	game.store.data.museum_final_job_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	game.ui.jobs_index = Balance.LOCATION_ORDER.find("pyramid")
	game.action("locations")
	await process_frame
	check(all_text(game.ui.menu).contains("PYRAMID") and find_button(game.ui.menu, "PLAY  ▶") != null and count_dots(game.ui.menu) == 6, "Chapter 2 reveals six location dots once unlocked")
	await capture("pyramid")
	find_dot(game.ui.menu, Balance.LOCATION_ORDER.find("castle")).pressed.emit()
	await process_frame
	check(all_text(game.ui.menu).contains("DRACULA'S CASTLE") and count_previews(game.ui.menu) == 1, "Last location has its own preview")
	await capture("castle")
	game.ui.jobs_preview_input(make_swipe(true, Vector2(310, 300)), game.store)
	game.ui.jobs_preview_input(make_swipe(false, Vector2(210, 300)), game.store)
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("pirate_ship"), "Swipe reaches Pirate Ship after Castle")
	await create_timer(0.5).timeout
	game.ui.job_shift(game.store, 1)
	await create_timer(0.5).timeout
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("vikings"), "Swipe reaches Viking Hall after Pirate Ship")
	game.ui.job_shift(game.store, 1)
	await create_timer(0.5).timeout
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("english_pub"), "Swipe reaches English Pub after Viking Hall")
	game.ui.job_shift(game.store, 1)
	await create_timer(0.5).timeout
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("prehistoric"), "Swipe reaches Prehistoric Era after English Pub")
	game.ui.job_shift(game.store, 1)
	await create_timer(0.5).timeout
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("prehistoric"), "Swipe stops at the last location without wrapping")
	game.ui.jobs_preview_input(make_swipe(true, Vector2(210, 300)), game.store)
	game.ui.jobs_preview_input(make_swipe(false, Vector2(310, 300)), game.store)
	check(game.ui.jobs_index == Balance.LOCATION_ORDER.find("english_pub"), "Horizontal swipe selects the previous location")
	for viewport_size in [Vector2i(450, 800), Vector2i(720, 1280), Vector2i(720, 1600)]:
		root.size = viewport_size
		game.ui.jobs_index = 0
		game.action("locations")
		await process_frame
		await process_frame
		var play = find_button(game.ui.menu, "PLAY  ▶")
		var navigation = find_button(game.ui.menu, "COLLECTION")
		var logical_size: Vector2 = root.get_visible_rect().size
		check(play != null and play.get_global_rect().end.y < navigation.get_global_rect().position.y and navigation.get_global_rect().end.y <= logical_size.y, "Jobs actions fit portrait %s · play %.0f nav %.0f–%.0f" % [viewport_size, play.get_global_rect().end.y, navigation.get_global_rect().position.y, navigation.get_global_rect().end.y])
		check(group_children(game.ui.menu, "jobs_objective_slot").all(func(slot): return slot.get_global_rect().position.x >= 0 and slot.get_global_rect().end.x <= logical_size.x), "Objective slots do not clip horizontally at %s" % viewport_size)
		if viewport_size == Vector2i(720, 1280): await capture("720x1280")
	find_button(game.ui.menu, "UPGRADES").pressed.emit()
	check(game.screen == "shop" and find_button(game.ui.menu, "JOBS") != null, "Bottom navigation opens Upgrades from Jobs")
	find_button(game.ui.menu, "JOBS").pressed.emit()
	check(game.screen == "locations" and find_button(game.ui.menu, "PLAY  ▶") != null, "Bottom navigation returns to the selected job")
	game.free()
	print("JOBS CARD SWAP SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func make_swipe(pressed: bool, at: Vector2) -> InputEventScreenTouch:
	var event = InputEventScreenTouch.new()
	event.pressed = pressed
	event.position = at
	return event
