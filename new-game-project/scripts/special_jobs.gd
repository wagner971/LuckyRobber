class_name SpecialJobs
extends RefCounted

const MODE = "special"
const DEFAULT_TYPE = "RUSH_HOUR"
const DEFINITIONS = {
	"RUSH_HOUR": {"id":"RUSH_HOUR", "display_name":"RUSH HOUR", "description":"35 SECONDS · +40% CASH", "time_override":35.0, "cash_multiplier":1.40}
}

static func roll_interval() -> int:
	return randi_range(2, 4)

static func definition(id: String) -> Dictionary:
	return DEFINITIONS[id]

static func can_play(data: Dictionary, location: String) -> bool:
	return data.special_pending and not data.special_in_progress and data.special_location_id == location and data.special_type in DEFINITIONS

static func bonus(base_loot: int, id: String) -> int:
	# Integer money: round once, after multiplying the secured total, never per item.
	return roundi(base_loot * (float(definition(id).cash_multiplier) - 1.0))

static func make_pending(data: Dictionary, location: String) -> void:
	if data.special_pending: return
	data.runs_since_special = data.special_interval
	data.special_pending = true
	data.special_type = DEFAULT_TYPE
	data.special_location_id = location
	LocalLog.event("special_job_available", {"type":data.special_type, "location":location, "interval":data.special_interval})

static func begin(data: Dictionary, location: String) -> void:
	if can_play(data, location): data.special_in_progress = true

static func consume(data: Dictionary) -> void:
	data.special_pending = false
	data.special_in_progress = false
	data.special_location_id = ""
	data.special_type = DEFAULT_TYPE
	data.runs_since_special = 0
	data.special_interval = roll_interval()

static func finish(data: Dictionary, mode: String, location: String, started: bool) -> bool:
	if not started: return false
	if mode == MODE:
		if data.special_pending and data.special_location_id == location: consume(data)
		return false
	if mode != "normal" or data.special_pending: return false
	data.runs_since_special += 1
	if data.runs_since_special >= data.special_interval:
		make_pending(data, location)
		return true
	return false
