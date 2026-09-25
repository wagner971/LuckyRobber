extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1
	print(("PASS: " if value else "FAIL: ") + message)

func count_named(node: Node, prefix: String) -> int:
	var total := 1 if str(node.name).begins_with(prefix) else 0
	for child in node.get_children(): total += count_named(child,prefix)
	return total

func run_test() -> void:
	LocalLog.enabled = false
	var all_seen: Array[String] = []
	for day in range(PlayRewards.shop_pool().size()):
		var selection := PlayRewards.today_shop(day * 86400)
		check(selection.size() == 3 and selection[0] != selection[1] and selection[1] != selection[2] and selection[0] != selection[2], "Rotation day %d shows exactly three distinct cosmetics" % day)
		for id in selection:
			if id not in all_seen: all_seen.append(id)
	check(all_seen.size() == PlayRewards.shop_pool().size() and PlayRewards.today_shop(0) == PlayRewards.today_shop(PlayRewards.shop_pool().size() * 86400), "Every cosmetic returns in the rotation cycle")
	check(PlayRewards.shop_refresh_remaining(120) == 86280, "Today's Shop refreshes at the next UTC day")
	var path := "res://tests/play_rewards_profile.json"
	for suffix in ["", ".bak", ".tmp", ".schema11.bak"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path + ".daily"))
	var store := SaveStore.new(path)
	store.load_progress()
	store.data.wallet = 50000
	store.data.diamonds = 50
	check(not store.purchase_cosmetic("van_coral", true, 0), "Off-rotation cosmetic cannot be purchased")
	var plum_day := PlayRewards.shop_pool().find("suit_plum") * 86400
	check(store.purchase_cosmetic("suit_plum", true, plum_day) and store.data.diamonds == 0, "Featured diamond cosmetic is purchasable at its regular price")
	check(store.equip_cosmetic("suit_plum", true) and store.data.cosmetics.equipped.suit == "suit_plum", "Owned cosmetics stay usable outside their rotation")
	for suffix in ["", ".bak", ".tmp", ".daily"]: DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	print("SHOP ROTATION SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
