class_name LootRarity
extends RefCounted

# One curated replacement per tier and location. The slot (and its type_id) never changes.
const TIERS = ["RARE", "EPIC", "LEGENDARY"]
const MULTIPLIERS = [2.6, 4.0, 6.0]
const COLORS = [Color("52b9ff"), Color("bc78ff"), Color("ffd566")]
const CATALOG = {
	"apartment": [["tv_a", "GILDED TV"], ["fridge", "CRYSTAL FRIDGE"], ["flamingo", "GOLDEN FLAMINGO"]],
	"house": [["tv", "DIAMOND TV"], ["tub", "GILDED BATHTUB"], ["sofa", "ROYAL SOFA"]],
	"villa": [["safe", "SAPPHIRE SAFE"], ["tub", "MARBLE BATHTUB"], ["piano", "GOLDEN PIANO"]],
	"electronics": [["monitor_a", "NEON MONITOR"], ["arcade_a", "PRISM ARCADE"], ["vending", "GOLDEN VENDING MACHINE"]],
	"mansion": [["tv", "SAPPHIRE TV"], ["safe_a", "GILDED SAFE"], ["statue", "JEWELED HORSE STATUE"]],
	"laboratory": [["microscope", "CHROME MICROSCOPE"], ["analyzer", "PLASMA ANALYZER"], ["core", "CELESTIAL QUANTUM CORE"]],
	"museum": [["relic", "SAPPHIRE RELIC"], ["statue_a", "GILDED STATUE"], ["artifact", "CELESTIAL DIAMOND"]],
	"pyramid": [["jar_a", "AZURE CANOPIC JAR"], ["scarab", "GILDED SCARAB"], ["sarcophagus", "SUN KING SARCOPHAGUS"]],
	"castle": [["chalice", "SAPPHIRE CHALICE"], ["crown", "VAMPIRE CROWN"], ["coffin", "GOLDEN VAMPIRE COFFIN"]],
	"pirate_ship": [["spyglass", "SILVER SPYGLASS"], ["wheel", "RUBY SHIP WHEEL"], ["chest", "GOLDEN CAPTAIN'S CHEST"]],
	"vikings": [["shield", "RUNESTONE SHIELD"], ["raven", "GILDED RAVEN"], ["throne", "CROWNED JARL'S THRONE"]],
	"english_pub": [["tankard", "GILDED TANKARD"], ["gramophone", "SILVER GRAMOPHONE"], ["billiards", "GOLDEN BILLIARD TABLE"]],
	"prehistoric": [["amber", "AZURE AMBER"], ["saber", "CRYSTAL SABER"], ["mammoth", "GOLDEN MAMMOTH SKULL"]]
}

static func all_ids() -> Array:
	var ids: Array = []
	for location in CATALOG:
		for tier in TIERS: ids.append(location + "_" + tier.to_lower())
	return ids

static func variant(id: String) -> Dictionary:
	for location in CATALOG:
		for index in range(TIERS.size()):
			if id == location + "_" + TIERS[index].to_lower():
				return {"id": id, "location": location, "slot": CATALOG[location][index][0], "name": CATALOG[location][index][1], "tier": TIERS[index], "color": COLORS[index], "multiplier": MULTIPLIERS[index]}
	return {}

static func choose(location: String, roll: float) -> Dictionary:
	if not CATALOG.has(location): return {}
	var tier := -1
	if roll < 0.01: tier = 2
	elif roll < 0.05: tier = 1
	elif roll < 0.20: tier = 0
	return variant(location + "_" + TIERS[tier].to_lower()) if tier >= 0 else {}

static func value(base: int, choice: Dictionary) -> int:
	if choice.is_empty(): return base
	if choice.id == "apartment_rare": return 600
	return maxi(base + 10, roundi(float(base) * float(choice.multiplier) / 10.0) * 10)

static func base_type(choice: Dictionary) -> String:
	if choice.is_empty(): return ""
	for row in Balance.LOCATIONS[choice.location].items:
		if row[0] == choice.slot: return str(row[1])
	return ""

static func visual_type(choice: Dictionary) -> String:
	if choice.is_empty(): return ""
	if choice.id == "mansion_legendary": return "jeweled_horse_statue"
	return base_type(choice)

static func decorate_model(model: Node, choice: Dictionary) -> void:
	if model is MeshInstance3D and model.material_override is StandardMaterial3D:
		var material: StandardMaterial3D = model.material_override.duplicate()
		var accent: Color = choice.color
		var shade := 0.43 + 0.5 * material.albedo_color.get_luminance()
		material.albedo_color = material.albedo_color.lerp(accent * shade, 0.43 if choice.tier == "RARE" else (0.58 if choice.tier == "EPIC" else 0.80))
		material.metallic = 0.14 if choice.tier == "RARE" else 0.31
		material.roughness = 0.58
		material.emission_enabled = true
		material.emission = accent
		material.emission_energy_multiplier = 0.10 if choice.tier == "RARE" else 0.16
		model.material_override = material
	for child in model.get_children(): decorate_model(child, choice)
