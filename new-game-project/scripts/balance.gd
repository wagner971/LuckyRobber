class_name Balance
extends RefCounted

const BASE_SPEED = 5.0
const ACCEL_TIME = 0.175
const STOP_TIME = 0.10
const MIN_PICKUP = 0.25
const PICKUP_RANGE = 0.62
const INPUT_DEADZONE = 0.16
const LOAD_DURATION = 0.30
const CLEAR_BONUS = 250
const WEIGHTS = {"LIGHT": 0.95, "MEDIUM": 0.85, "HEAVY": 0.70, "VERY_HEAVY": 0.60}
const UPGRADE_KEYS = ["strength", "grip", "carry", "capacity", "noise"]
# Economy V3: every location is a tier. A tier caps what the shop sells, and the
# next location opens only once every stat has reached its tier cap (the tier
# "loadout"). The 80 purchases are spread over the 13 locations so each one
# takes roughly 20 runs; a level's cash never outgrows what it must buy.
const TIER_CAPS = {
	"strength": [2, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5],
	"grip": [2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20],
	"carry": [2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20],
	"capacity": [6, 8, 10, 12, 14, 16, 20, 20, 20, 20, 20, 20, 20],
	"noise": [2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20]
}
const STRENGTH_CAPS = TIER_CAPS.strength
# A purchase costs its tier's price index times the stat's weight, so prices grow
# with the location's income (about 16 average hauls per tier loadout).
const TIER_PRICE = [850, 3600, 4500, 8500, 8500, 16500, 16500, 25000, 27000, 32000, 41000, 51000, 62000]
const UPGRADE_UNIT = {"strength": 1.6, "grip": 1.0, "carry": 1.0, "capacity": 1.3, "noise": 0.8}
const WALK_SPEED_STEP = 0.02
const NOISE = {"LIGHT": 4.0, "MEDIUM": 7.0, "HEAVY": 12.0, "VERY_HEAVY": 18.0}
# Awkward lifting at STR 1 makes even a small haul risky. STR 2 removes the
# largest penalty; subsequent upgrades refine handling without silencing clears.
const STRENGTH_NOISE = [2.0, 1.10, 1.04, 1.0, 0.96]
const ALARM_THRESHOLD_FACTOR = 0.65
const ALARM_WINDOW = 12.0
const PYRAMID_ALARM_WINDOW = 13.0 # The throne now sits at the back of the tomb.
const VILLA_ALARM_WINDOW = 26.0 # The wider four-wing villa needs a longer return after a full clear.
const ELECTRONICS_ALARM_WINDOW = 18.0 # The stock room adds one last long trip to the unchanged inventory.
const MANSION_ALARM_WINDOW = 32.0 # The estate's rear wings remain risky but physically clearable in Normal.
const LAB_ALARM_WINDOW = 30.0 # A symmetric three-bay route still leaves time to cross containment.
const MUSEUM_ALARM_WINDOW = 24.0 # Enough for the final circuit, but the alarm still forces an exit.
const ALARM_WARNING_FACTOR = 0.75
# Apartment Final Job pilot: a session-specific Alarm-escape window override (never
# changes the global ALARM_WINDOW used by every other mode/location).
const APARTMENT_FINAL_JOB_ALARM_WINDOW = 16.0
const NAMES = {"strength": "STRENGTH", "grip": "GRIP", "carry": "CARRY SPEED", "capacity": "VAN CAPACITY", "noise": "NOISE CONTROL"}
# Derived compatibility view; prices are calculated, never maintained as 76 literals.
static var COSTS: Dictionary = build_costs()
const OBJECTIVE_IDS = ["cash", "signature", "full_clear"]
const LOCATION_ORDER = ["apartment","house","villa","electronics","mansion","laboratory","museum","pyramid","castle","pirate_ship","vikings","english_pub","prehistoric"]
const MODES = ["normal", "rush", "small_van", "client_order", "special", "FINAL_JOB"]
const ITEMS = {
	"prehistoric_skull": {"display_name":"MAMMOTH SKULL", "cash_value":5200, "cargo_space":8, "required_strength":5, "pickup_duration":3.0, "weight_class":"VERY_HEAVY", "radius":1.0},
	"prehistoric_saber": {"display_name":"SABER-TOOTH SKULL", "cash_value":4300, "cargo_space":7, "required_strength":5, "pickup_duration":2.8, "weight_class":"VERY_HEAVY", "radius":0.65},
	"prehistoric_mortar": {"display_name":"STONE MORTAR", "cash_value":2500, "cargo_space":6, "required_strength":4, "pickup_duration":2.0, "weight_class":"HEAVY", "radius":0.60},
	"prehistoric_hide": {"display_name":"HIDE DRYING RACK", "cash_value":2800, "cargo_space":6, "required_strength":4, "pickup_duration":2.0, "weight_class":"HEAVY", "radius":0.72},
	"prehistoric_spear": {"display_name":"FLINT SPEAR", "cash_value":1100, "cargo_space":2, "required_strength":2, "pickup_duration":0.9, "weight_class":"MEDIUM", "radius":0.4},
	"prehistoric_drum": {"display_name":"HIDE DRUM", "cash_value":1700, "cargo_space":3, "required_strength":2, "pickup_duration":1.1, "weight_class":"MEDIUM", "radius":0.45},
	"prehistoric_amber": {"display_name":"ANCIENT AMBER", "cash_value":1900, "cargo_space":1, "required_strength":1, "pickup_duration":0.6, "weight_class":"LIGHT", "radius":0.34},
	"prehistoric_painting": {"display_name":"CAVE PAINTING", "cash_value":3600, "cargo_space":6, "required_strength":4, "pickup_duration":2.2, "weight_class":"HEAVY", "radius":0.65},
	"prehistoric_fur": {"display_name":"FUR BEDROLL", "cash_value":1400, "cargo_space":3, "required_strength":2, "pickup_duration":1.0, "weight_class":"MEDIUM", "radius":0.45},
	"prehistoric_necklace": {"display_name":"SHELL NECKLACE", "cash_value":1200, "cargo_space":2, "required_strength":1, "pickup_duration":0.7, "weight_class":"LIGHT", "radius":0.34},
	"pub_billiards": {"display_name":"BILLIARD TABLE", "cash_value":4200, "cargo_space":8, "required_strength":5, "pickup_duration":3.0, "weight_class":"VERY_HEAVY", "radius":1.12},
	"pub_clock": {"display_name":"GRANDFATHER CLOCK", "cash_value":3600, "cargo_space":7, "required_strength":4, "pickup_duration":2.3, "weight_class":"HEAVY", "radius":0.57},
	"pub_settee": {"display_name":"LEATHER SETTEE", "cash_value":2800, "cargo_space":7, "required_strength":4, "pickup_duration":2.0, "weight_class":"HEAVY", "radius":0.85},
	"pub_register": {"display_name":"BRASS CASH REGISTER", "cash_value":2400, "cargo_space":5, "required_strength":3, "pickup_duration":1.8, "weight_class":"HEAVY", "radius":0.45},
	"pub_beer_engine": {"display_name":"BEER ENGINE", "cash_value":2000, "cargo_space":5, "required_strength":3, "pickup_duration":1.8, "weight_class":"HEAVY", "radius":0.45},
	"pub_gramophone": {"display_name":"GRAMOPHONE", "cash_value":1500, "cargo_space":3, "required_strength":2, "pickup_duration":1.1, "weight_class":"MEDIUM", "radius":0.45},
	"pub_radio": {"display_name":"VALVE RADIO", "cash_value":900, "cargo_space":2, "required_strength":1, "pickup_duration":0.8, "weight_class":"LIGHT", "radius":0.43},
	"pub_darts": {"display_name":"DARTBOARD", "cash_value":800, "cargo_space":2, "required_strength":1, "pickup_duration":0.8, "weight_class":"LIGHT", "radius":0.50},
	"pub_tankard": {"display_name":"GOLDEN TANKARD", "cash_value":1200, "cargo_space":1, "required_strength":1, "pickup_duration":0.7, "weight_class":"LIGHT", "radius":0.32},
	"pub_sign": {"display_name":"BRASS FOX SIGN", "cash_value":1600, "cargo_space":4, "required_strength":2, "pickup_duration":1.2, "weight_class":"MEDIUM", "radius":0.6},
	"viking_runestone": {"display_name":"RUNIC STONE", "cash_value":3200, "cargo_space":8, "required_strength":5, "pickup_duration":2.8, "weight_class":"VERY_HEAVY", "radius":0.65},
	"viking_anvil": {"display_name":"FORGE ANVIL", "cash_value":2400, "cargo_space":8, "required_strength":5, "pickup_duration":2.7, "weight_class":"VERY_HEAVY", "radius":0.65},
	"viking_shield": {"display_name":"ROUND SHIELD", "cash_value":1000, "cargo_space":3, "required_strength":2, "pickup_duration":1.0, "weight_class":"MEDIUM", "radius":0.5},
	"viking_axe": {"display_name":"BEARDED AXE", "cash_value":850, "cargo_space":2, "required_strength":2, "pickup_duration":0.9, "weight_class":"MEDIUM", "radius":0.40},
	"viking_helmet": {"display_name":"IRON HELMET", "cash_value":650, "cargo_space":1, "required_strength":1, "pickup_duration":0.6, "weight_class":"LIGHT", "radius":0.34},
	"viking_horn": {"display_name":"DRINKING HORN", "cash_value":600, "cargo_space":1, "required_strength":1, "pickup_duration":0.55, "weight_class":"LIGHT", "radius":0.32},
	"viking_cauldron": {"display_name":"FEAST CAULDRON", "cash_value":1600, "cargo_space":5, "required_strength":4, "pickup_duration":1.7, "weight_class":"HEAVY", "radius":0.57},
	"viking_loom": {"display_name":"NORDIC LOOM", "cash_value":1800, "cargo_space":5, "required_strength":4, "pickup_duration":1.8, "weight_class":"HEAVY", "radius":0.6},
	"viking_throne": {"display_name":"JARL'S THRONE", "cash_value":3600, "cargo_space":8, "required_strength":5, "pickup_duration":3.2, "weight_class":"VERY_HEAVY", "radius":0.75},
	"viking_raven": {"display_name":"GILDED RAVEN", "cash_value":1300, "cargo_space":3, "required_strength":2, "pickup_duration":1.1, "weight_class":"MEDIUM", "radius":0.5},
	"pirate_spyglass": {"display_name":"SPYGLASS", "cash_value":350, "cargo_space":1, "required_strength":1, "pickup_duration":0.55, "weight_class":"LIGHT", "radius":0.30},
	"pirate_sextant": {"display_name":"BRASS SEXTANT", "cash_value":450, "cargo_space":1, "required_strength":1, "pickup_duration":0.65, "weight_class":"LIGHT", "radius":0.35},
	"pirate_compass": {"display_name":"CAPTAIN'S COMPASS", "cash_value":500, "cargo_space":1, "required_strength":1, "pickup_duration":0.6, "weight_class":"LIGHT", "radius":0.35},
	"pirate_parrot": {"display_name":"PIRATE PARROT", "cash_value":850, "cargo_space":2, "required_strength":2, "pickup_duration":1.0, "weight_class":"MEDIUM", "radius":0.40},
	"pirate_rum": {"display_name":"AGED RUM", "cash_value":750, "cargo_space":3, "required_strength":2, "pickup_duration":1.0, "weight_class":"MEDIUM", "radius":0.55},
	"pirate_cannon": {"display_name":"DECK CANNON", "cash_value":1900, "cargo_space":8, "required_strength":5, "pickup_duration":2.5, "weight_class":"VERY_HEAVY", "radius":0.85},
	"pirate_anchor": {"display_name":"IRON ANCHOR", "cash_value":1800, "cargo_space":8, "required_strength":5, "pickup_duration":2.5, "weight_class":"VERY_HEAVY", "radius":0.70},
	"pirate_wheel": {"display_name":"SHIP'S WHEEL", "cash_value":1400, "cargo_space":5, "required_strength":4, "pickup_duration":1.6, "weight_class":"HEAVY", "radius":0.62},
	"pirate_chest": {"display_name":"CAPTAIN'S CHEST", "cash_value":3000, "cargo_space":8, "required_strength":5, "pickup_duration":3.2, "weight_class":"VERY_HEAVY", "radius":0.80},
	"pirate_figurehead": {"display_name":"GOLDEN KRAKEN", "cash_value":2200, "cargo_space":7, "required_strength":4, "pickup_duration":1.9, "weight_class":"HEAVY", "radius":0.65},
	"floor_lamp": {"display_name":"FLOOR LAMP", "cash_value":140, "cargo_space":2, "required_strength":1, "pickup_duration":0.8, "weight_class":"MEDIUM", "radius":0.55},
	"table_fan": {"display_name":"DESK FAN", "cash_value":50, "cargo_space":1, "required_strength":1, "pickup_duration":0.5, "weight_class":"LIGHT", "radius":0.35},
	"laptop": {"display_name":"LAPTOP", "cash_value":70, "cargo_space":1, "required_strength":1, "pickup_duration":0.5, "weight_class":"LIGHT", "radius":0.38},
	"microwave": {"display_name":"MICROWAVE", "cash_value":120, "cargo_space":2, "required_strength":1, "pickup_duration":0.8, "weight_class":"MEDIUM", "radius":0.4},
	"chair": {
		"display_name": "CHAIR",
		"cash_value": 50,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.35
	},
	"monitor": {
		"display_name": "MONITOR",
		"cash_value": 70,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.38
	},
	"small_tv": {
		"display_name": "SMALL TV",
		"cash_value": 140,
		"cargo_space": 2,
		"required_strength": 1,
		"pickup_duration": 0.8,
		"weight_class": "MEDIUM",
		"radius": 0.55
	},
	"printer": {
		"display_name": "PRINTER",
		"cash_value": 120,
		"cargo_space": 2,
		"required_strength": 1,
		"pickup_duration": 0.8,
		"weight_class": "MEDIUM",
		"radius": 0.4
	},
	"rubber_duck": {
		"display_name": "RUBBER DUCK",
		"cash_value": 180,
		"cargo_space": 2,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.32
	},
	"gaming_pc": {
		"display_name": "GAMING PC",
		"cash_value": 450,
		"cargo_space": 3,
		"required_strength": 1,
		"pickup_duration": 1,
		"weight_class": "MEDIUM",
		"radius": 0.44
	},
	"toilet": {
		"display_name": "TOILET",
		"cash_value": 220,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1.1,
		"weight_class": "MEDIUM",
		"radius": 0.45
	},
	"fridge": {
		"display_name": "FRIDGE",
		"cash_value": 340,
		"cargo_space": 4,
		"required_strength": 2,
		"pickup_duration": 1.5,
		"weight_class": "HEAVY",
		"radius": 0.52
	},
	"small_safe": {
		"display_name": "SMALL SAFE",
		"cash_value": 500,
		"cargo_space": 4,
		"required_strength": 3,
		"pickup_duration": 2.5,
		"weight_class": "VERY_HEAVY",
		"radius": 0.48
	},
	"tool_cabinet": {
		"display_name": "TOOL CABINET",
		"cash_value": 380,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1.1,
		"weight_class": "HEAVY",
		"radius": 0.47
	},
	"bathtub": {
		"display_name": "BATHTUB",
		"cash_value": 380,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1.3,
		"weight_class": "HEAVY",
		"radius": 0.62
	},
	"sofa": {
		"display_name": "SOFA",
		"cash_value": 450,
		"cargo_space": 5,
		"required_strength": 2,
		"pickup_duration": 1.7,
		"weight_class": "VERY_HEAVY",
		"radius": 0.70
	},
	"arcade_machine": {
		"display_name": "ARCADE MACHINE",
		"cash_value": 650,
		"cargo_space": 5,
		"required_strength": 3,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.6
	},
	"vending_machine": {
		"display_name": "VENDING MACHINE",
		"cash_value": 850,
		"cargo_space": 5,
		"required_strength": 4,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.62
	},
	"piano": {
		"display_name": "PIANO",
		"cash_value": 1000,
		"cargo_space": 6,
		"required_strength": 4,
		"pickup_duration": 3,
		"weight_class": "VERY_HEAVY",
		"radius": 0.8
	},
	"large_statue": {
		"display_name": "LARGE STATUE",
		"cash_value": 1500,
		"cargo_space": 8,
		"required_strength": 5,
		"pickup_duration": 3.5,
		"weight_class": "VERY_HEAVY",
		"radius": 0.6
	},
	"pink_flamingo": {
		"display_name": "PINK FLAMINGO",
		"cash_value": 80,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.35
	},
	"museum_artifact": {
		"display_name": "GIANT DIAMOND",
		"cash_value": 2500,
		"cargo_space": 8,
		"required_strength": 5,
		"pickup_duration": 3.5,
		"weight_class": "VERY_HEAVY",
		"radius": 0.72
	},
	"time_machine": {
		"display_name": "TIME MACHINE",
		"cash_value": 2000,
		"cargo_space": 8,
		"required_strength": 5,
		"pickup_duration": 3.5,
		"weight_class": "VERY_HEAVY",
		"radius": 0.78
	},
	"ancient_relic": {
		"display_name": "ANCIENT RELIC",
		"cash_value": 650,
		"cargo_space": 3,
		"required_strength": 3,
		"pickup_duration": 1.2,
		"weight_class": "MEDIUM",
		"radius": 0.43
	},
	"canopic_jar": {
		"display_name": "CANOPIC JAR",
		"cash_value": 300,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.3
	},
	"pharaoh_mask": {
		"display_name": "GOLDEN PHARAOH MASK",
		"cash_value": 900,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.8,
		"weight_class": "LIGHT",
		"radius": 0.32
	},
	"treasure_chest": {
		"display_name": "TREASURE CHEST",
		"cash_value": 600,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1,
		"weight_class": "MEDIUM",
		"radius": 0.45
	},
	"giant_scarab": {
		"display_name": "GIANT SCARAB",
		"cash_value": 650,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1,
		"weight_class": "MEDIUM",
		"radius": 0.45
	},
	"pharaoh_bust": {
		"display_name": "PHARAOH BUST",
		"cash_value": 900,
		"cargo_space": 5,
		"required_strength": 3,
		"pickup_duration": 1.2,
		"weight_class": "MEDIUM",
		"radius": 0.42
	},
	"obelisk_fragment": {
		"display_name": "OBELISK FRAGMENT",
		"cash_value": 1300,
		"cargo_space": 6,
		"required_strength": 4,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.45
	},
	"giant_anubis": {
		"display_name": "GIANT ANUBIS",
		"cash_value": 1450,
		"cargo_space": 6,
		"required_strength": 4,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.5
	},
	"golden_throne": {
		"display_name": "GOLDEN THRONE",
		"cash_value": 1700,
		"cargo_space": 7,
		"required_strength": 5,
		"pickup_duration": 1.4,
		"weight_class": "VERY_HEAVY",
		"radius": 0.6
	},
	"sarcophagus": {
		"display_name": "SARCOPHAGUS",
		"cash_value": 1800,
		"cargo_space": 8,
		"required_strength": 5,
		"pickup_duration": 1.4,
		"weight_class": "VERY_HEAVY",
		"radius": 0.7
	},
	"crown_display": {
		"display_name": "CROWN DISPLAY",
		"cash_value": 700,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.8,
		"weight_class": "LIGHT",
		"radius": 0.32
	},
	"blood_chalice": {
		"display_name": "BLOOD CHALICE",
		"cash_value": 400,
		"cargo_space": 1,
		"required_strength": 1,
		"pickup_duration": 0.5,
		"weight_class": "LIGHT",
		"radius": 0.28
	},
	"vampire_portrait": {
		"display_name": "VAMPIRE PORTRAIT",
		"cash_value": 600,
		"cargo_space": 2,
		"required_strength": 1,
		"pickup_duration": 0.6,
		"weight_class": "LIGHT",
		"radius": 0.38
	},
	"relic_chest": {
		"display_name": "RELIC CHEST",
		"cash_value": 850,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1,
		"weight_class": "MEDIUM",
		"radius": 0.45
	},
	"bat_idol": {
		"display_name": "BAT IDOL",
		"cash_value": 650,
		"cargo_space": 3,
		"required_strength": 2,
		"pickup_duration": 1,
		"weight_class": "MEDIUM",
		"radius": 0.42
	},
	"gargoyle_statue": {
		"display_name": "GARGOYLE STATUE",
		"cash_value": 900,
		"cargo_space": 5,
		"required_strength": 3,
		"pickup_duration": 1.2,
		"weight_class": "MEDIUM",
		"radius": 0.45
	},
	"gothic_mirror": {
		"display_name": "GOTHIC MIRROR",
		"cash_value": 1200,
		"cargo_space": 6,
		"required_strength": 4,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.45
	},
	"pipe_organ": {
		"display_name": "PIPE ORGAN",
		"cash_value": 1400,
		"cargo_space": 6,
		"required_strength": 4,
		"pickup_duration": 2,
		"weight_class": "HEAVY",
		"radius": 0.6
	},
	"skull_candelabrum": {
		"display_name": "SKULL CANDELABRUM",
		"cash_value": 500,
		"cargo_space": 2,
		"required_strength": 1,
		"pickup_duration": 0.6,
		"weight_class": "LIGHT",
		"radius": 0.3
	},
	"vampire_throne": {
		"display_name": "VAMPIRE THRONE",
		"cash_value": 1700,
		"cargo_space": 7,
		"required_strength": 5,
		"pickup_duration": 2.5,
		"weight_class": "VERY_HEAVY",
		"radius": 0.6
	},
	"dracula_coffin": {
		"display_name": "DRACULA COFFIN",
		"cash_value": 2000,
		"cargo_space": 8,
		"required_strength": 5,
		"pickup_duration": 2.0,
		"weight_class": "VERY_HEAVY",
		"radius": 0.7
	},
	"lab_microscope": {"display_name":"MICROSCOPE", "cash_value":200, "cargo_space":1, "required_strength":1, "pickup_duration":0.6, "weight_class":"LIGHT", "radius":0.36},
	"lab_analyzer": {"display_name":"CHEMICAL ANALYZER", "cash_value":350, "cargo_space":2, "required_strength":2, "pickup_duration":0.9, "weight_class":"MEDIUM", "radius":0.44},
	"lab_centrifuge": {"display_name":"CENTRIFUGE", "cash_value":650, "cargo_space":4, "required_strength":3, "pickup_duration":1.5, "weight_class":"HEAVY", "radius":0.58},
	"lab_server": {"display_name":"DATA RACK", "cash_value":600, "cargo_space":4, "required_strength":3, "pickup_duration":1.4, "weight_class":"MEDIUM", "radius":0.53},
	"lab_robot_arm": {"display_name":"ROBOTIC ARM", "cash_value":750, "cargo_space":5, "required_strength":4, "pickup_duration":1.8, "weight_class":"HEAVY", "radius":0.58},
	"lab_laser": {"display_name":"LASER EMITTER", "cash_value":850, "cargo_space":4, "required_strength":4, "pickup_duration":1.7, "weight_class":"HEAVY", "radius":0.55},
	"lab_specimen": {"display_name":"SPECIMEN TANK", "cash_value":950, "cargo_space":5, "required_strength":4, "pickup_duration":1.9, "weight_class":"HEAVY", "radius":0.60},
	"lab_cryo_pod": {"display_name":"CRYO POD", "cash_value":1300, "cargo_space":7, "required_strength":5, "pickup_duration":2.5, "weight_class":"VERY_HEAVY", "radius":0.68},
	"lab_quantum_core": {"display_name":"QUANTUM CORE", "cash_value":1600, "cargo_space":7, "required_strength":5, "pickup_duration":2.8, "weight_class":"VERY_HEAVY", "radius":0.70}
}
# Spawn row: stable instance ID, type ID, x, z, optional independent trophy ID.
# Pyramid (Chapter 2) is designed backward from its Final Job budget: 44 cargo (fits Van
# L19, under MAX 46), 100 base Noise, fixed 65 threshold. Everything except the Throne and
# the Sarcophagus sums to 64 Noise, so a smart route reaches 64/65 and the first of the two
# VERY_HEAVY pieces trips the 12s alarm (also at Noise MAX: 51.84 -> 66.42). Rows are in the
# intended route order. Throne and Sarcophagus share the Burial Chamber (approved floor
# plan), so the post-alarm sprint is two deep trips: tight without Grip/Carry upgrades.
# Dracula's Castle (Chapter 2) follows the same backward budget: 44 cargo, 97 base Noise,
# 63.05 threshold. Everything but the Throne and Coffin is 61 Noise; the Throne trips the
# alarm (Noise MAX: 49.41 -> 63.99), then one short Coffin run from the Crypt by the breach.
# "signature_items" (optional) requires every listed type in one run for objective 2.
const LOCATIONS = {
	"prehistoric": {
		"name":"PREHISTORIC ERA", "duration":85, "threshold":10000, "special":"prehistoric_skull",
		"objectives":["ESCAPE WITH $10000","STEAL THE MAMMOTH SKULL","STEAL EVERYTHING"],
		"expected_cargo":44, "expected_value":25700,
		"items":[
			["mammoth","prehistoric_skull",0,-8.9],
			["saber","prehistoric_saber",-4.25,-7.25],
			["painting","prehistoric_painting",3.75,-7.6],
			["hide","prehistoric_hide",-4.6,-3.7],
			["spear","prehistoric_spear",4.5,-4.3],
			["necklace","prehistoric_necklace",4.5,-1.8],
			["amber","prehistoric_amber",-3.3,1.15,"prehistoric_amber"],
			["mortar","prehistoric_mortar",-4.5,-0.6],
			["drum","prehistoric_drum",3.8,1.1],
			["fur","prehistoric_fur",2.4,-1.4]
		]
	},
	"english_pub": {
		"name":"ENGLISH PUB · 1932", "duration":85, "threshold":8500, "special":"pub_billiards",
		"objectives":["ESCAPE WITH $8500","STEAL THE BILLIARD TABLE","STEAL EVERYTHING"],
		"expected_cargo":44, "expected_value":21000,
		"items":[
			["billiards","pub_billiards",-3.9,-6.9],
			["clock","pub_clock",4.8,-8.3],
			["settee","pub_settee",3.7,-6.15],
			["gramophone","pub_gramophone",-4.6,-3.0],
			["radio","pub_radio",4.3,-3.45],
			["darts","pub_darts",-5.2,-0.4],
			["tankard","pub_tankard",-4.9,1.35,"pub_tankard"],
			["register","pub_register",4.10,0.9],
			["pumps","pub_beer_engine",4.10,-1.0],
			["sign","pub_sign",-2.6,0.1]
		]
	},
	"vikings": {
		"name":"VIKING HALL", "duration":85, "threshold":7000, "special":"viking_throne",
		"objectives":["ESCAPE WITH $7000","STEAL THE JARL'S THRONE","STEAL EVERYTHING"],
		"expected_cargo":44, "expected_value":17000,
		"items":[
			["throne","viking_throne",0,-8.05],
			["runestone","viking_runestone",-4.6,-7.9],
			["loom","viking_loom",4.5,-7.9],
			["helmet","viking_helmet",-3.5,-5.8],
			["horn","viking_horn",3.5,-6.5],
			["axe","viking_axe",-4.4,-3.8],
			["shield","viking_shield",4.4,-3.4],
			["cauldron","viking_cauldron",3.7,-0.8],
			["anvil","viking_anvil",-4.3,-1.4],
			["raven","viking_raven",3.5,1.4,"viking_raven"]
		]
	},
	"pirate_ship": {
		"name": "PIRATE SHIP", "duration": 80, "threshold": 5500,
		"special": "pirate_chest", "objectives": ["ESCAPE WITH $5500", "STEAL THE CAPTAIN'S CHEST", "STEAL EVERYTHING"],
		"expected_cargo": 44, "expected_value": 13200,
		"items": [
			["anchor","pirate_anchor",2.3,-5.9],
			["cannon","pirate_cannon",-3.7,-4.4],
			["kraken","pirate_figurehead",0,-9.2],
			["spyglass","pirate_spyglass",-1.3,-7.25],
			["sextant","pirate_sextant",2.95,1.55],
			["compass","pirate_compass",3.9,1.55],
			["parrot","pirate_parrot",3.4,-3.15,"pirate_parrot"],
			["rum","pirate_rum",-3.8,-1.2],
			["wheel","pirate_wheel",3.35,-1.5],
			["chest","pirate_chest",-3.1,1.4]
		]
	},
	"apartment": {
		"name": "APARTMENT",
		"duration": 60,
		"threshold": 300,
		"special": "fridge",
		"objectives": [
			"ESCAPE WITH $300",
			"ESCAPE WITH FRIDGE",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 17,
		"expected_value": 1210,
		"items": [
			["tv_a", "small_tv", -3.03, 1.30],
			["chair_a", "chair", -1.62, 1.45],
			["lamp", "floor_lamp", -2.85, 2.65],
			["fan", "table_fan", 1.90, 0.97],
			["laptop", "laptop", 2.93, 0.97],
			["microwave", "microwave", -1.05, -2.92],
			["toilet", "toilet", 2.83, -1.85],
			["fridge", "fridge", -2.75, -1.25],
			["flamingo", "pink_flamingo", 2.95, 2.62, "flamingo"]
		]
	},
	"house": {
		"name": "SUBURBAN HOUSE",
		"duration": 60,
		"threshold": 800,
		"special": "sofa",
		"objectives": [
			"ESCAPE WITH $800",
			"ESCAPE WITH SOFA",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 23,
		"expected_value": 2140,
		"items": [
			["tv", "small_tv", 2.90, -7.00],
			["chair", "chair", 2.15, 1.30],
			["tools", "tool_cabinet", -3.92, -1.12],
			["duck", "rubber_duck", -4.45, -5.30, "duck"],
			["toilet", "toilet", -0.72, -4.15],
			["fridge", "fridge", 4.15, -0.80],
			["tub", "bathtub", -3.80, -6.55],
			["sofa", "sofa", 2.90, -4.10]
		]
	},
	"villa": {
		"name": "VILLA",
		"duration": 70,
		"threshold": 1600,
		"special": "piano",
		"objectives": [
			"ESCAPE WITH $1600",
			"ESCAPE WITH PIANO",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 28,
		"expected_value": 3260,
		"items": [
			["piano", "piano", -3.75, -7.75, "villa_piano"],
			["tub", "bathtub", 3.02, -8.05],
			["toilet", "toilet", 5.48, -4.45],
			["sofa", "sofa", -4.14, 1.65],
			["safe", "small_safe", 4.55, -2.50],
			["pc", "gaming_pc", 5.25, 2.04],
			["tv", "small_tv", -4.13, -2.64],
			["chair", "chair", -3.75, -6.35],
			["monitor", "monitor", 5.30, 0.30]
		]
	},
	"electronics": {
		"name": "ELECTRONICS STORE",
		"duration": 65,
		"economy_duration": 60,
		"threshold": 2200,
		"special": "vending_machine",
		"objectives": [
			"ESCAPE WITH $2200",
			"ESCAPE WITH VENDING MACHINE",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 32,
		"expected_value": 4060,
		"items": [
			["vending", "vending_machine", -5.72, 1.24, "electronics_vending"],
			["arcade_a", "arcade_machine", -5.30, -1.35],
			["arcade_b", "arcade_machine", -3.35, -1.35],
			["pc_a", "gaming_pc", -4.90, -4.50],
			["pc_b", "gaming_pc", -2.80, -4.50],
			["pc_c", "gaming_pc", 4.75, -4.50],
			["tv_a", "small_tv", 2.35, -2.10],
			["tv_b", "small_tv", 3.95, -2.10],
			["tv_c", "small_tv", 5.55, -2.10],
			["monitor_a", "monitor", 3.15, 0.65],
			["monitor_b", "monitor", 5.15, 0.65]
		]
	},
	"mansion": {
		"name": "MANSION",
		"duration": 85,
		"economy_duration": 80,
		"threshold": 3000,
		"special": "large_statue",
		"objectives": [
			"ESCAPE WITH $3000",
			"ESCAPE WITH LARGE STATUE",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 38,
		"expected_value": 5170,
		"items": [
			["statue", "large_statue", -4.80, -8.70, "mansion_statue"],
			["piano", "piano", 4.80, -9.15],
			["safe_a", "small_safe", -5.90, -5.40],
			["safe_b", "small_safe", 6.10, -6.40],
			["fridge", "fridge", 6.44, 2.13],
			["pc_a", "gaming_pc", -6.24, -1.80],
			["pc_b", "gaming_pc", 3.42, -4.90],
			["tv", "small_tv", -3.13, 1.24],
			["toilet", "toilet", 6.50, -2.12],
			["monitor", "monitor", -6.15, -3.35]
		]
	},
	"laboratory": {
		"name": "LABORATORY",
		"duration": 90,
		"economy_duration": 85,
		"threshold": 3700,
		"special": "lab_quantum_core",
		"objectives": ["ESCAPE WITH $3700", "ESCAPE WITH QUANTUM CORE", "STEAL EVERYTHING"],
		"expected_cargo": 39,
		"expected_value": 7250,
		"items": [
			["microscope", "lab_microscope", -4.7, 0.60],
			["analyzer", "lab_analyzer", 4.7, 0.60],
			["centrifuge", "lab_centrifuge", -4.7, -3.3],
			["data_rack", "lab_server", 4.7, -3.3],
			["robot_arm", "lab_robot_arm", -4.7, -7.1],
			["laser", "lab_laser", 4.7, -7.1],
			["specimen", "lab_specimen", -4.8, -10.0],
			["cryo_pod", "lab_cryo_pod", 4.8, -10.0],
			["core", "lab_quantum_core", 0.0, -10.0, "lab_core"]
		]
	},
	"museum": {
		"name": "MUSEUM",
		"duration": 85,
		"economy_duration": 80,
		"threshold": 4000,
		"special": "museum_artifact",
		"objectives": [
			"ESCAPE WITH $4000",
			"ESCAPE WITH GIANT DIAMOND",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 45,
		"expected_value": 9700,
		"items": [
			[
				"artifact",
				"museum_artifact",
				0,
				-4.1,
				"museum_crown"
			],
			[
				"statue_a",
				"large_statue",
				5.55,
				-5.0
			],
			[
				"statue_b",
				"large_statue",
				5.55,
				-8.3
			],
			[
				"machine",
				"time_machine",
				0,
				-10.25
			],
			[
				"relic",
				"ancient_relic",
				-5.55,
				-7.5
			],
			[
				"chest",
				"treasure_chest",
				-5.55,
				-4.7
			],
			[
				"safe",
				"small_safe",
				-4.85,
				0.75
			],
			[
				"pc",
				"gaming_pc",
				-4.85,
				2.35
			]
		]
	},
	"pyramid": {
		"name": "PYRAMID",
		"duration": 60,
		"threshold": 5000,
		"special": "sarcophagus",
		"objectives": [
			"ESCAPE WITH $5000",
			"ESCAPE WITH SARCOPHAGUS",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 44,
		"expected_value": 10500,
		"items": [
			[
				"jar_a",
				"canopic_jar",
				2.3,
				2.0
			],
			[
				"jar_b",
				"canopic_jar",
				3.9,
				2.0
			],
			[
				"chest_a",
				"treasure_chest",
				-0.85,
				1.60
			],
			[
				"chest_b",
				"treasure_chest",
				0.85,
				1.60
			],
			[
				"mask",
				"pharaoh_mask",
				-2.2,
				-3.15
			],
			[
				"scarab",
				"giant_scarab",
				2.2,
				-3.15
			],
			[
				"anubis",
				"giant_anubis",
				-4.05,
				0.45
			],
			[
				"obelisk",
				"obelisk_fragment",
				3.75,
				0.35
			],
			[
				"bust",
				"pharaoh_bust",
				2.4,
				0.35
			],
			[
				"sarcophagus",
				"sarcophagus",
				-3.25,
				1.90
			],
			[
				"throne",
				"golden_throne",
				0,
				-3.65
			]
		]
	},
	"castle": {
		"name": "DRACULA'S CASTLE",
		"duration": 60,
		"threshold": 4000,
		"special": "dracula_coffin",
		"signature_items": [
			"vampire_throne",
			"dracula_coffin"
		],
		"objectives": [
			"ESCAPE WITH $4000",
			"STEAL THRONE + COFFIN IN ONE RUN",
			"STEAL EVERYTHING"
		],
		"expected_cargo": 44,
		"expected_value": 10900,
		"items": [
			[
				"crown",
				"crown_display",
				0,
				0
			],
			[
				"chalice",
				"blood_chalice",
				-3.6,
				0.35
			],
			[
				"relic_chest",
				"relic_chest",
				-2.4,
				1.95
			],
			[
				"bat_idol",
				"bat_idol",
				-2.45,
				0.35
			],
			[
				"gargoyle",
				"gargoyle_statue",
				-3.75,
				1.95
			],
			[
				"candelabrum",
				"skull_candelabrum",
				2.0,
				0.6
			],
			[
				"portrait",
				"vampire_portrait",
				-2.8,
				-2.45
			],
			[
				"mirror",
				"gothic_mirror",
				3.3,
				0.3
			],
			[
				"organ",
				"pipe_organ",
				2.8,
				-2.45
			],
			[
				"throne",
				"vampire_throne",
				0,
				-2.45
			],
			[
				"coffin",
				"dracula_coffin",
				2.75,
				2.0
			]
		]
	}
}
const TROPHIES = {
	"flamingo": {
		"type_id": "pink_flamingo",
		"location": "apartment"
	},
	"duck": {
		"type_id": "rubber_duck",
		"location": "house"
	},
	"villa_piano": {
		"type_id": "piano",
		"location": "villa"
	},
	"electronics_vending": {
		"type_id": "vending_machine",
		"location": "electronics"
	},
	"mansion_statue": {
		"type_id": "large_statue",
		"location": "mansion"
	},
	"lab_core": {
		"type_id": "lab_quantum_core",
		"location": "laboratory"
	},
	"museum_crown": {
		"type_id": "museum_artifact",
		"location": "museum"
	},
	"pirate_parrot": {"type_id": "pirate_parrot", "location": "pirate_ship"},
	"viking_raven": {"type_id": "viking_raven", "location": "vikings"},
	"pub_tankard": {"type_id": "pub_tankard", "location": "english_pub"},
	"prehistoric_amber": {"type_id": "prehistoric_amber", "location": "prehistoric"}
}
const CONTRACTS = {
	"apartment.rush": {
		"location": "apartment",
		"mode": "rush",
		"name": "RUSH",
		"duration": 30,
		"capacity_limit": 44,
		"threshold": 800,
		"order": {},
		"bonus": 500
	},
	"apartment.small_van": {
		"location": "apartment",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 8,
		"threshold": 600,
		"order": {},
		"bonus": 500
	},
	"apartment.client_order": {
		"location": "apartment",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 30,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"fridge": 1,
			"toilet": 1,
			"pink_flamingo": 1
		},
		"bonus": 500
	},
	"house.rush": {
		"location": "house",
		"mode": "rush",
		"name": "RUSH",
		"duration": 30,
		"capacity_limit": 44,
		"threshold": 1400,
		"order": {},
		"bonus": 500
	},
	"house.small_van": {
		"location": "house",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 12,
		"threshold": 1200,
		"order": {},
		"bonus": 500
	},
	"house.client_order": {
		"location": "house",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 30,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"sofa": 1,
			"bathtub": 1,
			"rubber_duck": 1
		},
		"bonus": 500
	},
	"villa.rush": {
		"location": "villa",
		"mode": "rush",
		"name": "RUSH",
		"duration": 35,
		"capacity_limit": 44,
		"threshold": 2400,
		"order": {},
		"bonus": 1000
	},
	"villa.small_van": {
		"location": "villa",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 12,
		"threshold": 1600,
		"order": {},
		"bonus": 1000
	},
	"villa.client_order": {
		"location": "villa",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 35,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"piano": 1,
			"sofa": 1,
			"small_tv": 1
		},
		"bonus": 1000
	},
	"electronics.rush": {
		"location": "electronics",
		"mode": "rush",
		"name": "RUSH",
		"duration": 35,
		"capacity_limit": 44,
		"threshold": 3000,
		"order": {},
		"bonus": 1000
	},
	"electronics.small_van": {
		"location": "electronics",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 12,
		"threshold": 1800,
		"order": {},
		"bonus": 1000
	},
	"electronics.client_order": {
		"location": "electronics",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 35,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"vending_machine": 1,
			"gaming_pc": 2,
			"arcade_machine": 1
		},
		"bonus": 1000
	},
	"mansion.rush": {
		"location": "mansion",
		"mode": "rush",
		"name": "RUSH",
		"duration": 55,
		"capacity_limit": 44,
		"threshold": 3800,
		"order": {},
		"bonus": 1500
	},
	"mansion.small_van": {
		"location": "mansion",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 16,
		"threshold": 2400,
		"order": {},
		"bonus": 1500
	},
	"mansion.client_order": {
		"location": "mansion",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 50,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"large_statue": 1,
			"piano": 1,
			"small_safe": 2
		},
		"bonus": 1500
	},
	"laboratory.rush": {
		"location": "laboratory", "mode": "rush", "name": "RUSH",
		"duration": 55, "capacity_limit": 44, "threshold": 4200, "order": {}, "bonus": 1500
	},
	"laboratory.small_van": {
		"location": "laboratory", "mode": "small_van", "name": "SMALL VAN",
		"duration": 75, "capacity_limit": 16, "threshold": 2400, "order": {}, "bonus": 1500
	},
	"laboratory.client_order": {
		"location": "laboratory", "mode": "client_order", "name": "CLIENT ORDER",
		"duration": 60, "capacity_limit": 44, "threshold": 0,
		"order": {"lab_microscope": 1, "lab_analyzer": 1, "lab_quantum_core": 1}, "bonus": 1500
	},
	"museum.rush": {
		"location": "museum",
		"mode": "rush",
		"name": "RUSH",
		"duration": 35,
		"capacity_limit": 44,
		"threshold": 6000,
		"order": {},
		"bonus": 1500
	},
	"museum.small_van": {
		"location": "museum",
		"mode": "small_van",
		"name": "SMALL VAN",
		"duration": 60,
		"capacity_limit": 18,
		"threshold": 4000,
		"order": {},
		"bonus": 1500
	},
	"museum.client_order": {
		"location": "museum",
		"mode": "client_order",
		"name": "CLIENT ORDER",
		"duration": 45,
		"capacity_limit": 44,
		"threshold": 0,
		"order": {
			"museum_artifact": 1,
			"large_statue": 1,
			"time_machine": 1,
			"ancient_relic": 1
		},
		"bonus": 1500
	}
}
const VEHICLE_ORDER = ["vehicle_black", "vehicle_pickup", "vehicle_box", "vehicle_armored", "vehicle_luxury", "vehicle_hearse", "vehicle_pirate", "vehicle_pharaoh"]
const COSMETICS = {
	"vehicle_black": {"name":"BLACK VAN", "slot":"van", "price":8000, "color":"252d39", "reward":"", "vehicle_style":"black", "description":"Midnight paint. Chrome details."},
	"vehicle_pickup": {"name":"PICKUP", "slot":"van", "price":15000, "color":"cf6245", "reward":"", "vehicle_style":"pickup", "description":"Open bed. Ready for another haul."},
	"vehicle_box": {"name":"BOX VAN", "slot":"van", "price":25000, "color":"cbdce3", "reward":"", "vehicle_style":"box", "description":"A proper moving-day disguise."},
	"vehicle_armored": {"name":"ARMORED VAN", "slot":"van", "price":50000, "color":"53706b", "reward":"", "vehicle_style":"armored", "description":"Heavy steel. Serious presence."},
	"vehicle_luxury": {"name":"LUXURY GETAWAY VAN", "slot":"van", "price":80000, "color":"eee2bc", "reward":"", "vehicle_style":"luxury", "description":"Pearl paint and champagne gold."},
	"vehicle_hearse": {"name":"DRACULA HEARSE", "slot":"van", "price":100000, "color":"644766", "reward":"", "vehicle_style":"hearse", "description":"Gothic glass. A very quiet exit."},
	"vehicle_pirate": {"name":"PIRATE VAN", "slot":"van", "price":120000, "color":"318f99", "reward":"", "vehicle_style":"pirate", "description":"Wooden sides. A flag worth flying."},
	"vehicle_pharaoh": {"name":"PHARAOH VAN", "slot":"van", "price":150000, "color":"e3ba51", "reward":"", "vehicle_style":"pharaoh", "description":"Royal blue. Gold fit for a king."},
	"van_mint": {
		"name": "MINT GETAWAY",
		"slot": "van",
		"price": 5000,
		"color": "70dabc",
		"reward": ""
	},
	"van_coral": {
		"name": "CORAL GETAWAY",
		"slot": "van",
		"price": 5000,
		"color": "ed847a",
		"reward": ""
	},
	"suit_lucky": {"name":"LUCKY SUIT", "slot":"suit", "price":0, "color":"7d1fd6", "reward":"lucky", "description":"Only from the Lucky Shop."},
	"van_lucky": {"name":"LUCKY VAN", "slot":"van", "price":0, "color":"9822ed", "reward":"lucky", "description":"Only from the Lucky Shop."},
	"suit_plum": {
		"name": "PLUM SUIT",
		"slot": "suit",
		"price": 0,
		"gem_price": 50,
		"color": "945bca",
		"reward": ""
	},
	"set_midnight": {
		"name": "MIDNIGHT SET",
		"slot": "set",
		"price": 20000,
		"color": "5481ba",
		"reward": ""
	},
	"set_sunrise": {
		"name": "SUNRISE SET",
		"slot": "set",
		"price": 30000,
		"color": "ff9463",
		"reward": ""
	},
	"trophy_gold": {
		"name": "COLLECTOR GOLD",
		"slot": "set",
		"price": 0,
		"color": "e8bf4d",
		"reward": "trophies",
		"target": 7
	},
	"contract_6": {
		"name": "SILVER VAN",
		"slot": "van",
		"price": 0,
		"color": "c3cddd",
		"reward": "contracts",
		"target": 6
	},
	"contract_12": {
		"name": "MASTER SUIT",
		"slot": "suit",
		"price": 0,
		"color": "74d9ef",
		"reward": "contracts",
		"target": 12
	},
	"contract_18": {
		"name": "LEGEND SET",
		"slot": "set",
		"price": 0,
		"color": "d788ef",
		"reward": "contracts",
		"target": 18
	}
}

static func item(type_id: String) -> Dictionary:
	var data: Dictionary = ITEMS[type_id].duplicate(true)
	data["type_id"] = type_id
	data["visual_variant"] = type_id
	return data

static func max_level(key: String) -> int:
	return 5 if key == "strength" else 20

static func carry_factor(weight: String, level: int) -> float:
	# Recover the carrying penalty rather than hit the empty-speed cap after
	# two purchases. Every level helps every class; heavy loot gains the most.
	return 1.0 - (1.0 - WEIGHTS[weight]) / carry_multiplier(level)

static func walk_factor(level: int) -> float:
	return 1.0 + WALK_SPEED_STEP * (clampi(level, 1, 20) - 1)

static func walk_speed(level: int) -> float:
	return BASE_SPEED * walk_factor(level)

static func carry_speed(weight: String, level: int) -> float:
	return walk_speed(level) * carry_factor(weight, level)

static func pickup_time(base: float, level: int) -> float:
	return maxf(MIN_PICKUP, base / grip_speed(level))

static func totals(location: String) -> Dictionary:
	var result = {"cargo": 0, "value": 0}
	for spawn in LOCATIONS[location].items:
		result.cargo += ITEMS[spawn[1]].cargo_space
		result.value += ITEMS[spawn[1]].cash_value
	return result

static func session(location: String, mode: String, upgrades: Dictionary, special_type: String = SpecialJobs.DEFAULT_TYPE) -> Dictionary:
	var rules = {"mode": mode, "duration": float(LOCATIONS[location].duration), "capacity": van_capacity(upgrades.capacity), "contract_id": "", "alarm_window": ALARM_WINDOW}
	if location == "pyramid": rules.alarm_window = PYRAMID_ALARM_WINDOW
	if location == "pirate_ship" and mode == "normal": rules.alarm_window = 26.0
	if location == "vikings" and mode == "normal": rules.alarm_window = 30.0
	if location == "english_pub" and mode == "normal": rules.alarm_window = 28.0
	if location == "prehistoric" and mode == "normal": rules.alarm_window = 34.0
	if location == "villa" and mode == "normal": rules.alarm_window = VILLA_ALARM_WINDOW
	if location == "electronics" and mode == "normal": rules.alarm_window = ELECTRONICS_ALARM_WINDOW
	if location == "mansion" and mode == "normal": rules.alarm_window = MANSION_ALARM_WINDOW
	if location == "laboratory" and mode == "normal": rules.alarm_window = LAB_ALARM_WINDOW
	if location == "museum" and mode == "normal": rules.alarm_window = MUSEUM_ALARM_WINDOW
	if mode == SpecialJobs.MODE:
		rules.duration = SpecialJobs.definition(special_type).time_override
		rules["special_type"] = special_type
	elif mode == "FINAL_JOB":
		# Apartment mastery exam: same 60s duration and Van cap math as a normal
		# run, only the Alarm-escape window is widened for this session.
		rules.alarm_window = MUSEUM_ALARM_WINDOW if location == "museum" else APARTMENT_FINAL_JOB_ALARM_WINDOW
	elif mode != "normal":
		var id = location + "." + mode
		var contract: Dictionary = CONTRACTS[id]
		rules.duration = float(contract.duration)
		rules.capacity = mini(rules.capacity, contract.capacity_limit)
		rules.contract_id = id
	return rules

static func contract_met(id: String, cargo_value: int, counts: Dictionary) -> bool:
	var contract: Dictionary = CONTRACTS[id]
	if cargo_value < int(contract.threshold): return false
	for type_id in contract.order:
		if counts.get(type_id, 0) < contract.order[type_id]: return false
	return true

static func contract_description(id: String) -> String:
	var c: Dictionary = CONTRACTS[id]
	var text = "%ds · " % c.duration
	if c.mode == "small_van": text += "AT MOST %d CARGO · " % c.capacity_limit
	if c.threshold > 0: text += "ESCAPE WITH $%d" % c.threshold
	else:
		var parts = PackedStringArray()
		for type_id in c.order: parts.append("%d %s" % [c.order[type_id], ITEMS[type_id].display_name])
		text += " + ".join(parts)
	return text

static func effect(key: String, level: int) -> String:
	var next_level = mini(level + 1, max_level(key))
	match key:
		"strength":
			if level == max_level(key): return "ALL OBJECTS UNLOCKED"
			var unlocked = PackedStringArray()
			for id in ITEMS:
				if ITEMS[id].required_strength == next_level: unlocked.append(ITEMS[id].display_name)
			return "STR %d → %d · %d%% LESS PICKUP NOISE\nUNLOCKS %s" % [level, next_level, strength_noise_reduction(level), " + ".join(unlocked)]
		"grip":
			if level == max_level(key): return "PICKUP SPEED %d%% · MAX" % roundi(grip_speed(level) * 100)
			return "PICKUP SPEED %d%% → %d%%" % [roundi(grip_speed(level) * 100), roundi(grip_speed(next_level) * 100)]
		"carry":
			var parts = PackedStringArray()
			if level == max_level(key): parts.append("WALK %.2f m/s · MAX" % walk_speed(level))
			else: parts.append("WALK %.2f → %.2f m/s" % [walk_speed(level), walk_speed(next_level)])
			for weight in WEIGHTS:
				if level == max_level(key): parts.append("%s %.2f m/s · MAX" % [weight, carry_speed(weight, level)])
				else: parts.append("%s %.2f → %.2f m/s" % [weight, carry_speed(weight, level), carry_speed(weight, next_level)])
			return "\n".join(parts) + "\nEVERY LEVEL: +%d%% WALK SPEED, LESS LOOT DRAG" % roundi(WALK_SPEED_STEP * 100)
		"noise":
			if level == max_level(key): return "NOISE GENERATED %d%% · MAX" % roundi(noise_multiplier(level) * 100)
			return "NOISE GENERATED %d%% → %d%%" % [roundi(noise_multiplier(level) * 100), roundi(noise_multiplier(next_level) * 100)]
		"capacity":
			if level == max_level(key): return "CARGO POINTS %d · MAX" % van_capacity(level)
			return "CARGO POINTS %d → %d" % [van_capacity(level), van_capacity(next_level)]
	return ""


static func round_to_50(value: float) -> int:
	return int(floor(value / 50.0 + 0.5)) * 50

static func upgrade_cost(key: String, level: int) -> int:
	if key not in UPGRADE_KEYS or level < 1 or level >= max_level(key): return 0
	return round_to_50(float(UPGRADE_UNIT[key]) * TIER_PRICE[tier_of(key, level + 1)])

# The tier (location index) whose loadout first includes this level.
static func tier_of(key: String, level: int) -> int:
	var caps: Array = TIER_CAPS[key]
	for i in range(caps.size()):
		if caps[i] >= level: return i
	return caps.size() - 1

static func required_level(key: String, location: String) -> int:
	var index = LOCATION_ORDER.find(location)
	return TIER_CAPS[key][index] if index >= 0 else 1

static func build_costs() -> Dictionary:
	var costs: Dictionary = {}
	for key in UPGRADE_KEYS:
		costs[key] = []
		for level in range(1, max_level(key)): costs[key].append(upgrade_cost(key, level))
	return costs

static func grip_speed(level: int) -> float:
	return 1.0 + 0.12 * (clampi(level, 1, 20) - 1)

static func carry_multiplier(level: int) -> float:
	return 1.0 + 0.35 * (clampi(level, 1, 20) - 1)

static func powerup_requirement(location: String) -> int:
	return required_level("grip", location)

static func van_capacity(level: int) -> int:
	return 8 + 2 * (clampi(level, 1, 20) - 1)

static func noise_multiplier(level: int) -> float:
	return maxf(0.81, 1.0 - 0.01 * (clampi(level, 1, 20) - 1))

static func strength_noise_multiplier(level: int) -> float:
	return 2.4 if level <= 0 else float(STRENGTH_NOISE[clampi(level, 1, 5) - 1])

static func strength_noise_reduction(level: int) -> int:
	var next_level := mini(level + 1, max_level("strength"))
	return roundi((1.0 - strength_noise_multiplier(next_level) / strength_noise_multiplier(level)) * 100)

static func pickup_noise(weight: String, strength: int, noise: int) -> float:
	return float(NOISE[weight]) * strength_noise_multiplier(strength) * noise_multiplier(noise)

static func location_noise(location: String) -> float:
	var total = 0.0
	for spawn in LOCATIONS[location].items: total += NOISE[ITEMS[spawn[1]].weight_class]
	return total

static func alarm_threshold(location: String) -> float:
	return location_noise(location) * ALARM_THRESHOLD_FACTOR

static func unlocked_tier(data: Dictionary) -> int:
	var tier = 0
	for i in range(LOCATION_ORDER.size()):
		if LOCATION_ORDER[i] in data.unlocked: tier = i
	return tier

static func purchase_cap(key: String, data: Dictionary) -> int:
	return TIER_CAPS[key][unlocked_tier(data)]

static func tier_message(key: String, data: Dictionary) -> String:
	var level: int = data.upgrades[key]
	var caps: Array = TIER_CAPS[key]
	for i in range(unlocked_tier(data) + 1, LOCATION_ORDER.size()):
		if caps[i] > level:
			return "UNLOCK %s FOR LEVEL %d–%d" % [LOCATIONS[LOCATION_ORDER[i]].name, level + 1, caps[i]]
	return "ALL LOCATION TIERS UNLOCKED"
