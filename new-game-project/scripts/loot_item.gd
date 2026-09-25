class_name LootItem
extends Node3D

enum State { AVAILABLE, PICKING_UP, CARRIED, LOADING, LOADED }
var data: Dictionary
var state = State.AVAILABLE
var model: Node3D
var marker: MeshInstance3D
var cooldown = 0.0
var instance_id_in_run = ""
var trophy_id = ""
var rare_id = ""
var rarity_marker: RarityVisual
var loot_highlight: LootHighlight
var noise_generated_this_run = false
var feedback_tween: Tween
var strength_lock: Node3D

func setup(type_id: String, id: String, trophy: String = "") -> void:
	data = Balance.item(type_id)
	instance_id_in_run = id
	trophy_id = trophy
	model = Models.loot(data.visual_variant)
	add_child(model)
	marker = Models.cylinder(self, float(data.radius) + 0.13, 0.025, Vector3(0, 0.025, 0), Color("ffcf69"))
	Models.set_toon_profile(marker, ToonMaterial.Profile.MARKER)
	marker.visible = false
	strength_lock = Node3D.new()
	strength_lock.name = "StrengthLock"
	strength_lock.position.y = 2.25 if data.weight_class in ["HEAVY", "VERY_HEAVY"] else 1.55
	add_child(strength_lock)
	var icon = Sprite3D.new()
	icon.texture = HudStyle.ICONS.lock
	icon.pixel_size = 0.006
	icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	icon.no_depth_test = true
	strength_lock.add_child(icon)
	var requirement = Label3D.new()
	requirement.text = "STR %d" % int(data.required_strength)
	requirement.font_size = 32
	requirement.pixel_size = 0.008
	requirement.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	requirement.no_depth_test = true
	requirement.position.y = -0.43
	requirement.modulate = Color("ffcf69")
	strength_lock.add_child(requirement)
	strength_lock.hide()

func apply_rarity(choice: Dictionary) -> void:
	if choice.is_empty(): return
	rare_id = str(choice.id)
	data = data.duplicate(true)
	data.display_name = str(choice.name)
	data.cash_value = LootRarity.value(int(data.cash_value), choice)
	if LootRarity.visual_type(choice) != str(data.visual_variant):
		var old_transform := model.transform
		remove_child(model)
		model.free()
		model = Models.loot(LootRarity.visual_type(choice))
		add_child(model)
		model.transform = old_transform
	LootRarity.decorate_model(model, choice)
	rarity_marker = RarityVisual.new()
	add_child(rarity_marker)
	rarity_marker.setup(self, choice)

func set_strength_lock(level: int) -> void:
	if is_instance_valid(strength_lock):
		strength_lock.visible = state == State.AVAILABLE and int(data.required_strength) > level

func edge_distance(point: Vector3) -> float:
	return maxf(0.0, Vector2(point.x - global_position.x, point.z - global_position.z).length() - float(data.radius))

func highlight(enabled: bool) -> void:
	marker.visible = not is_instance_valid(loot_highlight) and enabled and not get_meta("suppress_highlight",false) and rare_id == "" and state in [State.AVAILABLE, State.PICKING_UP]
	if is_instance_valid(loot_highlight):
		loot_highlight.update_visual(0.0, enabled, state in [State.AVAILABLE, State.PICKING_UP], false)
	if not is_instance_valid(model): return
	if is_instance_valid(feedback_tween) and feedback_tween.is_valid(): feedback_tween.kill()
	model.scale = Vector3.ONE
	if marker.visible or (enabled and is_instance_valid(loot_highlight) and loot_highlight.visible):
		feedback_tween = create_tween()
		feedback_tween.tween_property(model, "scale", Vector3.ONE * 1.035, 0.09)
		feedback_tween.tween_property(model, "scale", Vector3.ONE, 0.12)

func pickup_pop() -> void:
	if not is_instance_valid(model): return
	if is_instance_valid(feedback_tween) and feedback_tween.is_valid(): feedback_tween.kill()
	var heavy: bool = data.weight_class in ["HEAVY", "VERY_HEAVY"]
	model.scale = Vector3.ONE * (1.035 if heavy else 1.075)
	feedback_tween = create_tween()
	feedback_tween.tween_property(model, "scale", Vector3.ONE, 0.16 if heavy else 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
