extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func find_button(node: Node, caption: String) -> Button:
	if node is Button and node.text == caption: return node
	for child in node.get_children():
		var found := find_button(child, caption)
		if found != null: return found
	return null

func all_text(node: Node) -> String:
	var output := str(node.text) + "\n" if node is Label or node is Button else ""
	for child in node.get_children(): output += all_text(child)
	return output

func frame(path: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func test() -> void:
	LocalLog.enabled = false
	root.size = Vector2i(450, 800)
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/museum_final_ui_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.unlocked = Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("museum") + 1)
	for location_id in Balance.LOCATION_ORDER.slice(0, Balance.LOCATION_ORDER.find("museum")):
		game.store.data.objectives[location_id].cash = true
		game.store.data.objectives[location_id].signature = true
	game.store.data.objectives.museum.cash = true
	game.store.data.objectives.museum.signature = true
	for key in Balance.UPGRADE_KEYS: game.store.data.upgrades[key] = Balance.required_level(key, "museum")
	game.store.data.upgrades.capacity = 19
	root.add_child(game)
	game.ui.jobs_index = Balance.LOCATION_ORDER.find("museum")
	game.action("locations")
	await process_frame
	check(not game.store.unlocked("pyramid") and find_button(game.ui.menu, "PLAY  ▶") != null and all_text(game.ui.menu).contains("VAN: 44/45") and find_button(game.ui.menu, "UPGRADE VAN · NEED 45 CARGO") == null, "Museum keeps Play primary and shows the van requirement on the objective")
	game.action("play_museum_final_job")
	check(game.screen != "run", "Museum finale cannot start below required van capacity")
	await frame("res://tests/museum_final_job_need_van.png")
	game.store.data.upgrades.capacity = 20
	game.action("locations")
	await process_frame
	var start = find_button(game.ui.menu, "PLAY FINAL JOB  ▶")
	check(start != null and all_text(game.ui.menu).contains("FINAL JOB READY") and not all_text(game.ui.menu).contains("NEXT TARGET"), "Jobs presents the playable Museum Final Job without a duplicate target")
	await frame("res://tests/museum_final_job_ready.png")
	SpecialJobs.make_pending(game.store.data, "museum")
	game.action("locations")
	await process_frame
	var special_chip = find_button(game.ui.menu, "⚡ RUSH HOUR · 35s · +40%")
	var last_nav = find_button(game.ui.menu, "COLLECTION")
	if last_nav == null: last_nav = find_button(game.ui.menu, "LOCKED")
	check(special_chip != null and last_nav != null and special_chip.get_global_rect().end.y < last_nav.get_global_rect().position.y, "Museum Special Job stays secondary and clear of navigation")
	await frame("res://tests/museum_final_job_special.png")
	game.store.data.special_pending = false
	game.action("locations")
	game.action("play_museum_final_job")
	check(game.screen == "run" and game.current_location == "museum" and game.current_mode == "FINAL_JOB", "Museum Final Job button starts the correct mode")
	game.cleanup_run()
	game.store.data.museum_final_job_completed = true
	game.store.data.wallet = 9950
	Progression.refresh(game.store.data)
	var outcome = {"success":true,"earned":9950,"loot_value":9700,"items":8,"elapsed":64.17,"full_clear":true,"mode":"FINAL_JOB","final_job_completed":true,"time_machine_stolen":true,"unlocked_locations":["pyramid"],"special_unlocked":false}
	game.ui.results(outcome, game.store, "museum")
	await process_frame
	check(all_text(game.ui.menu).contains("TIME MACHINE STOLEN") and all_text(game.ui.menu).contains("PYRAMID UNLOCKED"), "Results celebrates the story item and Chapter 2 unlock")
	await create_timer(0.6).timeout
	await frame("res://tests/museum_final_job_result.png")
	game.free()
	print("MUSEUM FINAL JOB UI: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
