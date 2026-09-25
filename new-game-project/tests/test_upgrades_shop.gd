extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS: " if ok else "FAIL: ") + message)

func all_text(node: Node) -> String:
	if node is CanvasItem and not node.visible: return ""
	var result := str(node.text) + "\n" if node is Label or node is Button else ""
	for child in node.get_children(): result += all_text(child)
	return result

func find_button(node: Node, title: String) -> Button:
	if node is Button and node.text == title: return node
	for child in node.get_children():
		var found := find_button(child, title)
		if found != null: return found
	return null

func run_test() -> void:
	LocalLog.enabled = false
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/upgrades_shop_profile.json")
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	game.store.data.wallet = 2500
	root.add_child(game)
	game.action("shop")
	await process_frame
	await process_frame
	var copy := all_text(game.ui.menu)
	check(game.ui.upgrade_cards.size() == 5, "Five compact power-up cards are present")
	check(copy.contains("STEAL THE FRIDGE") and copy.contains("NEXT TARGET"), "Next target states the loot goal")
	check(copy.contains("FRIDGE") and copy.contains("TOILET") and copy.contains("SOFA"), "Strength teases the next recognizable loot")
	check(copy.contains("45% less noise"), "Strength advertises its immediate handling benefit")
	check(copy.contains("+12% PICKUP SPEED") and copy.contains("HEAVIEST LOOT +17% SPEED") and copy.contains("8  →  10 CARGO") and copy.contains("-1% NOISE"), "Cards show the stronger immediate benefit without formulas")
	check(not copy.contains("m/s") and not copy.contains("+3% PER LEVEL") and not copy.contains("DEV ·"), "Technical formulas and DEV controls stay out of the default shop")
	check(game.ui.shop_preview != null and game.ui.shop_preview.upgrade_focus == "strength" and game.ui.shop_preview.actor.carrying, "Live 3D preview responds to Strength")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.15).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/upgrades_shop.png")
	game.ui.shop_select("carry")
	check(game.ui.shop_preview.upgrade_focus == "carry" and game.ui.shop_preview.actor.carrying, "Selecting Carry updates the live preview")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.12).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/upgrades_shop_carry.png")
	game.ui.shop_select("capacity")
	check(game.ui.shop_preview.upgrade_focus == "capacity" and not game.ui.shop_preview.actor.carrying, "Selecting Van Space switches preview focus")
	check(get_nodes_in_group("shop_cargo_box").size() == 5, "Van Space shows current cargo boxes and the next box")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.12).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/upgrades_shop_van.png")
	game.ui.shop_select("noise")
	check(game.ui.shop_preview.noise_preview_bar.visible, "Selecting Noise shows a live noise meter")
	find_button(game.ui.menu, "GO ›").pressed.emit()
	check(game.ui.shop_selected_key == "strength", "Next Target jumps to the needed power-up")
	var strength_card: VBoxContainer = game.ui.upgrade_cards.strength
	var detail: Label = strength_card.get_meta("details_label")
	check(not detail.visible, "Detailed formulas start collapsed")
	game.ui.shop_toggle_details("strength")
	check(detail.visible, "Formula remains available on demand")
	var before: int = game.store.data.wallet
	game.buy("strength")
	check(game.store.data.upgrades.strength == 2 and game.store.data.wallet == before - Balance.upgrade_cost("strength", 1), "Buying Strength keeps progression and price intact")
	check(game.ui.shop_selected_key == "strength" and not get_nodes_in_group("ui_juice_overlay").is_empty(), "Purchase keeps focus and shows an unlock celebration")
	var overlay_copy := ""
	for overlay in get_nodes_in_group("ui_juice_overlay"): overlay_copy += all_text(overlay)
	check(overlay_copy.contains("POWER UP!") and overlay_copy.contains("STRENGTH 2") and overlay_copy.contains("FRIDGE") and overlay_copy.contains("TOILET") and overlay_copy.contains("SOFA") and overlay_copy.contains("NEW LOOT UNLOCKED"), "Strength purchase names all three newly unlocked items")
	var progress: ProgressBar = game.ui.upgrade_cards.strength.get_meta("progress_bar")
	check(progress.value < 40.0, "Selected level progress starts at the previous value")
	await create_timer(0.46).timeout
	check(is_equal_approx(progress.value, 40.0) and game.ui.menu_wallet_label.text == "$1,500", "Progress and wallet animate to the purchased state")
	await create_timer(0.58).timeout
	await process_frame
	check(get_nodes_in_group("ui_juice_overlay").is_empty(), "Power-up reveal clears itself after about 0.8 seconds")
	game.ui.show_strength_power_up(3)
	var next_unlocks := ""
	for overlay in get_nodes_in_group("ui_juice_overlay"): next_unlocks += all_text(overlay)
	check(next_unlocks.contains("SMALL SAFE") and next_unlocks.contains("ARCADE MACHINE") and not next_unlocks.contains("FRIDGE"), "Higher tiers reveal only their newly unlocked loot")
	game.action("home")
	await process_frame
	check(get_nodes_in_group("ui_juice_overlay").is_empty(), "Leaving the shop immediately clears the power-up effect")
	root.size = Vector2i(720, 1280)
	game.action("shop")
	await process_frame
	await process_frame
	var nav: Button = find_button(game.ui.menu, "GARAGE")
	check(nav != null and nav.get_global_rect().end.y <= root.size.y and game.ui.upgrade_cards.size() == 5, "Shop fits a larger portrait viewport")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/upgrades_shop_720x1280.png")
	game.free()
	print("UPGRADES SHOP SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
