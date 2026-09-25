extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func find_button(node: Node, name: String) -> Button:
	if node is Button and node.name == name: return node
	for child in node.get_children():
		var result := find_button(child, name)
		if result != null: return result
	return null

func run_test() -> void:
	LocalLog.enabled = false
	var path := "res://tests/daily_wheel_test_profile.json"
	var ledger := "res://tests/daily_wheel_test_ledger.json"
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ledger))
	var store := SaveStore.new(path)
	store.wheel_ledger_path = ledger
	store.load_progress()
	var start := 1984500000
	check(DailyWheel.cash_unit(store.data) == 350, "Apartment common cash is below a full-clear payout")
	store.data.unlocked.append("electronics")
	check(DailyWheel.cash_unit(store.data) >= 1000, "By Electronics, even the smallest cash prize clears $1000")
	store.data.unlocked.erase("electronics")
	check(store.daily_spin_available(start), "New profile has one free spin")
	var prize := store.claim_daily_spin(start, 40)
	check(prize.kind == "diamonds" and prize.amount == 3 and store.data.diamonds == 3, "A diamond result credits the new currency")
	check(not store.daily_spin_available(start + 3600) and store.claim_daily_spin(start + 3600).is_empty(), "Second spin on the same UTC day is blocked")
	var reloaded := SaveStore.new(path)
	reloaded.wheel_ledger_path = ledger
	reloaded.load_progress()
	check(reloaded.data.diamonds == 3 and not reloaded.daily_spin_available(start), "Diamonds and cooldown survive a relaunch")
	var dev_reset := SaveStore.new(path)
	dev_reset.wheel_ledger_path = ledger
	dev_reset.load_daily_ledger()
	check(not dev_reset.daily_spin_available(start) and dev_reset.data.diamonds == 3, "DEV fresh progress keeps daily cooldown and wheel diamonds")
	check(reloaded.daily_spin_available(start + 86400), "Next UTC day grants another free spin")
	var jackpot := reloaded.claim_daily_spin(start + 86400, 38)
	check(jackpot.kind == "jackpot" and "character" in reloaded.data.wheel_jackpots and reloaded.data.diamonds == 13, "Jackpot saves a future skin ticket and gives immediate diamonds")
	check(DailyWheel.PRIZES.reduce(func(total, entry): return total + int(entry.weight), 0) == 100, "Reward odds total 100 percent independently of illustrated sectors")
	check(Balance.COSMETICS.suit_plum.gem_price == 50, "Existing Plum Suit costs 50 diamonds")
	var plum_day := PlayRewards.shop_pool().find("suit_plum") * 86400
	check(not reloaded.purchase_cosmetic("suit_plum", true, plum_day), "Diamond cosmetic cannot be bought with cash")
	reloaded.data.diamonds = 50
	var cash_before: int = reloaded.data.wallet
	check(reloaded.purchase_cosmetic("suit_plum", true, plum_day) and reloaded.data.diamonds == 0 and reloaded.data.wallet == cash_before, "50 diamonds buy the existing skin without spending cash")
	var after_purchase := SaveStore.new(path)
	after_purchase.wheel_ledger_path = ledger
	after_purchase.load_daily_ledger()
	check(after_purchase.data.diamonds == 0 and "character" in after_purchase.data.wheel_jackpots, "Spending diamonds updates the shared ledger without losing jackpot tickets")
	var game = load("res://scenes/main.tscn").instantiate()
	game.store = SaveStore.new("res://tests/daily_wheel_ui_profile.json")
	game.store.session_only = true
	game.store.data.tutorial_completed = true
	game.store.data.noise_tutorial_completed = true
	root.add_child(game)
	var entry := find_button(game.ui.menu, "DailyWheelEntry")
	check(entry != null and find_button(game.ui.menu, "DailyGiftButton") != null, "Home presents both the gift and the optional wheel")
	entry.pressed.emit()
	check(game.screen == "daily_wheel" and find_button(game.ui.menu, "DailySpinButton") != null, "Wheel opens without entering or blocking a heist")
	game.free()
	var old_profile := store.defaults()
	old_profile.schema_version = 9
	old_profile.wallet = 1234
	old_profile.erase("diamonds")
	old_profile.erase("daily_spin_day")
	old_profile.erase("wheel_jackpots")
	var legacy_file := FileAccess.open(path, FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(old_profile))
	legacy_file.close()
	var migrated := SaveStore.new(path)
	migrated.wheel_ledger_path = ledger
	migrated.load_progress()
	check(migrated.data.schema_version == SaveStore.SCHEMA and migrated.data.wallet == 1234 and migrated.data.diamonds == 0 and FileAccess.file_exists(path + ".schema9.bak"), "Schema 9 migration preserves cash and backs up the old profile")
	for suffix in ["", ".bak", ".tmp", ".schema9.bak"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ledger))
	print("DAILY WHEEL SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
