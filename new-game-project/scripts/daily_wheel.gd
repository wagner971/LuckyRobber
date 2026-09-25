class_name DailyWheel
extends RefCounted

# Illustrated sectors are independent of the odds disclosed in the info panel.
# Jackpots award saved tickets and diamonds until their skins are produced.
const PRIZES = [
	{"id":"cash_small", "weight":38, "kind":"cash", "scale":1},
	{"id":"skin_ticket", "weight":1, "kind":"jackpot", "ticket":"character"},
	{"id":"gems_three", "weight":20, "kind":"diamonds", "amount":3},
	{"id":"cash_medium", "weight":22, "kind":"cash", "scale":2},
	{"id":"van_ticket", "weight":1, "kind":"jackpot", "ticket":"van"},
	{"id":"gems_eight", "weight":10, "kind":"diamonds", "amount":8},
	{"id":"cash_large", "weight":8, "kind":"cash", "scale":3},
]

static func utc_day(unix_time: int) -> int:
	return maxi(0, unix_time / 86400)

static func next_reset_seconds(unix_time: int) -> int:
	return (utc_day(unix_time) + 1) * 86400 - unix_time

static func cash_unit(profile: Dictionary) -> int:
	var best_value := int(Balance.LOCATIONS.apartment.expected_value)
	for id in profile.get("unlocked", []):
		if Balance.LOCATIONS.has(id):
			best_value = maxi(best_value, int(Balance.LOCATIONS[id].expected_value))
	# A common early spin is below one full heist; later locations raise the floor.
	return maxi(100, roundi(best_value * 0.30 / 50.0) * 50)

static func choose(profile: Dictionary, draw: int = -1) -> Dictionary:
	var roll := clampi(draw if draw >= 0 else randi_range(0, 99), 0, 99)
	var offset := 0
	for index in range(PRIZES.size()):
		var definition: Dictionary = PRIZES[index]
		offset += int(definition.weight)
		if roll >= offset: continue
		var prize := definition.duplicate(true)
		prize["index"] = index
		if prize.kind == "cash": prize["amount"] = cash_unit(profile) * int(prize.scale)
		if prize.kind == "jackpot": prize["amount"] = 10 if prize.ticket not in profile.get("wheel_jackpots", []) else 20
		return prize
	return {}

static func award(profile: Dictionary, prize: Dictionary, day: int) -> void:
	profile.daily_spin_day = day
	match str(prize.get("kind", "")):
		"cash": profile.wallet = mini(1000000000, int(profile.wallet) + int(prize.amount))
		"diamonds": profile.diamonds = mini(1000000, int(profile.diamonds) + int(prize.amount))
		"jackpot":
			var ticket: String = str(prize.ticket)
			if ticket not in profile.wheel_jackpots: profile.wheel_jackpots.append(ticket)
			profile.diamonds = mini(1000000, int(profile.diamonds) + int(prize.amount))

static func caption(prize: Dictionary) -> String:
	match str(prize.get("kind", "")):
		"cash": return "+$%s CASH" % prize.amount
		"diamonds": return "+%s DIAMONDS" % prize.amount
		"jackpot": return ("CHARACTER" if prize.ticket == "character" else "VAN") + " SKIN TICKET +%d ◆" % int(prize.amount)
	return ""
