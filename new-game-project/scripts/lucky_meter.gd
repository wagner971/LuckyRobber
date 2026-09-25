class_name LuckyMeter
extends RefCounted

# Every heist fills the meter; a full meter is a guaranteed Lucky Block. The
# random in-run block stays as a bonus on top, so blocks arrive every few runs
# even on unlucky streaks.
const TARGET := 100
const BASE_SUCCESS := 15
const PER_ITEM := 1
const MAX_ITEM_GAIN := 12
const OBJECTIVE_GAIN := 10
const FULL_CLEAR_GAIN := 15
const FAILURE_GAIN := 5
const BLOCK_TOKENS := {"positive": 1, "negative": 2}

static func gain_for(result: Dictionary) -> int:
	if not result.get("success", false): return FAILURE_GAIN
	var gain := BASE_SUCCESS + mini(MAX_ITEM_GAIN, int(result.get("items", 0)) * PER_ITEM)
	if not result.get("new_objectives", []).is_empty(): gain += OBJECTIVE_GAIN
	if result.get("full_clear", false): gain += FULL_CLEAR_GAIN
	return gain

static func tokens_for(effect_id: String) -> int:
	return BLOCK_TOKENS.positive if LuckyEffects.positive(effect_id) else BLOCK_TOKENS.negative

# Grants a pending block outcome plus its tokens in one place, so a block from the
# meter and a block carried out of a heist pay identically.
static func award_block(data: Dictionary, source: String) -> Dictionary:
	var effect_id := LuckyEffects.roll()
	var tokens := tokens_for(effect_id)
	data.lucky_pending = {"id": effect_id, "seen": false, "source": source, "tokens": tokens}
	data.lucky_tokens = mini(1000000, int(data.get("lucky_tokens", 0)) + tokens)
	data.lucky_blocks_found = int(data.get("lucky_blocks_found", 0)) + 1
	return data.lucky_pending

# Called once per settled run by the round authority. A block collected in the
# heist has priority; the meter then keeps its full charge for the next run.
static func settle(data: Dictionary, result: Dictionary) -> Dictionary:
	var before := int(data.get("lucky_meter", 0))
	var gain := gain_for(result)
	var meter := before + gain
	var awarded := false
	if meter >= TARGET and data.get("lucky_pending", {}).is_empty():
		meter -= TARGET
		award_block(data, "meter")
		awarded = true
	data.lucky_meter = mini(meter, TARGET)
	return {"before": before, "gain": gain, "after": int(data.lucky_meter), "awarded": awarded}
