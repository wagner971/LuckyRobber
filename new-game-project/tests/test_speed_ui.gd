extends SceneTree
var checks := 0
var failures := 0
var game: Node
func _initialize() -> void: call_deferred("test")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ")+label)
func find_button(label: String,node: Node = null) -> Button:
	if node == null: node = game.ui.menu
	if node is Button and node.text == label: return node
	for child in node.get_children():
		var found = find_button(label,child)
		if found: return found
	return null
func all_text(node: Node) -> String:
	var copy = str(node.text)+"\n" if node is Label or node is Button else ""
	for child in node.get_children(): copy += all_text(child)
	return copy
func shot(label: String) -> void:
	for frame in range(5): await process_frame
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/speed_%s_%dx%d.png" % [label,root.size.x,root.size.y])
func test() -> void:
	LocalLog.enabled = false
	for dimensions in [Vector2i(450,800),Vector2i(320,712)]:
		root.size = dimensions
		game = load("res://scenes/main.tscn").instantiate()
		game.store = SaveStore.new("res://tests/speed_ui_unused.json")
		game.store.session_only = true
		var data = game.store.data
		data.tutorial_completed = true
		data.noise_tutorial_completed = true
		data.first_job_at = 1
		data.successes = 3
		data.wallet = 1000
		data.objectives.apartment.cash = true
		data.objectives.apartment.signature = true
		data.upgrades.capacity = 6
		data.upgrades.strength = 2
		root.add_child(game)
		game.ui.set_safe_area_override(Vector4(0,56,0,40))
		game.action("locations")
		await shot("blocked_jobs")
		check(find_button("PLAY FINAL JOB  ▶") == null and find_button("PLAY  ▶") != null,"Farming stays available; Final Job is withheld before the speed purchases")
		check(all_text(game.ui.menu).contains("UPGRADE SPEEDS") and all_text(game.ui.menu).contains("PICKUP 1/2"),"Jobs explicitly explains the two speed requirements")
		var requirements = get_nodes_in_group("jobs_powerup_requirement")
		for chip in requirements:
			if game.ui.menu.is_ancestor_of(chip) and chip.get_meta("upgrade_key") == "carry":
				chip.pressed.emit()
				break
		check(game.screen == "shop" and game.ui.shop_selected_key == "carry","Requirement chip opens Carry Speed directly")
		await shot("shop_required")
		check(all_text(game.ui.menu).contains("NEED 2") and all_text(game.ui.menu).contains("BUY  $300"),"Shop exposes the required level and affordable price")
		game.action("home")
		await shot("home_target")
		check(all_text(game.ui.menu).contains("MOVE FASTER WITH LOOT"),"Home target recommends the actual missing upgrade")
		game.action("play_final_job")
		check(game.screen == "shop" and not is_instance_valid(game.run),"Direct Final Job action also enforces requirements")
		var carry_button: Button = game.ui.upgrade_cards.carry.get_meta("buy_button")
		carry_button.pressed.emit()
		check(data.upgrades.carry == 2 and data.wallet == 700 and not Progression.final_job_unlocked(data),"Buying only Carry does not bypass Pickup requirement")
		var grip_button: Button = game.ui.upgrade_cards.grip.get_meta("buy_button")
		grip_button.pressed.emit()
		check(data.upgrades.grip == 2 and data.wallet == 450 and Progression.final_job_unlocked(data),"Both actual purchases enable Final Job for exactly $550")
		game.action("locations")
		await shot("ready_jobs")
		var play = find_button("PLAY FINAL JOB  ▶")
		check(play != null and play.get_global_rect().end.y < game.ui.root.size.y-game.ui.safe_insets.w,"Final Job action remains visible inside portrait safe area")
		if play: play.pressed.emit()
		check(game.screen == "run" and game.run.mode == "FINAL_JOB","Player can start Final Job immediately after satisfying both requirements")
		game.free()
		await process_frame
	print("SPEED UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
