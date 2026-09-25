extends SceneTree

var checks = 0
var failures = 0

func _initialize() -> void:
	call_deferred("test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func find_button(node: Node, label: String) -> Button:
	if node is Button and node.text == label: return node
	for child in node.get_children():
		var found = find_button(child, label)
		if found != null: return found
	return null

func test() -> void:
	LocalLog.enabled = false
	var main = load("res://scenes/main.tscn").instantiate()
	main.store = SaveStore.new("res://tests/ui_v2_profile.json")
	main.store.data.tutorial_completed = true
	main.store.data.noise_tutorial_completed = true
	main.store.data.successes = 4
	main.store.data.first_job_at = 1
	root.add_child(main)
	main.start_run("apartment", "rush")
	check(main.run == null, "Contracts cannot be started before campaign clear")
	main.store.data.objectives.museum = {"cash": true, "signature": true, "full_clear": false}
	main.store.data.upgrades.capacity = 10
	main.ui.contracts_page(main.store, "apartment")
	await process_frame
	var start = find_button(main.ui.menu, "START RUSH →")
	check(start != null and not start.disabled, "Contract start available without MAX upgrades")
	start.pressed.emit()
	await process_frame
	check(main.run.mode == "rush" and main.run.remaining == 30 and main.run.capacity() == 26, "Contract menu starts live session with its own rules")
	main.run.abandon()
	await process_frame
	check(find_button(main.ui.menu, "RETRY") != null and find_button(main.ui.menu, "UPGRADES") != null and find_button(main.ui.menu, "JOBS") != null, "Results offers one primary retry and two smaller destinations")
	check(not has_scroll(main.ui.menu) and find_button(main.ui.menu, "DEV · MAX ALL + UNLOCK AVAILABLE LEVELS") == null and count_buy_buttons(main.ui.menu) == 0, "Results fits one screen without Shop or DEV controls")
	check(all_text(main.ui.menu).contains("STEAL THE FRIDGE") and all_text(main.ui.menu).contains("Upgrade Strength to Level 2"), "Next Target names the loot and the action needed")
	check(find_button(main.ui.menu, "RETRY").get_global_rect().end.y <= main.ui.root.size.y, "Primary result action stays inside the portrait viewport")
	find_button(main.ui.menu, "RETRY").pressed.emit()
	await process_frame
	check(main.run.mode == "rush" and main.run.remaining == 30, "Play Again retains selected contract mode")
	main.run.abandon()
	main.action("locations")
	await process_frame
	find_button(main.ui.menu, "PLAY  ▶").pressed.emit()
	await process_frame
	check(main.run.mode == "normal" and main.run.remaining == 60 and main.run.capacity() == 26, "Normal button restores 60 seconds and permanent capacity")
	main.run.abandon()
	main.store.data.wallet = 20000
	var upgrades = main.store.data.upgrades.duplicate()
	main.action("cosmetics")
	await process_frame
	var buy = find_button(main.ui.menu, "BUY $5000")
	buy.pressed.emit()
	buy.pressed.emit()
	await process_frame
	check(main.store.data.wallet == 15000 and main.store.data.cosmetics.owned == ["van_mint"], "Cosmetic shop signal purchases once even on repeated press")
	find_button(main.ui.menu, "EQUIP").pressed.emit()
	await process_frame
	main.action("locations")
	main.start_run("apartment")
	check(main.level.van.model.get_child(1).material_override.albedo_color == Color("70dabc") and main.run.upgrades == upgrades, "Equipped cosmetic reaches next playable round without stat changes")
	main.run.abandon()
	main.action("locations")
	await process_frame
	await create_timer(1).timeout
	var count = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for i in range(10):
		main.start_run("apartment", "small_van" if i % 2 else "normal")
		main.run.abandon()
		main.action("locations")
		await process_frame
	await create_timer(1).timeout
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) == count, "Ten complete UI run/result/replay cycles release nodes, signals and sound players")
	main.store.data = main.store.defaults()
	main.store.data.tutorial_completed = true
	main.store.data.noise_tutorial_completed = true
	main.store.data.successes = 4
	main.store.data.first_job_at = 1
	main.store.data.wallet = 10000
	main.store.data.upgrades.grip = 4
	main.action("shop")
	await process_frame
	check(find_button(main.ui.menu, "LOCKED").disabled, "Shop tier lock is visible and disabled")
	check(all_text(main.ui.menu).contains("UNLOCK SUBURBAN HOUSE"), "Shop explains next tier unlock in player-facing language")
	var before = main.store.data.wallet
	main.buy("grip")
	check(main.store.data.wallet == before and main.store.data.upgrades.grip == 4, "Tier bypass via direct buy signal cannot charge")
	main.store.data.unlocked.append("house")
	main.buy("grip")
	check(main.store.data.upgrades.grip == 5 and main.store.data.wallet == before - Balance.upgrade_cost("grip", 4), "Unlock opens global purchase tier")
	var body_text = all_text(main.ui.menu)
	var five = true
	for key in Balance.UPGRADE_KEYS: five = five and body_text.contains(GameUI.SHOP_TITLES[key])
	check(five and count_buy_buttons(main.ui.menu) == 5, "Exactly five power-up cards and purchase controls")
	main.store.data.upgrades.grip = 15
	main.action("shop")
	check(all_text(main.ui.menu).contains("GRANDFATHERED"), "Migrated over-tier level is explained in shop")
	main.start_run("apartment")
	main.run.set_physics_process(false)
	check(is_equal_approx(Balance.grip_speed(main.run.upgrades.grip), 1.42), "Grandfathered Grip15 remains active while replaying Apartment")
	main.run.phase = RunManager.Phase.ACTIVE
	main.run.current_noise = main.run.alarm_threshold * 0.76
	main.ui.update_run(main.run, 0)
	check(main.ui.noise_status.text.contains("ALARM CLOSE") and main.ui.noise_bar.value > 75, "Warning uses text and compact bar, not color alone")
	main.run.current_noise = main.run.alarm_threshold
	main.run.carried = main.level.items[0]
	main.run.add_pickup_noise(main.run.carried)
	main.ui.update_run(main.run, 0)
	check(main.ui.toast.text.begins_with("ALARM! POLICE IN") and main.ui.noise_status.text.contains("POLICE IN") and main.ui.alarm_vignette.visible, "Alarm appears with police countdown and red vignette")
	main.run.carried = null
	main.level.player.position = main.level.van.load_position
	main.ui.update_run(main.run, 0)
	check(main.ui.escape_button.visible and main.ui.escape_button.text.contains("ESCAPE NOW"), "Alarm makes van escape action explicit")
	main.ui.update_run(main.run, 2)
	check(main.ui.toast.text == "" and main.ui.noise_status.text.contains("POLICE IN"), "Alarm banner is brief while the countdown remains")
	check(main.sound.clips.has("alarm") and main.sound.clips.alarm != main.sound.clips.tick, "Distinct synthesized alarm sound exists")
	main.run.abandon()
	main.store.data.upgrades = {"strength":5,"grip":20,"carry":20,"capacity":20,"noise":20}
	main.store.data.unlocked = Balance.LOCATION_ORDER.duplicate()
	main.action("shop")
	check(count_buy_buttons(main.ui.menu) == 5 and not all_text(main.ui.menu).contains("$0") and not all_text(main.ui.menu).contains("LEVEL 21"), "MAX shop has no level21 or fake zero-price purchase")
	main.free()
	print("V2 UI SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func all_text(node: Node) -> String:
	var output = str(node.text) + "\n" if node is Label or node is Button else ""
	for child in node.get_children(): output += all_text(child)
	return output

func count_buy_buttons(node: Node) -> int:
	var total = 1 if node is Button and (node.text.begins_with("BUY") or node.text in ["LOCKED", "MAXED"]) else 0
	for child in node.get_children(): total += count_buy_buttons(child)
	return total

func has_scroll(node: Node) -> bool:
	if node is ScrollContainer: return true
	for child in node.get_children():
		if has_scroll(child): return true
	return false
