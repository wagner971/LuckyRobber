extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func find_node(node: Node, node_name: String) -> Node:
	if node.name == node_name: return node
	for child in node.get_children():
		var result := find_node(child, node_name)
		if result != null: return result
	return null

func run_test() -> void:
	LocalLog.enabled = false
	var path := "res://tests/daily_gift_test_profile.json"
	var ledger := "res://tests/daily_gift_test_ledger.json"
	for suffix in ["", ".bak", ".tmp", ".schema10.bak"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ledger))
	var store := SaveStore.new(path)
	store.wheel_ledger_path = ledger
	store.load_progress()
	var start := 1984500000
	check(store.daily_gift_remaining(start) == 0, "Fresh player can claim immediately")
	var first := store.claim_daily_gift(start)
	check(first.cash == 300 and first.diamonds == 1 and store.data.wallet == 300, "Gift pays exactly $300 and one diamond")
	check(store.claim_daily_gift(start).is_empty() and store.claim_daily_gift(start + 86399).is_empty(), "Gift cannot be claimed twice within 24 hours")
	check(store.daily_gift_remaining(start + 120) == 86280, "Countdown tracks elapsed seconds from claim")
	var reloaded := SaveStore.new(path)
	reloaded.wheel_ledger_path = ledger
	reloaded.load_progress()
	check(reloaded.daily_gift_remaining(start + 120) == 86280 and reloaded.data.diamonds == 1, "Cooldown and diamonds persist after relaunch")
	var dev_reset := SaveStore.new(path)
	dev_reset.wheel_ledger_path = ledger
	dev_reset.load_daily_ledger()
	check(dev_reset.data.wallet == 0 and dev_reset.data.diamonds == 1 and dev_reset.daily_gift_remaining(start + 120) == 86280, "DEV fresh progress keeps gift cooldown without retaining cash")
	var second := reloaded.claim_daily_gift(start + 8 * 86400)
	check(second.cash == 300 and second.diamonds == 1 and reloaded.data.daily_gift_claims == 2, "Skipping a week does not reset or punish the gift")
	check(reloaded.daily_gift_remaining(start + 8 * 86400 + 60) == 86340, "Next countdown starts when gift is claimed")
	reloaded.claim_daily_gift(start + 9 * 86400)
	var fourth := reloaded.claim_daily_gift(start + 10 * 86400)
	check(fourth.diamonds == 2 and reloaded.data.diamonds == 5, "Every fourth total claim gives a second diamond without a streak")
	var old_profile := store.defaults()
	old_profile.schema_version = 10
	old_profile.wallet = 1234
	old_profile.erase("daily_gift_last_at")
	old_profile.erase("daily_gift_claims")
	var legacy_file := FileAccess.open(path, FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(old_profile))
	legacy_file.close()
	var migrated := SaveStore.new(path)
	migrated.wheel_ledger_path = ledger
	migrated.load_progress()
	check(migrated.data.schema_version == SaveStore.SCHEMA and migrated.data.wallet == 1234 and FileAccess.file_exists(path + ".schema10.bak"), "Schema 10 save migrates safely with backup")
	var game = load("res://scenes/main.tscn").instantiate()
	game.development_mode = false
	game.store = SaveStore.new("res://tests/daily_gift_ui_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	root.add_child(game)
	var button := find_node(game.ui.menu, "DailyGiftButton") as Button
	var badge := find_node(game.ui.menu, "DailyGiftBadge") as Control
	check(button != null and button.text == "" and badge == null, "Home shows the standalone gift icon without a text panel")
	button.pressed.emit()
	check(game.store.data.wallet == 300 and game.store.data.diamonds == 1, "Home gift button claims the reward")
	var timer_label := find_node(game.ui.menu, "DailyGiftTimer") as Label
	check(button.disabled and timer_label == null, "Claimed gift dims with no visible timer or caption")
	game.ui.refresh_home_gift(game.store)
	check(button.tooltip_text.contains("23h") or button.tooltip_text.contains("24h"), "Cooldown remains available in the tooltip")
	game.free()
	for suffix in ["", ".bak", ".tmp", ".schema10.bak"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ledger))
	print("DAILY GIFT SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
