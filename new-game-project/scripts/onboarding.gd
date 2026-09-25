class_name Onboarding
extends Node

enum Step { MOVE, GET_FIRST_ITEM, CARRY_FIRST_ITEM, LOAD_FIRST_ITEM, GET_SECOND_ITEM, CARRY_SECOND_ITEM, LOAD_SECOND_ITEM, GET_THIRD_ITEM, CARRY_THIRD_ITEM, LOAD_THIRD_ITEM, RETURN_TO_VAN, ESCAPE, COMPLETE }
const MOVE_DISTANCE = 0.65
var step = Step.MOVE
var run: RunManager
var first_item: LootItem
var second_item: LootItem
var third_item: LootItem
var replay = false
var active_elapsed = 0.0
var distance_moved = 0.0
var previous_position = Vector3.ZERO
var bank_explanation = 0.0

func setup(owner_run: RunManager, is_replay: bool) -> void:
	run = owner_run
	replay = is_replay
	previous_position = run.level.player.global_position
	for item in run.level.items:
		match item.data.type_id:
			"small_tv": first_item = item
			"gaming_pc": second_item = item
			"chair": third_item = item
	assert(first_item != null and second_item != null and third_item != null and run.level.training_layout, "Onboarding requires the separate practice garage and its three objects")
	if not run.store.session_only:
		if LocalLog.tutorial_attempted(run.store.path): log_event("tutorial_restarted")
		log_event("tutorial_started")

func log_event(kind: String, extra: Dictionary = {}) -> void:
	if run.store.session_only: return
	var details = {"profile": run.store.path, "replay": replay, "step": Step.keys()[step], "elapsed": snappedf(active_elapsed, 0.01)}
	details.merge(extra, true)
	LocalLog.onboarding_event(kind, details)

func advance(next: Step, completed: bool = true) -> void:
	if step == next: return
	if completed: log_event("tutorial_step_completed")
	step = next

func tick(delta: float) -> void:
	active_elapsed += delta
	bank_explanation = maxf(0, bank_explanation - delta)
	var current = run.level.player.global_position
	if step == Step.MOVE:
		# Real movement, not a key press, a timer or a stationary joystick.
		if run.intention.length() > Balance.INPUT_DEADZONE:
			distance_moved += minf(current.distance_to(previous_position), Balance.BASE_SPEED * delta * 1.5)
		if distance_moved >= MOVE_DISTANCE: advance(Step.GET_FIRST_ITEM)
	previous_position = current
	var at_van = run.level.van.in_zone(current)
	if run.carried != null and at_van:
		if step == Step.CARRY_FIRST_ITEM: advance(Step.LOAD_FIRST_ITEM)
		elif step == Step.CARRY_SECOND_ITEM: advance(Step.LOAD_SECOND_ITEM)
		elif step == Step.CARRY_THIRD_ITEM: advance(Step.LOAD_THIRD_ITEM)
	elif run.carried != null and not at_van:
		if step == Step.LOAD_FIRST_ITEM: advance(Step.CARRY_FIRST_ITEM, false)
		elif step == Step.LOAD_SECOND_ITEM: advance(Step.CARRY_SECOND_ITEM, false)
		elif step == Step.LOAD_THIRD_ITEM: advance(Step.CARRY_THIRD_ITEM, false)
	if step == Step.RETURN_TO_VAN and at_van and run.carried == null: advance(Step.ESCAPE)

func permits_pickup(item: LootItem) -> bool:
	if step == Step.GET_FIRST_ITEM: return item == first_item
	if step == Step.GET_SECOND_ITEM: return item == second_item
	return step == Step.GET_THIRD_ITEM and item == third_item

func picked_up(item: LootItem) -> void:
	if item == first_item: advance(Step.CARRY_FIRST_ITEM)
	elif item == second_item: advance(Step.CARRY_SECOND_ITEM)
	else: advance(Step.CARRY_THIRD_ITEM)

func loaded() -> void:
	if run.cargo.size() == 1:
		bank_explanation = 1.8
		advance(Step.GET_SECOND_ITEM)
	elif run.cargo.size() == 2: advance(Step.GET_THIRD_ITEM)
	else: advance(Step.RETURN_TO_VAN)

func dropped() -> void:
	advance(Step.GET_FIRST_ITEM if run.cargo.is_empty() else (Step.GET_SECOND_ITEM if run.cargo.size() == 1 else Step.GET_THIRD_ITEM), false)

func permits_escape() -> bool:
	return run.cargo.size() >= 3 and step in [Step.RETURN_TO_VAN, Step.ESCAPE]

func guide_item() -> LootItem:
	if step == Step.GET_FIRST_ITEM: return first_item
	if step == Step.GET_SECOND_ITEM: return second_item
	if step == Step.GET_THIRD_ITEM: return third_item
	return null

func guides_van() -> bool:
	return step in [Step.CARRY_FIRST_ITEM, Step.LOAD_FIRST_ITEM, Step.CARRY_SECOND_ITEM, Step.LOAD_SECOND_ITEM, Step.CARRY_THIRD_ITEM, Step.LOAD_THIRD_ITEM, Step.RETURN_TO_VAN, Step.ESCAPE]

func hint() -> String:
	if bank_explanation > 0: return "ESCAPE TO BANK YOUR LOOT"
	match step:
		Step.MOVE: return "DRAG TO MOVE"
		Step.GET_FIRST_ITEM:
			return "STOP TO PICK UP" if first_item.edge_distance(run.level.player.global_position) <= Balance.PICKUP_RANGE and run.level.accessible(first_item) else "GET THE TV"
		Step.CARRY_FIRST_ITEM, Step.CARRY_SECOND_ITEM, Step.CARRY_THIRD_ITEM: return "TAKE IT TO THE VAN"
		Step.LOAD_FIRST_ITEM, Step.LOAD_SECOND_ITEM, Step.LOAD_THIRD_ITEM: return "STOP TO LOAD"
		Step.GET_SECOND_ITEM: return "BIGGER LOOT TAKES MORE SPACE"
		Step.GET_THIRD_ITEM: return "FILL THE LAST SPACE · GET THE CHAIR"
		Step.RETURN_TO_VAN: return "RETURN TO THE VAN"
		Step.ESCAPE: return "ESCAPE & KEEP $%d" % run.cargo_value
	return "TUTORIAL COMPLETE"

func lesson_title() -> String:
	if step == Step.MOVE: return "1 / 4 · MOVE"
	if step == Step.GET_FIRST_ITEM: return "2 / 4 · STOP TO PICK UP"
	if step in [Step.CARRY_FIRST_ITEM,Step.LOAD_FIRST_ITEM]: return "3 / 4 · DELIVER"
	if step in [Step.RETURN_TO_VAN,Step.ESCAPE,Step.COMPLETE]: return "4 / 4 · ESCAPE TO KEEP IT"
	return "FILL THE VAN · %d / 3 ITEMS" % run.cargo.size()

func settle(success: bool) -> Dictionary:
	var earned = 0
	var wallet_before: int = run.store.data.wallet
	if success:
		advance(Step.COMPLETE)
		if not replay and not run.store.data.tutorial_completed:
			earned = run.cargo_value
			run.store.data.wallet += earned
			run.store.data.tutorial_completed = true
		log_event("tutorial_completed", {"banked": earned})
	var saved = run.store.save_progress() if success and not replay else true
	return {"tutorial": true, "replay": replay, "success": success, "earned": earned, "loot_value": run.cargo_value, "wallet_before": wallet_before, "saved": saved, "elapsed": active_elapsed, "mode": "tutorial"}
