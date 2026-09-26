class_name LockerCollection
extends RefCounted

# The Locker's collection: thirty fixed slots per tab. A slot shows its look once
# it is owned and stays a "?" until then, so new looks unlock in place.
const SLOT_COUNT := 30
const ORIGINAL_SUIT := "original_suit"
const ORIGINAL_VAN := "original_van"
const RARITY_COLORS := {"COMMON": Color("9a93ad"), "UNCOMMON": Color("35e07a"), "RARE": Color("38c8ff"), "EPIC": Color("b45cff"), "LEGENDARY": Color("ff9a1f")}
# Bright tiers read best with dark lettering on their buttons.
const RARITY_DARK_TEXT := {"COMMON": false, "UNCOMMON": true, "RARE": true, "EPIC": false, "LEGENDARY": true}

static func slots(tab: String) -> Array[String]:
	var ids: Array[String] = [ORIGINAL_SUIT if tab == "skins" else ORIGINAL_VAN]
	if tab == "skins":
		for id in Balance.COSMETICS:
			if Balance.COSMETICS[id].slot == "suit": ids.append(id)
		for id in Balance.COSMETICS:
			if Balance.COSMETICS[id].slot == "set": ids.append(id)
	else:
		for id in Balance.VEHICLE_ORDER: ids.append(id)
		for id in Balance.COSMETICS:
			if Balance.COSMETICS[id].slot == "van" and id not in ids: ids.append(id)
	while ids.size() < SLOT_COUNT: ids.append("")
	return ids.slice(0, SLOT_COUNT)

static func tab_of(id: String) -> String:
	if id == ORIGINAL_VAN: return "vehicles"
	if id in Balance.COSMETICS and Balance.COSMETICS[id].slot == "van": return "vehicles"
	return "skins"

static func display_name(id: String) -> String:
	if id == ORIGINAL_SUIT: return "ORIGINAL LOOK"
	if id == ORIGINAL_VAN: return "GETAWAY VAN"
	return str(Balance.COSMETICS.get(id, {}).get("name", "?"))

static func kind_label(id: String) -> String:
	if id == ORIGINAL_VAN: return "GETAWAY VEHICLE"
	if id == ORIGINAL_SUIT: return "THIEF SKIN"
	match str(Balance.COSMETICS.get(id, {}).get("slot", "suit")):
		"van": return "GETAWAY VEHICLE"
		"set": return "FULL SET"
	return "THIEF SKIN"

static func rarity(id: String) -> String:
	if id in [ORIGINAL_SUIT, ORIGINAL_VAN] or id not in Balance.COSMETICS: return "COMMON"
	var config: Dictionary = Balance.COSMETICS[id]
	if config.reward in ["contracts", "trophies"]: return "LEGENDARY"
	if config.reward == "lucky" or int(config.get("gem_price", 0)) > 0: return "RARE"
	var price := int(config.get("price", 0))
	if price <= 5000: return "COMMON"
	if price <= 10000: return "UNCOMMON"
	if price <= 30000: return "RARE"
	if price <= 100000: return "EPIC"
	return "LEGENDARY"

static func tint(id: String) -> Color:
	if id in Balance.COSMETICS: return Color(str(Balance.COSMETICS[id].color))
	return Color.WHITE

static func owned(id: String, data: Dictionary) -> bool:
	return id in [ORIGINAL_SUIT, ORIGINAL_VAN] or id in data.cosmetics.owned

static func equipped(id: String, data: Dictionary) -> bool:
	var wearing: Dictionary = data.cosmetics.equipped
	if id == ORIGINAL_SUIT: return wearing.suit == "" and wearing.set == ""
	if id == ORIGINAL_VAN: return wearing.van == "" and wearing.set == ""
	if id not in Balance.COSMETICS: return false
	return wearing[Balance.COSMETICS[id].slot] == id

# Name of the look currently worn in a tab, for the equipped panels.
static func worn(tab: String, data: Dictionary) -> String:
	var wearing: Dictionary = data.cosmetics.equipped
	if wearing.set != "": return wearing.set
	var id: String = wearing.suit if tab == "skins" else wearing.van
	return id if id != "" else (ORIGINAL_SUIT if tab == "skins" else ORIGINAL_VAN)
