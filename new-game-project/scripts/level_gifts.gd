class_name LevelGifts
extends RefCounted

const RARITIES := ["COMMON", "UNCOMMON", "RARE", "LEGENDARY"]
const COLORS := [Color("4cea88"), Color("45b6ff"), Color("b25bff"), Color("ffd45c")]

static func roll() -> int:
	var draw := randi_range(0,99)
	return 0 if draw < 50 else (1 if draw < 80 else (2 if draw < 96 else 3))

static func settle(profile: Dictionary, location: String, full_clear: bool) -> Dictionary:
	if not full_clear or location not in Balance.LOCATIONS: return {}
	if location == "apartment" and not profile.get("apartment_final_job_completed",false): return {}
	if location == "museum" and not profile.get("museum_final_job_completed",false): return {}
	if not profile.has("level_gifts"): profile.level_gifts = {}
	if profile.level_gifts.has(location): return {}
	var reward := {"rarity":roll(), "seen":false}
	profile.level_gifts[location] = reward
	return {"location":location, "rarity":reward.rarity, "prototype":true}

static func pending(profile: Dictionary) -> Dictionary:
	for location in Balance.LOCATION_ORDER:
		var reward: Dictionary = profile.get("level_gifts",{}).get(location,{})
		if not reward.is_empty() and not reward.get("seen",false):
			return {"location":location, "rarity":reward.rarity, "prototype":true}
	return {}
