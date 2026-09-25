class_name LuckyShop
extends RefCounted

# Permanent rewards bought with Lucky Tokens. Cosmetic entries live in
# Balance.COSMETICS (reward "lucky") so the wardrobe, equip flow and models keep
# working; the rest are owned flags or consumables applied here.
const SLOTS := ["block_skin", "load_vfx", "cash_vfx", "escape_vfx"]
const CATALOG := {
	"block_gold": {"name": "GOLD BLOCK", "kind": "block_skin", "price": 3, "description": "Lucky Blocks spawn in gold.", "color": "f2b930"},
	"block_neon": {"name": "NEON BLOCK", "kind": "block_skin", "price": 5, "description": "Lucky Blocks spawn in electric cyan.", "color": "2ae6ff"},
	"load_gold": {"name": "GOLDEN LOAD", "kind": "load_vfx", "price": 4, "description": "Loading loot bursts golden bills.", "color": "ffd14a"},
	"cash_violet": {"name": "VIOLET CASH", "kind": "cash_vfx", "price": 4, "description": "Cash pop-ups and the results rain turn violet.", "color": "c86bff"},
	"escape_fireworks": {"name": "FIREWORK ESCAPE", "kind": "escape_vfx", "price": 6, "description": "Escapes celebrate with extra confetti and a brighter flash.", "color": "ff7ad9"},
	"suit_lucky": {"name": "LUCKY SUIT", "kind": "cosmetic", "price": 6, "description": "Purple suit with a golden question mark.", "cosmetic": "suit_lucky"},
	"vehicle_lucky": {"name": "LUCKY VAN", "kind": "cosmetic", "price": 10, "description": "Purple getaway van, only from the Lucky Shop.", "cosmetic": "van_lucky"},
	"upgrade_token": {"name": "UPGRADE TOKEN", "kind": "upgrade_token", "price": 5, "description": "One free upgrade level of your choice, any stat.", "repeatable": true},
	"diamonds_5": {"name": "5 DIAMONDS", "kind": "diamonds", "price": 2, "description": "Five diamonds for the cosmetics shop.", "repeatable": true, "amount": 5}
}

static func owned(data: Dictionary, id: String) -> bool:
	var entry: Dictionary = CATALOG.get(id, {})
	if entry.get("kind", "") == "cosmetic": return str(entry.cosmetic) in data.cosmetics.owned
	return id in data.get("lucky_owned", [])

static func equipped(data: Dictionary, kind: String) -> String:
	return str(data.get("lucky_equipped", {}).get(kind, ""))

static func can_buy(data: Dictionary, id: String) -> bool:
	if not CATALOG.has(id): return false
	var entry: Dictionary = CATALOG[id]
	if int(data.get("lucky_tokens", 0)) < int(entry.price): return false
	return entry.get("repeatable", false) or not owned(data, id)

# Mutates the profile only; the caller saves and reacts.
static func buy(data: Dictionary, id: String) -> bool:
	if not can_buy(data, id): return false
	var entry: Dictionary = CATALOG[id]
	data.lucky_tokens = int(data.lucky_tokens) - int(entry.price)
	match str(entry.kind):
		"cosmetic":
			data.cosmetics.owned.append(str(entry.cosmetic))
		"upgrade_token":
			data.upgrade_tokens = int(data.get("upgrade_tokens", 0)) + 1
		"diamonds":
			data.diamonds = mini(1000000, int(data.diamonds) + int(entry.amount))
		_:
			data.lucky_owned.append(id)
			data.lucky_equipped[str(entry.kind)] = id
	return true

static func equip(data: Dictionary, id: String) -> bool:
	if id != "" and (not CATALOG.has(id) or not owned(data, id)): return false
	var kind: String = str(CATALOG[id].kind) if id != "" else ""
	if id == "": return false
	if kind not in SLOTS: return false
	data.lucky_equipped[kind] = "" if data.lucky_equipped.get(kind, "") == id else id
	return true

static func block_color(data: Dictionary) -> Color:
	var skin := equipped(data, "block_skin")
	return Color(str(CATALOG[skin].color)) if CATALOG.has(skin) else Color("9822ed")

static func accent(data: Dictionary, kind: String, fallback: Color) -> Color:
	var id := equipped(data, kind)
	return Color(str(CATALOG[id].color)) if CATALOG.has(id) else fallback
