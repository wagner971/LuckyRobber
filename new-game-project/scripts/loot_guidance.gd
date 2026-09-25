class_name LootGuidance
extends Control

var ui: GameUI
var label_panel: PanelContainer
var name_label: Label
var detail_label: Label
var rarity_label: Label
var requirement: Label
var lock_icon: TextureRect
var selected: LootItem
var pointed = Vector2.ZERO
var show_pointer = false
var show_gesture = false
var clock = 0.0
var highlighted: LootItem
var styled_rarity := "uninitialized"

func setup(owner_ui: GameUI) -> void:
	ui = owner_ui
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_panel = ui.hud_plate(self, Color("2f0c48"), HudStyle.GREEN)
	label_panel.custom_minimum_size = Vector2(204, 0)
	var labels = ui.column(label_panel, 2)
	rarity_label = ui.text(labels, "", 16, HudStyle.CYAN)
	rarity_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	rarity_label.hide()
	name_label = ui.text(labels, "", 20)
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_label.add_theme_font_override("font", ui.heavy_font)
	detail_label = ui.text(labels, "", 18, HudStyle.GREEN)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var restriction = ui.row(labels, 6)
	lock_icon = HudStyle.icon(restriction, "lock", 24)
	requirement = ui.text(restriction, "", 16, HudStyle.GOLD)
	requirement.autowrap_mode = TextServer.AUTOWRAP_OFF
	requirement.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	HudStyle.pass_through(self)
	label_panel.hide()

func update(run: RunManager, delta: float) -> void:
	if run.phase == RunManager.Phase.PAUSED: return
	clock += delta
	selected = run.label_item()
	show_pointer = false
	show_gesture = run.onboarding != null and run.onboarding.step == Onboarding.Step.MOVE
	var guided = (run.onboarding.first_item if run.onboarding.step == Onboarding.Step.MOVE else run.onboarding.guide_item()) if run.onboarding != null else null
	if is_instance_valid(highlighted) and highlighted != guided:
		highlighted.marker.material_override.albedo_color = Color("ffcf69")
		highlighted.marker.scale = Vector3.ONE
		highlighted.highlight(false)
	highlighted = guided
	if guided != null:
		guided.marker.visible = true
		guided.marker.material_override.albedo_color = HudStyle.GREEN
		guided.marker.scale = Vector3.ONE * (1.05 + sin(clock * 5) * 0.08)
		if run.onboarding.step != Onboarding.Step.MOVE:
			pointed = run.level.camera.unproject_position(guided.global_position + Vector3.UP * 1.3)
			show_pointer = true
	if run.onboarding != null and run.onboarding.guides_van():
		run.level.van.zone.material_override.albedo_color = HudStyle.GREEN.lerp(Color("baffde"), (sin(clock * 5) + 1) * 0.35)
		run.level.van.zone.scale = Vector3.ONE * (1.0 + sin(clock * 5) * 0.08)
		pointed = run.level.camera.unproject_position(run.level.van.load_position + Vector3.UP * 0.8)
		show_pointer = true
	label_panel.visible = selected != null
	if selected != null:
		var rare_choice := LootRarity.variant(selected.rare_id)
		var rare: bool = not rare_choice.is_empty()
		var accent: Color = rare_choice.color if rare else HudStyle.GREEN
		rarity_label.visible = rare
		rarity_label.text = str(rare_choice.get("tier", "")) + " LOOT" if rare else ""
		rarity_label.add_theme_color_override("font_color", accent)
		detail_label.add_theme_color_override("font_color", accent)
		if styled_rarity != selected.rare_id:
			label_panel.add_theme_stylebox_override("panel", HudStyle.plate(Color("2f0c48"), accent, 16))
			styled_rarity = selected.rare_id
		name_label.text = "TV" if run.onboarding != null and selected == run.onboarding.first_item else selected.data.display_name
		# Explicit line breaks avoid a hidden auto-sized panel measuring a one-pixel
		# wrapped label, then hiding itself permanently because it appears too tall.
		if rare: name_label.text = wrap_loot_name(name_label.text, minf(280.0, size.x - 84.0))
		detail_label.text = "$%d  ·  %d CARGO" % [selected.data.cash_value, selected.data.cargo_space]
		var reason = run.block_reason(selected)
		requirement.text = reason
		requirement.visible = not reason.is_empty()
		lock_icon.visible = reason.begins_with("STRENGTH")
		requirement.get_parent().visible = not reason.is_empty()
		label_panel.size = Vector2(204, 0)
		var anchor = run.level.camera.unproject_position(selected.global_position + Vector3.UP * 0.8)
		var player = run.level.camera.unproject_position(run.level.player.global_position + Vector3.UP * 0.7)
		var safe_top = maxf(ui.hud_top.get_global_rect().end.y, ui.instruction_panel.get_global_rect().end.y) + 8
		var safe_bottom = ui.hud_bottom.get_global_rect().position.y - 12
		var bounds = Rect2(18, safe_top, size.x - 36, safe_bottom - safe_top)
		var player_rect = Rect2(player - Vector2(30, 55), Vector2(60, 100))
		var panel_size = label_panel.get_combined_minimum_size()
		for candidate in [anchor + Vector2(30, -panel_size.y - 16), anchor + Vector2(-panel_size.x - 30, -panel_size.y - 16), anchor + Vector2(-panel_size.x / 2, -panel_size.y - 80), anchor + Vector2(30, 25)]:
			var at = Vector2(clampf(candidate.x, bounds.position.x, bounds.end.x - panel_size.x), clampf(candidate.y, bounds.position.y, bounds.end.y - panel_size.y))
			var rect = Rect2(at, panel_size)
			if not rect.intersects(player_rect) and (not ui.toast_panel.visible or not rect.intersects(ui.toast_panel.get_global_rect())):
				label_panel.show()
				label_panel.position = at
				break
			label_panel.hide()
	queue_redraw()

func wrap_loot_name(value: String, width: float) -> String:
	var lines := PackedStringArray()
	var line := ""
	var font := name_label.get_theme_font("font")
	var font_size := name_label.get_theme_font_size("font_size")
	for word in value.split(" "):
		var candidate := word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
			lines.append(line)
			line = word
		else: line = candidate
	if not line.is_empty(): lines.append(line)
	return "\n".join(lines)

func _draw() -> void:
	if show_pointer:
		var tip = pointed + Vector2(0, sin(clock * 4) * 5 - 10)
		draw_line(tip - Vector2(0, 40), tip, Color("1e062f"), 12, true)
		draw_line(tip - Vector2(0, 40), tip, HudStyle.GREEN, 7, true)
		draw_polyline(PackedVector2Array([tip + Vector2(-11,-12), tip, tip + Vector2(11,-12)]), HudStyle.GREEN, 7, true)
	if show_gesture:
		var center = Vector2(size.x * 0.78, size.y - 325)
		draw_circle(center, 42, Color("4b1570b3"))
		draw_arc(center, 42, 0, TAU, 48, HudStyle.CYAN, 2, true)
		var hand = center + Vector2(sin(clock * 2) * 27, cos(clock * 2) * 8)
		draw_texture_rect(HudStyle.ICONS.hand, Rect2(hand - Vector2(22,22), Vector2(44,44)), false)
