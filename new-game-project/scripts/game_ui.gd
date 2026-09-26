class_name GameUI
extends CanvasLayer

signal start_requested(location: String, mode: String)
signal cosmetic_requested(id: String, operation: String)
signal buy_requested(key: String)
signal action_requested(action: String)
signal cash_reward_collected
signal wheel_reward_revealed(prize: Dictionary)
const INK = Color("2a1538")
const MINT = Color("91e4c3")
const PAPER = Color("f5efdf")
const MUTED = Color("afa0b9")
const PAGE_GUTTER := 18
const PAGE_SPACING := 9
var root: Control
var motion: ScreenMotion
var page_motion_requested := false
var input: MoveInput
var hud: Control
var menu: Control
var modal: Control
var trophy_modal: Control
var gift_reveal: GiftReveal
var timer: Label
var timer_caption: Label
var alarm_countdown_bar: ProgressBar
var alarm_countdown_total := 0.0
var van_value: Label
var space: Label
var session_info: Label
var session_panel: PanelContainer
var diamond_hud: Label
var diamond_hud_icon: TextureRect
var diamond_hud_chip: PanelContainer
var target: Label
var tutorial: Label
var toast: Label
var meter: ProgressBar
var drop_button: Button
var escape_button: Button
var pause_button: Button
var cargo_bar: ProgressBar
var time_panel: PanelContainer
var loot_panel: PanelContainer
var noise_icon: TextureRect
var interaction_icon: TextureRect
var interaction_caption: Label
var instruction_panel: PanelContainer
var toast_panel: PanelContainer
var alarm_vignette: ColorRect
var scene_polish: ColorRect
var world_color_grade: ColorRect
var hud_top: MarginContainer
var hud_bottom: MarginContainer
var menu_outer: MarginContainer
var menu_background: ColorRect
var safe_insets := Vector4.ZERO # Left, top, right, bottom in canvas units.
var safe_area_override_enabled := false
var safe_area_override := Vector4.ZERO
var noise_fill: StyleBoxFlat
var last_urgent = false
var noise_panel: PanelContainer
var cargo_panel: PanelContainer
var loot_caption: Label
var loot_lock: TextureRect
var guidance: LootGuidance
var cash_effect: CashBurst3D
var cash_text_tween: Tween
var cash_text_paused := false
var cash_amount: Label
var cash_amount_panel: PanelContainer
var toast_time = 0.0
var loot_pulse: Tween
var cash_count_elapsed := 1.0
var cash_count_from := 0
var cash_count_to := 0
var noise_bar: ProgressBar
var noise_status: Label
var noise_gain = ""
var noise_gain_time = 0.0
var development_mode = false
var menu_previews_active = true
var cosmetics_list: VBoxContainer
var locker_tab := "skins"
var locker_scroll: ScrollContainer
var locker_grid_anchor: Control
var lucky_shop_list: VBoxContainer
const LUCKY_CUBE := preload("res://assets/ui/reward_cards/purple-lucky-cube.png")
var garage_selected := ""
var garage_live_preview: MenuCharacterPreview
var garage_buy: Button
var garage_title: Label
var garage_description: Label
var garage_wallet: Label
var cosmetic_status: Label
var cosmetic_wallet: Label
var cosmetic_gems_label: Label
var selected_vehicle := "vehicle_black"
var vehicle_wallet: Label
var vehicle_status: Label
var vehicle_buy: Button
var heavy_font: FontVariation
var display_font: Font # Bungee: titles, numbers, PLAY.
var body_font: Font # Lilita One: labels and copy.
var menu_wallet_label: Label
var menu_diamond_label: Label
var home_gift_button: Button
var upgrade_cards: Dictionary = {}
var shop_selected_key := "strength"
var shop_preview: MenuCharacterPreview
var shop_scroll: ScrollContainer
var last_noise_value := 0.0
var last_warning_visual := false
var last_full_visual := false
var last_timer_second := 11
var result_overlay: Control
var jobs_index := -1
var jobs_swipe_start := Vector2.ZERO
var jobs_swipe_time := 0.0
var jobs_current_card: PanelContainer
var jobs_transition: Tween
var jobs_wallet_tween: Tween
var jobs_last_wallet := -1
var duplication_selected_type := ""
var wheel_disc: DailyWheelView
var wheel_result: Label
var wheel_balance: Label
var wheel_spin_button: Button
var wheel_reset: Label
var wheel_tickets: Label
var wheel_busy := false
const SHOP_TITLES = {"strength":"STRENGTH", "grip":"PICKUP SPEED", "carry":"CARRY SPEED", "capacity":"VAN SPACE", "noise":"NOISE CONTROL"}
const SHOP_DESCRIPTIONS = {"strength":"UNLOCKS NEXT", "grip":"Pick up faster", "carry":"Walk and carry faster", "capacity":"Fit more in the van", "noise":"Make less noise"}
const SHOP_COLORS = {"strength":HudStyle.INFO, "grip":HudStyle.INFO, "carry":HudStyle.INFO, "capacity":HudStyle.INFO, "noise":HudStyle.INFO}
const SHOP_BLURBS = {"strength":"Lift heavier objects", "grip":"Pick up items faster", "carry":"Move faster while carrying", "capacity":"Carry more items in the van", "noise":"Make less noise"}
const SHOP_TILES = {"strength":Color("f08a16"), "grip":Color("2f8cff"), "carry":Color("2bd25c"), "capacity":Color("ef3d4a"), "noise":Color("8e3cff")}
const SHOP_ACCENTS = {"strength":Color("ffc033"), "grip":Color("5fb2ff"), "carry":Color("5ff08a"), "capacity":Color("ff6d78"), "noise":Color("c48bff")}
const SHOP_ICONS = {"strength":"strength", "grip":"grip", "carry":"carry", "capacity":"capacity", "noise":"noise"}
# Up to three most valuable objects a Strength level unlocks; every level unlocks something.
static func strength_featured(level: int) -> Array:
	var ids: Array = []
	for id in Balance.ITEMS:
		if int(Balance.ITEMS[id].required_strength) == level: ids.append(id)
	ids.sort_custom(func(a, b): return int(Balance.ITEMS[a].cash_value) > int(Balance.ITEMS[b].cash_value))
	return ids.slice(0, 3)
const JOB_ACCENTS = {
	"apartment": Color("58e6ce"), "house": Color("8be982"),
	"villa": Color("ffca76"), "electronics": Color("c168ff"),
	"mansion": Color("ffc75b"), "laboratory": Color("bb82e2"), "museum": Color("cf9cff"),
	"pyramid": Color("eeb65b"), "castle": Color("e88c9f"), "pirate_ship": Color("a757de"), "vikings": Color("d0a4ee"), "english_pub": Color("e6c28a"), "prehistoric": Color("abc974")
}
const JOB_HERO_SHADER = preload("res://assets/shaders/jobs_hero.gdshader")
const JOB_COVER_SHADER = preload("res://assets/shaders/jobs_cover.gdshader")
const JOB_BLUEPRINT_SHADER = preload("res://assets/shaders/jobs_blueprint.gdshader")
const ALARM_VIGNETTE_SHADER = preload("res://assets/shaders/alarm_vignette.gdshader")
const SCENE_POLISH_SHADER = preload("res://assets/shaders/scene_polish.gdshader")
const JOB_PREVIEWS = {
	"apartment": "res://assets/ui/jobs/apartment.png",
	"house": "res://assets/ui/jobs/house.png",
	"villa": "res://assets/ui/jobs/villa.png",
	"electronics": "res://assets/ui/jobs/electronics.png",
	"mansion": "res://assets/ui/jobs/mansion.png",
	"laboratory": "res://assets/ui/jobs/laboratory.png",
	"museum": "res://assets/ui/jobs/museum.png",
	"pyramid": "res://assets/ui/jobs/pyramid.png",
	"castle": "res://assets/ui/jobs/castle.png",
	"pirate_ship": "res://assets/ui/jobs/pirate_ship.png",
	"vikings": "res://assets/ui/jobs/vikings.png",
	"english_pub": "res://assets/ui/jobs/english_pub.png",
	"prehistoric": "res://assets/ui/jobs/prehistoric.png"
}

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.resized.connect(refresh_safe_area)
	var theme = Theme.new()
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", PAPER)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_disabled_color", "Button", Color("847291"))
	theme.set_stylebox("normal", "Button", panel(MINT, 16))
	theme.set_stylebox("hover", "Button", panel(Color("bcf4dc"), 16))
	theme.set_stylebox("pressed", "Button", panel(Color("64bb9d"), 16))
	theme.set_stylebox("disabled", "Button", panel(Color("3e2b4c"), 16))
	theme.set_stylebox("focus", "Button", panel(Color.TRANSPARENT, 16))
	root.theme = theme
	input = MoveInput.new()
	root.add_child(input)
	heavy_font = FontVariation.new()
	heavy_font.base_font = ThemeDB.fallback_font
	heavy_font.variation_embolden = 1.15
	display_font = load("res://assets/fonts/Bungee-Regular.ttf") if ResourceLoader.exists("res://assets/fonts/Bungee-Regular.ttf") else heavy_font
	body_font = load("res://assets/fonts/LilitaOne-Regular.ttf") if ResourceLoader.exists("res://assets/fonts/LilitaOne-Regular.ttf") else heavy_font
	build_hud()
	motion = ScreenMotion.new()
	add_child(motion)
	refresh_safe_area()

func set_safe_area_override(insets: Vector4) -> void:
	# Also lets the layout be checked in the editor on a desktop display.
	safe_area_override_enabled = true
	safe_area_override = insets
	refresh_safe_area()

func refresh_safe_area() -> void:
	if not is_instance_valid(root): return
	if safe_area_override_enabled:
		safe_insets = safe_area_override
	elif OS.has_feature("Android") or OS.has_feature("iOS"):
		var screen_size := Vector2(DisplayServer.screen_get_size())
		var safe_rect := DisplayServer.get_display_safe_area()
		if screen_size.x > 0.0 and screen_size.y > 0.0 and safe_rect.size.x > 0 and safe_rect.size.y > 0:
			var scale := root.size / screen_size
			safe_insets = Vector4(
				maxf(0.0, safe_rect.position.x) * scale.x,
				maxf(0.0, safe_rect.position.y) * scale.y,
				maxf(0.0, screen_size.x - safe_rect.end.x) * scale.x,
				maxf(0.0, screen_size.y - safe_rect.end.y) * scale.y
			)
		else:
			safe_insets = Vector4.ZERO
	else:
		safe_insets = Vector4.ZERO
	if is_instance_valid(menu_outer): apply_page_margins(menu_outer)
	if is_instance_valid(hud_top): apply_page_margins(hud_top)
	if is_instance_valid(hud_bottom):
		apply_page_margins(hud_bottom)
		hud_bottom.offset_top = -150.0 - safe_insets.w
	if is_instance_valid(instruction_panel): position_instruction()

func apply_page_margins(container: MarginContainer) -> void:
	container.add_theme_constant_override("margin_left", PAGE_GUTTER + roundi(safe_insets.x))
	container.add_theme_constant_override("margin_top", PAGE_GUTTER + roundi(safe_insets.y))
	container.add_theme_constant_override("margin_right", PAGE_GUTTER + roundi(safe_insets.z))
	container.add_theme_constant_override("margin_bottom", PAGE_GUTTER + roundi(safe_insets.w))

func panel(color: Color, radius: int = 18) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

func noise_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style

func text(parent: Node, value: String, size: int = 22, color: Color = PAPER) -> Label:
	var label = Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func button(parent: Node, value: String, callable: Callable, height: int = 64) -> Button:
	var b = Button.new()
	b.text = value
	b.custom_minimum_size.y = height
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(callable)
	UiJuice.button_touch(b)
	parent.add_child(b)
	return b

func margin(parent: Node, edges: int = 24) -> MarginContainer:
	var m = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]: m.add_theme_constant_override("margin_" + side, edges)
	parent.add_child(m)
	return m

func column(parent: Node, separation: int = 12) -> VBoxContainer:
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	parent.add_child(v)
	return v

func row(parent: Node, separation: int = 12) -> HBoxContainer:
	var r = HBoxContainer.new()
	r.add_theme_constant_override("separation", separation)
	parent.add_child(r)
	return r

func card(parent: Node, color: Color = Color("420a69")) -> VBoxContainer:
	var p = PanelContainer.new()
	var style = menu_style(color,Color("622c87")) if is_instance_valid(menu) else panel(color)
	style.set_border_width_all(1)
	style.shadow_size = 3
	p.add_theme_stylebox_override("panel", style)
	parent.add_child(p)
	return column(p, 8)

func hud_plate(parent: Node, color: Color = HudStyle.BLUE, edge: Color = HudStyle.EDGE) -> PanelContainer:
	var plate = PanelContainer.new()
	plate.add_theme_stylebox_override("panel", HudStyle.plate(color, edge))
	parent.add_child(plate)
	return plate

func hud_bar(parent: Node, color: Color, height: float = 10) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.custom_minimum_size.y = height
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", HudStyle.track(Color("220735")))
	bar.add_theme_stylebox_override("fill", HudStyle.track(color))
	parent.add_child(bar)
	return bar

func build_hud() -> void:
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(hud)
	world_color_grade = ColorRect.new()
	world_color_grade.name = "VividWorldColor"
	world_color_grade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	world_color_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var color_material := ShaderMaterial.new()
	color_material.shader = preload("res://assets/shaders/vivid_world.gdshader")
	world_color_grade.material = color_material
	hud.add_child(world_color_grade)
	scene_polish = ColorRect.new()
	scene_polish.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_polish.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var polish_material = ShaderMaterial.new()
	polish_material.shader = SCENE_POLISH_SHADER
	scene_polish.material = polish_material
	hud.add_child(scene_polish)
	alarm_vignette = ColorRect.new()
	alarm_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	alarm_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var alarm_material = ShaderMaterial.new()
	alarm_material.shader = ALARM_VIGNETTE_SHADER
	alarm_vignette.material = alarm_material
	hud.add_child(alarm_vignette)
	alarm_vignette.hide()
	hud_top = margin(hud, PAGE_GUTTER)
	hud_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	var top_col = column(hud_top, 10)
	var primary = row(top_col, 10)
	time_panel = hud_plate(primary, Color("5e0a98"), HudStyle.INFO.darkened(0.42))
	time_panel.custom_minimum_size.x = 224
	var time_row = row(time_panel, 8)
	HudStyle.icon(time_row, "clock", 64)
	var time_col = column(time_row, 0)
	time_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_caption = text(time_col, "TIME LEFT", 15, HudStyle.INFO)
	timer = headline(time_col, "60.0", 42)
	timer.autowrap_mode = TextServer.AUTOWRAP_OFF
	alarm_countdown_bar = hud_bar(time_col, Color("ffbd66"), 5)
	alarm_countdown_bar.hide()
	var loot_plate = hud_plate(primary)
	loot_panel = loot_plate
	loot_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var loot_row = row(loot_plate, 8)
	HudStyle.icon(loot_row, "cash", 60)
	var loot_col = column(loot_row, 0)
	loot_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(loot_col, "VAN LOOT", 15, HudStyle.CYAN)
	van_value = headline(loot_col, "$0", 34, HudStyle.MONEY)
	van_value.autowrap_mode = TextServer.AUTOWRAP_OFF
	var keep_row = row(loot_col, 4)
	loot_lock = HudStyle.icon(keep_row, "lock", 18)
	loot_lock.hide()
	loot_caption = text(keep_row, "ESCAPE TO BANK", 14, Color("cba3e7"))
	loot_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_button = button(primary, "", func(): action_requested.emit("pause"), 86)
	pause_button.custom_minimum_size.x = 80
	pause_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	pause_button.tooltip_text = "Pause"
	HudStyle.action(pause_button, "pause", Color("692399"), HudStyle.EDGE, heavy_font)
	var secondary = row(top_col, 10)
	var cargo_plate = hud_plate(secondary, Color("450a6e"), Color("8628c7"))
	cargo_panel = cargo_plate
	cargo_plate.custom_minimum_size.x = 224
	var cargo_row = row(cargo_plate, 10)
	HudStyle.icon(cargo_row, "box", 44)
	var cargo_col = column(cargo_row, 2)
	cargo_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(cargo_col, "VAN SPACE", 13, Color("cba3e7"))
	space = text(cargo_col, "0 / 8", 21)
	space.add_theme_font_override("font", heavy_font)
	cargo_bar = hud_bar(cargo_col, HudStyle.INFO, 7)
	var noise_plate = hud_plate(secondary, Color("450a6e"), Color("8628c7"))
	noise_panel = noise_plate
	noise_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var noise_row = row(noise_plate, 10)
	noise_icon = HudStyle.icon(noise_row, "noise", 42)
	var noise_col = column(noise_row, 6)
	noise_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	noise_status = text(noise_col, "NOISE · SAFE", 16, HudStyle.GREEN)
	noise_status.add_theme_font_override("font", heavy_font)
	noise_bar = hud_bar(noise_col, HudStyle.GREEN)
	noise_fill = noise_bar.get_theme_stylebox("fill")
	session_panel = PanelContainer.new()
	var session_style = HudStyle.plate(Color("2b0b41e8"), Color("612888"), 10)
	session_style.set_content_margin_all(4)
	session_style.set_border_width_all(1)
	session_style.shadow_size = 0
	session_panel.add_theme_stylebox_override("panel", session_style)
	top_col.add_child(session_panel)
	var session_line = row(session_panel, 6)
	session_info = text(session_line, "NORMAL", 16, HudStyle.CYAN)
	session_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	session_info.clip_text = true
	session_info.autowrap_mode = TextServer.AUTOWRAP_OFF
	session_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	session_info.add_theme_color_override("font_shadow_color", Color("190626"))
	session_info.add_theme_constant_override("shadow_offset_y", 2)
	diamond_hud_chip = PanelContainer.new()
	diamond_hud_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var gem_style = HudStyle.plate(Color("450a6e"), HudStyle.INFO.darkened(0.30), 11)
	gem_style.set_content_margin_all(3)
	gem_style.set_border_width_all(1)
	gem_style.shadow_size = 0
	diamond_hud_chip.add_theme_stylebox_override("panel", gem_style)
	loot_row.add_child(diamond_hud_chip)
	var gem_row = row(diamond_hud_chip, 3)
	diamond_hud_icon = TextureRect.new()
	diamond_hud_icon.texture = preload("res://assets/ui/diamond.png")
	diamond_hud_icon.custom_minimum_size = Vector2(36, 36)
	diamond_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	diamond_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gem_row.add_child(diamond_hud_icon)
	diamond_hud = headline(gem_row, "0", 25, HudStyle.INFO)
	diamond_hud.autowrap_mode = TextServer.AUTOWRAP_OFF

	toast_panel = hud_plate(hud, Color("2f0c48"), Color("7d38ad"))
	toast_panel.anchor_left = 0.0
	toast_panel.anchor_right = 1.0
	toast_panel.anchor_top = 0.5
	toast_panel.anchor_bottom = 0.5
	toast_panel.offset_top = -35
	toast_panel.offset_bottom = 35
	toast_panel.offset_left = 38
	toast_panel.offset_right = -38
	toast = headline(toast_panel, "", 24, HudStyle.GREEN, true)
	toast_panel.hide()
	instruction_panel = hud_plate(hud, Color("620b9e"), HudStyle.EDGE)
	var instruction_style = HudStyle.plate(Color("620b9e"), HudStyle.EDGE, 14)
	instruction_style.content_margin_left = 10
	instruction_style.content_margin_right = 10
	instruction_style.content_margin_top = 6
	instruction_style.content_margin_bottom = 6
	instruction_style.border_width_bottom = 3
	instruction_panel.add_theme_stylebox_override("panel", instruction_style)
	var interaction_row = row(instruction_panel, 8)
	interaction_icon = HudStyle.icon(interaction_row, "hand", 36)
	var interaction_col = column(interaction_row, 1)
	tutorial = text(interaction_col, "", 12, HudStyle.CYAN)
	tutorial.autowrap_mode = TextServer.AUTOWRAP_OFF
	tutorial.hide()
	interaction_caption = text(interaction_col, "GRAB & GO", 11, HudStyle.INFO)
	interaction_caption.add_theme_font_override("font", heavy_font)
	interaction_caption.autowrap_mode = TextServer.AUTOWRAP_OFF
	target = text(interaction_col, "STOP NEAR AN OBJECT", 18)
	target.add_theme_font_override("font", heavy_font)
	target.autowrap_mode = TextServer.AUTOWRAP_OFF
	meter = hud_bar(interaction_col, HudStyle.GREEN, 5)
	meter.hide()
	instruction_panel.resized.connect(position_instruction)
	hud_top.resized.connect(position_instruction)
	hud.resized.connect(position_instruction)
	position_instruction()
	hud_bottom = margin(hud, PAGE_GUTTER)
	hud_bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hud_bottom.offset_top = -150
	var bottom_col = column(hud_bottom, 8)
	bottom_col.alignment = BoxContainer.ALIGNMENT_END
	var actions = row(bottom_col, 12)
	drop_button = button(actions, "DROP", func(): action_requested.emit("drop"), 80)
	HudStyle.action(drop_button, "drop", Color("692399"), HudStyle.INFO, heavy_font)
	escape_button = button(actions, "ESCAPE →", func(): action_requested.emit("escape"), 80)
	HudStyle.action(escape_button, "escape", Color("14be86"), Color("66ffbe"), heavy_font)
	HudStyle.pass_through(hud)
	guidance = LootGuidance.new()
	hud.add_child(guidance)
	guidance.setup(self)
	cash_amount_panel = PanelContainer.new()
	hud.add_child(cash_amount_panel)
	cash_amount_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var money_style = StyleBoxFlat.new()
	money_style.bg_color = Color("190924f2")
	money_style.border_color = Color("3af4a6")
	money_style.set_border_width_all(2)
	money_style.set_corner_radius_all(12)
	money_style.content_margin_left = 12
	money_style.content_margin_right = 12
	money_style.content_margin_top = 5
	money_style.content_margin_bottom = 5
	money_style.shadow_color = Color("000000a8")
	money_style.shadow_size = 4
	cash_amount_panel.add_theme_stylebox_override("panel", money_style)
	cash_amount = headline(cash_amount_panel, "", 27, HudStyle.GREEN, true)
	cash_amount.autowrap_mode = TextServer.AUTOWRAP_OFF
	cash_amount.add_theme_font_override("font", heavy_font)
	cash_amount.add_theme_color_override("font_outline_color", Color.BLACK)
	cash_amount.add_theme_constant_override("outline_size", 6)
	cash_amount_panel.hide()
	hud.hide()

func position_instruction() -> void:
	if not is_instance_valid(instruction_panel) or not is_instance_valid(hud_top): return
	var compact_size = instruction_panel.get_combined_minimum_size()
	if instruction_panel.size != compact_size: instruction_panel.size = compact_size
	instruction_panel.position = Vector2(clampf((hud.size.x - instruction_panel.size.x) * 0.5, PAGE_GUTTER + safe_insets.x, hud.size.x - PAGE_GUTTER - safe_insets.z - instruction_panel.size.x), hud_top.position.y + hud_top.size.y + 5)

func position_cash_amount(run: RunManager) -> void:
	if not is_instance_valid(cash_amount_panel): return
	var source: Vector3 = run.level.van.money_burst_origin.global_position
	var projected: Vector2 = run.level.camera.unproject_position(source)
	cash_amount_panel.position = Vector2(clampf(projected.x - cash_amount_panel.size.x * 0.5, PAGE_GUTTER + safe_insets.x, hud.size.x - cash_amount_panel.size.x - PAGE_GUTTER - safe_insets.z), clampf(projected.y - 74, maxf(160, safe_insets.y + PAGE_GUTTER), hud.size.y - 90 - safe_insets.w))

func show_run() -> void:
	clear_menu()
	hud.visible = true
	input.enabled = true
	input.reset()
	toast.text = ""
	toast_panel.hide()
	toast_time = 0
	noise_gain = ""
	noise_gain_time = 0
	clear_cash_burst()
	noise_bar.value = 0
	last_noise_value = 0
	last_warning_visual = false
	last_full_visual = false
	alarm_vignette.hide()
	alarm_countdown_total = 0.0
	alarm_countdown_bar.hide()
	last_timer_second = 11

func set_scene_polish(location: String, enabled: bool) -> void:
	scene_polish.visible = enabled
	if not enabled: return
	var material := scene_polish.material as ShaderMaterial
	var cool := location in ["laboratory", "electronics", "castle", "pirate_ship", "vikings"]
	material.set_shader_parameter("beam_color", Color("b373df") if cool else Color("ffd291"))
	material.set_shader_parameter("beam_origin", Vector2(0.82, -0.10) if cool else Vector2(0.12, -0.10))
	material.set_shader_parameter("beam_slope", -0.34 if cool else 0.34)
	material.set_shader_parameter("beam_strength", 0.08 if cool else 0.10)

func update_run(run: RunManager, delta: float) -> void:
	timer.text = "%ds" % ceili(run.remaining) if run.alarm_active else "%04.1f" % run.remaining
	timer_caption.text = "POLICE IN" if run.alarm_active else "TIME LEFT"
	alarm_countdown_bar.visible = run.alarm_active
	if run.alarm_active:
		if alarm_countdown_total <= 0.0: alarm_countdown_total = maxf(1.0, run.remaining)
		alarm_countdown_bar.value = 100.0 * run.remaining / alarm_countdown_total
	else:
		alarm_countdown_total = 0.0
	var second := ceili(run.remaining)
	if second < last_timer_second and second in [1, 2, 3, 4, 5] and run.phase == RunManager.Phase.ACTIVE:
		UiJuice.pulse(timer, 1.045 if second == 1 else 1.025, 0.17)
	last_timer_second = second
	var urgent = run.onboarding == null and (run.remaining <= 10 or run.alarm_active)
	timer.add_theme_color_override("font_color", Color("fff3df") if urgent else PAPER)
	if urgent != last_urgent:
		time_panel.add_theme_stylebox_override("panel", HudStyle.plate(Color("382446"), HudStyle.FINAL) if urgent else HudStyle.plate(Color("5e0a98"), HudStyle.INFO.darkened(0.42)))
		last_urgent = urgent
	var noise_ratio = run.current_noise / maxf(0.01, run.alarm_threshold)
	var noise_color = HudStyle.FINAL if run.alarm_active else (HudStyle.FINAL if noise_ratio >= Balance.ALARM_WARNING_FACTOR else HudStyle.GREEN)
	var noise_goal := minf(100, noise_ratio * 100)
	noise_bar.value = noise_goal if delta <= 0 else lerpf(noise_bar.value, noise_goal, clampf(delta / 0.16, 0, 1))
	if run.current_noise > last_noise_value + 0.01:
		UiJuice.pulse(noise_panel, 1.025, 0.15)
	last_noise_value = run.current_noise
	var warning := noise_ratio >= Balance.ALARM_WARNING_FACTOR and not run.alarm_active
	if warning and not last_warning_visual: UiJuice.flash(noise_panel, Color("ffeab6"), 0.24)
	last_warning_visual = warning
	# Warning is confined to the noise HUD; the active alarm adds static corners.
	alarm_vignette.visible = run.alarm_active and run.phase == RunManager.Phase.ACTIVE
	var alarm_material := alarm_vignette.material as ShaderMaterial
	alarm_material.set_shader_parameter("intensity", 1.0 if alarm_vignette.visible else 0.0)
	alarm_material.set_shader_parameter("canvas_size", root.size)
	noise_fill.bg_color = noise_color
	noise_icon.texture = HudStyle.ICONS["warning" if noise_ratio >= Balance.ALARM_WARNING_FACTOR or run.alarm_active else "noise"]
	noise_status.text = "ALARM · RETURN TO VAN" if run.alarm_active else ("ALARM CLOSE" if warning else "NOISE · SAFE")
	if noise_gain_time > 0 and not run.alarm_active:
		noise_gain_time -= delta
		noise_status.text += " · " + noise_gain
	noise_status.add_theme_color_override("font_color", noise_color)
	if cash_count_elapsed < 1.0 and run.phase != RunManager.Phase.PAUSED:
		cash_count_elapsed = minf(1.0, cash_count_elapsed + delta / 0.30)
	var displayed_value: int = roundi(lerpf(float(cash_count_from), float(cash_count_to), cash_count_elapsed)) if cash_count_elapsed < 1.0 else run.cargo_value
	van_value.text = "$%d" % displayed_value
	space.text = "FULL  %d / %d" % [run.cargo_used, run.capacity()] if run.cargo_used == run.capacity() else "%d / %d" % [run.cargo_used, run.capacity()]
	space.add_theme_color_override("font_color", HudStyle.FINAL if run.cargo_used == run.capacity() else PAPER)
	cargo_bar.value = 100.0 * run.cargo_used / maxi(1, run.capacity())
	if run.lucky.id == "bottomless":
		space.text = "%d / ∞" % run.cargo_used
		cargo_bar.value = 100.0 * run.cargo_used / maxi(1,int(Balance.LOCATIONS[run.location_id].expected_cargo))
	target.text = run.nearby_text if run.nearby_text != "" else "STOP NEAR AN OBJECT"
	meter.value = run.progress / maxf(0.01, run.progress_duration) * 100
	meter.visible = run.progress > 0
	var carrying = is_instance_valid(run.carried)
	if carrying and not run.nearby_text.begins_with("LOADING"):
		target.text = run.carried.data.display_name
	interaction_icon.texture = HudStyle.ICONS["strength" if carrying else "hand"]
	interaction_caption.text = "CARRYING LOOT" if carrying else "AUTO PICKUP"
	if run.nearby_text.begins_with("LOADING"):
		interaction_icon.texture = HudStyle.ICONS["box"]
		interaction_caption.text = "STAY HERE TO LOAD"
	elif run.progress > 0:
		interaction_caption.text = "PICKING UP"
	elif run.can_escape():
		interaction_icon.texture = HudStyle.ICONS["escape"]
		interaction_caption.text = "ESCAPE WITH YOUR LOOT"
		target.text = "TAP ESCAPE"
	elif run.phase == RunManager.Phase.READY:
		interaction_caption.text = "READY WHEN YOU ARE"
	elif run.nearby_text.contains("REQUIRED") or run.nearby_text.contains("NOT ENOUGH"):
		interaction_icon.texture = HudStyle.ICONS["warning"]
		interaction_caption.text = "CAN'T PICK UP"
	tutorial.text = ""
	session_info.text = "NORMAL · " + Balance.LOCATIONS[run.location_id].name if run.mode == "normal" else run.contract_progress()
	session_info.add_theme_color_override("font_color", HudStyle.INFO)
	if is_instance_valid(run.level.security) and run.phase == RunManager.Phase.READY:
		session_info.text = "SECURITY · AVOID THE VISION CONES"
	if run.mode == SpecialJobs.MODE:
		var special = SpecialJobs.definition(run.rules.special_type)
		session_info.text = "SPECIAL JOB · %s · +%d%% CASH" % [special.display_name, roundi((special.cash_multiplier - 1) * 100)]
		session_info.add_theme_color_override("font_color", HudStyle.SPECIAL)
	elif run.mode == "FINAL_JOB":
		session_info.text = "FINAL JOB · " + Balance.LOCATIONS[run.location_id].name
		session_info.add_theme_color_override("font_color", HudStyle.FINAL)
	diamond_hud.text = str(run.store.data.diamonds)
	if run.lucky.id != "":
		session_info.text = ("LUCKY · " if LuckyEffects.positive(run.lucky.id) else "CURSED · ")+LuckyEffects.CATALOG[run.lucky.id][0]
		session_info.add_theme_color_override("font_color",MINT if LuckyEffects.positive(run.lucky.id) else HudStyle.SPECIAL)
	diamond_hud_chip.visible = run.onboarding == null
	drop_button.visible = run.carried != null
	escape_button.visible = run.can_escape()
	escape_button.text = "! ESCAPE NOW" if run.alarm_active else "ESCAPE WITH LOOT"
	if run.alarm_active:
		interaction_caption.text = "ALARM"
		target.text = "TAP ESCAPE" if run.can_escape() else "GET TO THE VAN"
	elif run.van_is_full():
		interaction_icon.texture = HudStyle.ICONS["warning"]
		interaction_caption.text = "VAN FULL"
		target.text = "ESCAPE!" if run.can_escape() else "RETURN TO THE VAN · ESCAPE!"
	var full := run.van_is_full()
	if full and not last_full_visual: UiJuice.flash(cargo_panel, HudStyle.FINAL, 0.3)
	last_full_visual = full
	escape_button.modulate = Color.WHITE.lerp(HudStyle.PLAY, 0.24 + 0.18 * sin(run.elapsed * 6.0)) if full and escape_button.visible else Color.WHITE
	instruction_panel.visible = not run.can_escape()
	if urgent or full:
		run.level.van.zone.material_override.albedo_color = Color("ffcf57").lerp(MINT, (sin(run.elapsed * 6) + 1) * 0.5)
		run.level.van.zone.scale = Vector3.ONE * (1.0 + 0.06 * (0.5 + 0.5 * sin(run.elapsed * 6)))
	else:
		run.level.van.zone.material_override.albedo_color = Color("61c6ac")
		run.level.van.zone.scale = Vector3.ONE
	if toast_time > 0:
		toast_time -= delta
		if toast_time <= 0: toast.text = ""
	toast_panel.visible = toast_time > 0
	guidance.update(run, delta)
	update_onboarding_hud(run, delta)
	if is_instance_valid(run.level.security) and run.level.security.cooldown > SecurityPatrol.COOLDOWN - 1.5 and not run.alarm_active and not full and not run.can_escape():
		interaction_caption.text = "SPOTTED"
		target.text = "-2s · KEEP MOVING!"
		interaction_icon.texture = HudStyle.ICONS["warning"]
	tutorial.visible = not tutorial.text.is_empty()
	position_instruction()
	if cash_text_tween != null and cash_text_tween.is_valid():
		if run.phase == RunManager.Phase.PAUSED and cash_text_tween.is_running():
			cash_text_tween.pause()
			cash_text_paused = true
		elif run.phase != RunManager.Phase.PAUSED and cash_text_paused:
			cash_text_tween.play()
			cash_text_paused = false

func update_onboarding_hud(run: RunManager, _delta: float) -> void:
	var lesson = run.onboarding
	run.level.van.label.visible = lesson == null or lesson.guides_van()
	noise_panel.visible = lesson == null
	loot_lock.visible = lesson != null
	loot_caption.text = "ESCAPE TO KEEP" if lesson != null else "ESCAPE TO BANK"
	time_panel.visible = lesson == null
	pause_button.visible = true
	pause_button.get_parent().alignment = BoxContainer.ALIGNMENT_END if lesson != null else BoxContainer.ALIGNMENT_BEGIN
	loot_panel.visible = lesson == null or run.cargo.size() > 0
	cargo_panel.visible = lesson == null or run.cargo_used >= 5
	hud_top.visible = true
	hud_bottom.visible = lesson == null or run.can_escape()
	drop_button.visible = lesson == null and run.carried != null
	instruction_panel.visible = not run.can_escape()
	session_info.visible = lesson == null
	session_panel.visible = lesson == null
	noise_panel.modulate = Color.WHITE
	if lesson != null:
		session_info.text = "PRACTICE · NO REWARDS" if lesson.replay else "NEIGHBOR'S GARAGE"
		target.text = lesson.hint()
		# One short prompt, with world guidance carrying the destination.
		interaction_caption.text = lesson.lesson_title()
		if lesson.bank_explanation > 0:
			loot_caption.text = "LOOT STAYS IN THE VAN"
			interaction_caption.text = "LOOT IS IN THE VAN"
		escape_button.text = "ESCAPE & KEEP $%d" % run.cargo_value
	elif run.noise_hint_time > 0 and not run.alarm_active and run.current_noise < run.alarm_threshold * Balance.ALARM_WARNING_FACTOR:
		noise_status.text = "PICKUPS MAKE NOISE"
	if lesson == null and guidance.selected != null and not run.van_is_full():
		var reason = run.block_reason(guidance.selected)
		if reason == "NOT ENOUGH VAN SPACE":
			interaction_caption.text = "VAN FULL"
			target.text = "RETURN TO THE VAN · ESCAPE!"
		elif reason == "":
			target.text = "STOP TO PICK UP" if run.progress == 0 else "PICKING UP"

func show_cash_load(run: RunManager, amount: int) -> void:
	if not is_instance_valid(cash_effect):
		cash_effect = CashBurst3D.new()
		run.level.add_child(cash_effect)
		cash_effect.setup(run)
		cash_effect.tint(LuckyShop.accent(run.store.data, "load_vfx", Color("50ed88")))
		cash_effect.collected.connect(on_cash_collected)
	var visible_value: int = roundi(lerpf(float(cash_count_from), float(cash_count_to), cash_count_elapsed)) if cash_count_elapsed < 1.0 else run.cargo_value - amount
	cash_count_from = visible_value
	cash_count_to = run.cargo_value
	cash_count_elapsed = 0.0
	cash_effect.play_reward_vfx(amount)
	show_cash_amount(run, amount)

func show_cash_amount(run: RunManager, amount: int) -> void:
	if not hud.visible: return
	if cash_text_tween != null and cash_text_tween.is_valid(): cash_text_tween.kill()
	cash_text_paused = false
	cash_amount.text = "+$%d" % amount
	cash_amount.add_theme_color_override("font_color", LuckyShop.accent(run.store.data, "cash_vfx", HudStyle.GREEN))
	cash_amount_panel.reset_size()
	position_cash_amount(run)
	cash_amount_panel.show()
	cash_amount_panel.modulate.a = 1.0
	cash_amount_panel.pivot_offset = cash_amount_panel.size * 0.5
	cash_amount_panel.scale = Vector2.ONE * 0.85
	var origin := cash_amount_panel.position
	cash_text_tween = create_tween()
	cash_text_tween.tween_property(cash_amount_panel, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	cash_text_tween.parallel().tween_property(cash_amount_panel, "position:y", origin.y - 35, 0.65)
	cash_text_tween.tween_property(cash_amount_panel, "modulate:a", 0.0, 0.18)
	cash_text_tween.tween_callback(cash_amount_panel.hide)

func on_cash_collected(_amount: int) -> void:
	if not hud.visible: return
	if loot_pulse != null and loot_pulse.is_valid(): loot_pulse.kill()
	van_value.pivot_offset = van_value.size * 0.5
	van_value.scale = Vector2.ONE * 1.12
	loot_pulse = create_tween()
	loot_pulse.tween_property(van_value, "scale", Vector2.ONE, 0.18)
	cash_reward_collected.emit()

func clear_cash_burst() -> void:
	if is_instance_valid(cash_effect): cash_effect.queue_free()
	cash_effect = null
	if cash_text_tween != null and cash_text_tween.is_valid(): cash_text_tween.kill()
	cash_text_paused = false
	if is_instance_valid(cash_amount_panel): cash_amount_panel.hide()
	cash_count_elapsed = 1.0

func notify(message: String) -> void:
	if message == "": return
	if message.contains(" LOOT FOUND!"):
		var parts := message.split("|")
		var tier := parts[0].get_slice(" ", 0)
		var accent: Color = HudStyle.RARE if tier == "RARE" else (HudStyle.SPECIAL if tier == "EPIC" else HudStyle.GOLD)
		toast_panel.anchor_top = 0.24
		toast_panel.anchor_bottom = 0.24
		toast_panel.offset_left = 70
		toast_panel.offset_right = -70
		toast_panel.add_theme_stylebox_override("panel", HudStyle.plate(Color("271037"), accent, 18))
		toast.text = parts[0] + "\n" + (parts[1] if parts.size() > 1 else "")
		toast.add_theme_color_override("font_color", accent)
		toast_panel.show()
		toast_time = 1.8
		return
	if message.begins_with("ALARM!"): noise_gain_time = minf(noise_gain_time, 0.8)
	if message.begins_with("+") and message.contains("NOISE"):
		noise_gain = message.split(" · ")[0]
		noise_gain_time = 1.6
		return
	if message.begins_with("VAN +"):
		if loot_pulse != null and loot_pulse.is_valid(): loot_pulse.kill()
		van_value.pivot_offset = van_value.size / 2
		van_value.scale = Vector2.ONE * 1.15
		loot_pulse = create_tween()
		loot_pulse.tween_property(van_value, "scale", Vector2.ONE, 0.22)
		return
	if not (message.begins_with("ALARM!") or message.begins_with("VAN FULL")):
		return
	toast_panel.anchor_top = 0.5
	toast_panel.anchor_bottom = 0.5
	toast_panel.offset_left = 38
	toast_panel.offset_right = -38
	toast_panel.add_theme_stylebox_override("panel", HudStyle.plate(Color("2f0c48"), Color("7d38ad"), 18))
	toast.text = message
	toast_panel.show()
	toast.add_theme_color_override("font_color", HudStyle.RED if message.begins_with("ALARM!") else HudStyle.FINAL)
	toast_time = 0.8 if message.begins_with("ALARM!") else 1.5

func clear_menu() -> void:
	if jobs_transition != null and jobs_transition.is_valid(): jobs_transition.kill()
	if jobs_wallet_tween != null and jobs_wallet_tween.is_valid(): jobs_wallet_tween.kill()
	for old_card in get_tree().get_nodes_in_group("jobs_transition_card"):
		if is_instance_valid(old_card): old_card.queue_free()
	jobs_current_card = null
	for overlay in get_tree().get_nodes_in_group("ui_juice_overlay"):
		if is_instance_valid(overlay): overlay.queue_free()
	if is_instance_valid(menu):
		for preview in get_tree().get_nodes_in_group("menu_character_previews"):
			if menu.is_ancestor_of(preview): preview.stop()
		if page_motion_requested and not motion.travelling:
			motion.retain(menu)
		else:
			motion.discard_page()
			menu.hide()
			menu.queue_free()
		menu = null
	menu_outer = null
	menu_background = null
	menu_wallet_label = null
	menu_diamond_label = null
	upgrade_cards.clear()
	shop_preview = null
	shop_scroll = null
	cosmetic_gems_label = null
	wheel_disc = null
	wheel_result = null
	wheel_balance = null
	wheel_spin_button = null
	wheel_reset = null
	wheel_tickets = null
	wheel_busy = false
	result_overlay = null
	close_pause()
	close_trophy_modal()

func menu_style(color: Color, border: Color = Color("63288c"), radius: int = 20) -> StyleBoxFlat:
	var style = panel(color,radius)
	style.border_color = border
	style.set_border_width_all(3)
	style.border_width_bottom = 7
	style.shadow_color = Color(0.0454, 0.0100, 0.0700,0.5)
	style.shadow_offset = Vector2(0,4)
	style.shadow_size = 2
	return style

func blue_button(parent: Node, label: String, callback: Callable, height: int = 64) -> Button:
	var b = button(parent,label,callback,height)
	b.add_theme_stylebox_override("normal",menu_style(Color("7b09ca"),Color("aa2fff")))
	b.add_theme_stylebox_override("hover",menu_style(Color("9d25f0"),Color("c878ff")))
	b.add_theme_stylebox_override("pressed",menu_style(Color("5e089a"),Color("9325df")))
	b.add_theme_color_override("font_color",PAPER)
	b.add_theme_color_override("font_hover_color",PAPER)
	b.add_theme_color_override("font_pressed_color",PAPER)
	return b

func base_menu() -> VBoxContainer:
	clear_menu()
	hud.hide()
	input.enabled = false
	input.reset()
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background_style = panel(Color("2b0b41"),0)
	background_style.set_content_margin_all(0)
	menu.add_theme_stylebox_override("panel",background_style)
	root.add_child(menu)
	var theme = Theme.new()
	theme.set_font("font","Button",heavy_font)
	theme.set_font_size("font_size","Button",24)
	theme.set_stylebox("normal","Button",menu_style(Color("0de997"),Color("0b8269")))
	theme.set_stylebox("hover","Button",menu_style(Color("51ffc0"),Color("69ffe4")))
	theme.set_stylebox("pressed","Button",menu_style(Color("05b677"),Color("106858")))
	theme.set_stylebox("disabled","Button",menu_style(Color("3c204f"),Color("4f2d66")))
	theme.set_color("font_disabled_color","Button",Color("af94c1"))
	theme.set_stylebox("normal", "OptionButton", menu_style(Color("3a1256"), Color("71468f"), 14))
	theme.set_stylebox("hover", "OptionButton", menu_style(Color("471d64"), Color("a16bc7"), 14))
	theme.set_stylebox("pressed", "OptionButton", menu_style(Color("2d0b44"), Color("a16bc7"), 14))
	theme.set_color("font_color", "OptionButton", PAPER)
	theme.set_stylebox("panel", "PopupMenu", panel(Color("410b67"), 14))
	theme.set_stylebox("hover", "PopupMenu", panel(Color("512470"), 8))
	theme.set_color("font_color", "PopupMenu", PAPER)
	theme.set_color("font_hover_color", "PopupMenu", HudStyle.GREEN)
	theme.set_font_size("font_size", "PopupMenu", 22)
	theme.set_constant("v_separation", "PopupMenu", 20)
	for scroll_type in ["VScrollBar", "HScrollBar"]:
		var rail = noise_style(Color("250a37"))
		rail.content_margin_left = 3
		rail.content_margin_right = 3
		theme.set_stylebox("scroll", scroll_type, rail)
		for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
			theme.set_stylebox(state, scroll_type, noise_style(Color("77439b")))
	menu.theme = theme
	menu_background = ColorRect.new()
	var background_material = ShaderMaterial.new()
	background_material.shader = preload("res://assets/shaders/menu_studio.gdshader")
	menu_background.material = background_material
	menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(menu_background)
	menu_outer = margin(menu, PAGE_GUTTER)
	apply_page_margins(menu_outer)
	if page_motion_requested:
		page_motion_requested = false
		if not motion.travelling: motion.reveal(menu)
	return column(menu_outer, PAGE_SPACING)

func headline(parent: Node, value: String, size: int = 44, color: Color = PAPER, centered: bool = false) -> Label:
	var label = text(parent,value,size,color)
	label.add_theme_font_override("font",heavy_font)
	label.add_theme_color_override("font_outline_color",Color("180624"))
	label.add_theme_constant_override("outline_size",5)
	label.add_theme_color_override("font_shadow_color",Color("1a0529"))
	label.add_theme_constant_override("shadow_offset_y",4)
	if centered: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func menu_header(body: VBoxContainer, title: String, wallet: int, subtitle: String = "", diamonds: int = 0) -> Label:
	var top = row(body, 12)
	var back = blue_button(top,"‹ HOME",func(): action_requested.emit("home"),76)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var space = Control.new()
	space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(space)
	var money = wallet_chip(top, wallet, diamonds)
	headline(body,title,40)
	if subtitle != "": text(body,subtitle,18,Color("c2a8d4"))
	return money

func wallet_chip(parent: Node, amount: int, diamonds: int = 0) -> Label:
	var shell = PanelContainer.new()
	var style = panel(Color("290c3e"), 18)
	style.set_content_margin_all(9)
	style.border_color = Color("593075")
	style.set_border_width_all(1)
	shell.add_theme_stylebox_override("panel", style)
	shell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(shell)
	var line = row(shell, 8)
	HudStyle.icon(line, "cash", 38)
	var money = headline(line, "$" + cash_text(amount), 28, HudStyle.MONEY)
	money.autowrap_mode = TextServer.AUTOWRAP_OFF
	money.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu_wallet_label = money
	add_diamond_balance(line,diamonds,28,36)
	return money

func cash_text(value: int) -> String:
	var digits = str(value)
	var out = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length()-i) % 3 == 0: out += ","
		out += digits[i]
	return out

func add_diamond_balance(parent: Node, amount: int, pixels: int = 28, icon_size: int = 36) -> Label:
	var line = row(parent,5)
	line.name = "DiamondBalance"
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon := TextureRect.new()
	icon.texture = preload("res://assets/ui/diamond.png")
	icon.custom_minimum_size = Vector2(icon_size,icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	line.add_child(icon)
	menu_diamond_label = headline(line,str(amount),pixels,HudStyle.INFO)
	menu_diamond_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	menu_diamond_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return menu_diamond_label

func scroll_body(parent: VBoxContainer) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var body = column(scroll,14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return body

func navigation(parent: VBoxContainer, selected: String, height: int = 68, store: SaveStore = null) -> void:
	height = maxi(height, 100)
	var links = row(parent, 8)
	links.add_to_group("jobs_navigation")
	var last_tab := ["GARAGE", "garage", "garage"]
	for entry in [["HOME", "home", "home"], ["JOBS", "locations", "jobs"], ["UPGRADES", "shop", "upgrades"], last_tab]:
		var active: bool = entry[1] == selected or (entry[1] == "garage" and selected in ["collection","trophies"])
		var tab = button(links, "", func(): action_requested.emit(entry[1]), height)
		tab.tooltip_text = entry[0]
		tab.accessibility_name = entry[0]
		tab.clip_text = true
		tab.disabled = entry[1] == ""
		tab.add_to_group("jobs_nav_tab")
		var style = jobs_style(Color("6b2bb4") if active else Color("3a1160"), Color("b57cff") if active else Color("5f339c"), 18, 0, 5)
		if active:
			style.shadow_color = Color("b070ff", 0.35)
			style.shadow_size = 7
			style.shadow_offset = Vector2.ZERO
		tab.add_theme_stylebox_override("normal", style)
		for state in ["hover", "pressed"]:
			var touch_style = style.duplicate()
			touch_style.bg_color = style.bg_color.lightened(0.06) if state == "hover" else style.bg_color.darkened(0.12)
			tab.add_theme_stylebox_override(state, touch_style)
		var icon = TextureRect.new()
		icon.add_to_group("jobs_nav_icon")
		icon.texture = MenuArt.texture(entry[2])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 18
		icon.offset_right = -18
		icon.offset_top = 8
		icon.offset_bottom = -34
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tab.add_child(icon)
		var caption = jobs_label(tab, entry[0], 17, PAPER, false, 3)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.clip_text = true
		caption.anchor_right = 1.0
		caption.anchor_top = 1.0
		caption.anchor_bottom = 1.0
		caption.offset_left = 2
		caption.offset_right = -2
		caption.offset_top = -32
		caption.offset_bottom = -7
		if entry[1] == "shop" and store != null:
			for key in Balance.UPGRADE_KEYS:
				var level: int = int(store.data.upgrades[key])
				if level < Balance.purchase_cap(key, store.data) and store.data.wallet >= Balance.upgrade_cost(key, level):
					var dot := Label.new()
					dot.name = "UpgradeNotice"
					dot.text = "●"
					dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
					dot.anchor_left = 1.0
					dot.anchor_right = 1.0
					dot.offset_left = -23
					dot.offset_right = -2
					dot.offset_top = -2
					dot.offset_bottom = 20
					dot.add_theme_color_override("font_color", HudStyle.RED)
					tab.add_child(dot)
					break

# Shared top bar: cash and diamonds as pills with an earn button, settings gear.
func currency_header(frame: VBoxContainer, store: SaveStore, settings_name: String = "") -> Button:
	var header = row(frame, 10)
	var wallet = jobs_currency_pill(header, "res://assets/hud/cash.png", "$" + cash_text(store.data.wallet), HudStyle.MONEY, Color("1fb85a"), "daily_wheel")
	menu_wallet_label = wallet
	jobs_count_wallet(wallet, store.data.wallet)
	menu_diamond_label = jobs_currency_pill(header, "res://assets/ui/diamond.png", str(store.data.diamonds), Color("8fd6ff"), Color("2f6fe8"), "lucky_shop")
	var settings = button(header, "", func(): action_requested.emit("settings"), 62)
	settings.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	settings.custom_minimum_size = Vector2(66, 62)
	settings.tooltip_text = "SETTINGS"
	settings.add_theme_stylebox_override("normal", jobs_style(Color("4a1679"), Color("8b42d4"), 18, 0, 4))
	settings.add_theme_stylebox_override("hover", jobs_style(Color("5a1e90"), Color("a457ee"), 18, 0, 4))
	settings.add_theme_stylebox_override("pressed", jobs_style(Color("3a1160"), Color("8b42d4"), 18, 0, 4))
	var gear = jobs_icon(settings, "res://assets/ui/settings.svg", 44)
	gear.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	gear.offset_left = -22
	gear.offset_right = 22
	gear.offset_top = -23
	gear.offset_bottom = 21
	if settings_name != "": settings.name = settings_name
	return settings

# Jobs page building blocks: Bungee for display, Lilita One for copy.
func jobs_label(parent: Node, value: String, size: int, color: Color = PAPER, display: bool = false, outline: int = 0) -> Label:
	var label = text(parent, value, size, color)
	label.add_theme_font_override("font", display_font if display else body_font)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	if outline > 0:
		label.add_theme_color_override("font_outline_color", Color("1c0630"))
		label.add_theme_constant_override("outline_size", outline)
	return label

func jobs_style(fill: Color, edge: Color, radius: int = 18, margin: int = 10, bottom: int = 4) -> StyleBoxFlat:
	var style = menu_style(fill, edge, radius)
	style.set_content_margin_all(margin)
	style.set_border_width_all(2)
	style.border_width_bottom = bottom
	style.shadow_color = Color("12041f", 0.45)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 3)
	return style

func jobs_icon(parent: Node, path: String, size: float) -> TextureRect:
	var icon = TextureRect.new()
	icon.texture = load(path)
	icon.custom_minimum_size = Vector2(size, size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(icon)
	return icon

func jobs_lucky_block(parent: Node, size: float) -> TextureRect:
	var block = jobs_icon(parent, "res://assets/ui/lucky_block.png", size)
	block.add_to_group("jobs_lucky_block")
	block.pivot_offset = Vector2(size, size) * 0.5
	var bob = block.create_tween().set_loops()
	bob.tween_property(block, "scale", Vector2(1.04, 1.04), 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(block, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return block

func jobs_sparkles(host: Control, count: int, seed_value: int, area: Rect2 = Rect2(0.02, 0.02, 0.96, 0.96)) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var spark = ColorRect.new()
		spark.color = [Color("ff5ce1"), Color("c88cff"), Color("ffd84a"), Color("9d4dff")][i % 4]
		var side = rng.randf_range(6, 13)
		var fx = area.position.x + rng.randf() * area.size.x
		var fy = area.position.y + rng.randf() * area.size.y
		spark.anchor_left = fx
		spark.anchor_right = fx
		spark.anchor_top = fy
		spark.anchor_bottom = fy
		spark.offset_left = -side * 0.5
		spark.offset_right = side * 0.5
		spark.offset_top = -side * 0.5
		spark.offset_bottom = side * 0.5
		spark.pivot_offset = Vector2(side, side) * 0.5
		spark.rotation = rng.randf_range(0.0, PI * 0.5)
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(spark)
		var twinkle = spark.create_tween().set_loops()
		twinkle.tween_property(spark, "modulate:a", 0.25, rng.randf_range(0.6, 1.3)).set_trans(Tween.TRANS_SINE)
		twinkle.tween_property(spark, "modulate:a", 1.0, rng.randf_range(0.6, 1.3)).set_trans(Tween.TRANS_SINE)

func jobs_block_stage(parent: Node, size: float, seed_value: int) -> Control:
	var stage = Control.new()
	stage.custom_minimum_size = Vector2(size, size * 0.92)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(stage)
	jobs_sparkles(stage, 8, seed_value)
	var block = jobs_lucky_block(stage, size * 0.9)
	block.position = Vector2(size * 0.05, size * 0.06)
	block.size = Vector2(size * 0.9, size * 0.9 * 445.0 / 512.0)
	return stage

func jobs_currency_pill(parent: Node, icon_path: String, value: String, color: Color, plus_color: Color, plus_action: String) -> Label:
	var shell = PanelContainer.new()
	shell.add_theme_stylebox_override("panel", jobs_style(Color("3a0f60"), Color("8b42d4"), 22, 5, 4))
	shell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(shell)
	var line = row(shell, 6)
	jobs_icon(line, icon_path, 46)
	var label = jobs_label(line, value, 30, color, true, 3)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	var plus = button(line, "+", func(): action_requested.emit(plus_action), 40)
	plus.size_flags_horizontal = Control.SIZE_SHRINK_END
	plus.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plus.custom_minimum_size = Vector2(40, 40)
	plus.tooltip_text = "EARN MORE"
	plus.add_theme_font_override("font", display_font)
	plus.add_theme_font_size_override("font_size", 24)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: plus.add_theme_color_override(state, Color.WHITE)
	plus.add_theme_stylebox_override("normal", jobs_style(plus_color, plus_color.lightened(0.4), 12, 0, 3))
	plus.add_theme_stylebox_override("hover", jobs_style(plus_color.lightened(0.08), plus_color.lightened(0.4), 12, 0, 3))
	plus.add_theme_stylebox_override("pressed", jobs_style(plus_color.darkened(0.2), plus_color, 12, 0, 3))
	return label

func add_preview(parent: VBoxContainer, store: SaveStore, kind: String, height: float) -> MenuCharacterPreview:
	var preview = MenuCharacterPreview.new()
	preview.configure(store,kind,height)
	parent.add_child(preview)
	preview.suspend(not menu_previews_active)
	return preview

func set_previews_active(active: bool) -> void:
	menu_previews_active = active
	for preview in get_tree().get_nodes_in_group("menu_character_previews"):
		preview.suspend(not active)

func home(store: SaveStore) -> void:
	var body = base_menu()
	body.add_theme_constant_override("separation", 8)
	currency_header(body, store, "HomeSettings")
	if not store.data.lucky_pending.is_empty() and store.data.lucky_pending.seen:
		var effect_id: String = store.data.lucky_pending.id
		var next_effect = jobs_label(body, "NEXT RUN · " + LuckyEffects.CATALOG[effect_id][0], 18, MINT if LuckyEffects.positive(effect_id) else HudStyle.SPECIAL)
		next_effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		next_effect.tooltip_text = LuckyEffects.CATALOG[effect_id][1]
	# Title zone: the supplied logo between the Daily Wheel and the Daily Gift.
	var title_zone = Control.new()
	title_zone.name = "HomeTitleZone"
	title_zone.custom_minimum_size.y = 226
	title_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(title_zone)
	var logo = TextureRect.new()
	logo.name = "HomeLogo"
	logo.texture = preload("res://assets/ui/home/logo_lucky_robber.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.anchor_left = 0.5
	logo.anchor_right = 0.5
	logo.anchor_top = 0.5
	logo.anchor_bottom = 0.5
	logo.offset_left = -206
	logo.offset_right = 206
	logo.offset_top = -118
	logo.offset_bottom = 118
	logo.pivot_offset = Vector2(206, 118)
	title_zone.add_child(logo)
	var breathe = logo.create_tween().set_loops()
	breathe.tween_property(logo, "scale", Vector2(1.025, 1.025), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(logo, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var wheel_entry = home_reward_icon(title_zone, MenuArt.texture("wheel"), func(): action_requested.emit("daily_wheel"))
	wheel_entry.name = "DailyWheelEntry"
	wheel_entry.tooltip_text = "Daily Wheel"
	wheel_entry.set_anchors_preset(Control.PRESET_TOP_LEFT)
	wheel_entry.offset_left = -4
	wheel_entry.offset_right = 150
	wheel_entry.offset_top = 14
	wheel_entry.offset_bottom = 168
	home_gift_button = home_reward_icon(title_zone, preload("res://assets/ui/home/daily-gift.png"), func(): action_requested.emit("daily_gift"))
	home_gift_button.name = "DailyGiftButton"
	home_gift_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	home_gift_button.offset_left = -150
	home_gift_button.offset_right = 4
	home_gift_button.offset_top = 14
	home_gift_button.offset_bottom = 168
	refresh_home_gift(store)
	var fit_title = func():
		var narrow: bool = title_zone.size.x < 600.0
		var icon_size: float = 112.0 if narrow else 154.0
		var logo_half: float = minf(206.0, (title_zone.size.x - 2.0 * icon_size + 50.0) * 0.5)
		logo.offset_left = -logo_half
		logo.offset_right = logo_half
		logo.offset_top = -logo_half * 0.573
		logo.offset_bottom = logo_half * 0.573
		logo.pivot_offset = Vector2(logo_half, logo_half * 0.573)
		for entry in [wheel_entry, home_gift_button]:
			entry.custom_minimum_size = Vector2(icon_size, icon_size)
			entry.offset_top = 14
			entry.offset_bottom = 14 + icon_size
		wheel_entry.offset_left = -4
		wheel_entry.offset_right = icon_size - 4
		home_gift_button.offset_left = -icon_size + 4
		home_gift_button.offset_right = 4
	title_zone.resized.connect(fit_title)
	fit_title.call()
	var preview = add_preview(body, store, "home", 250)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview.attach_home_backdrop(menu)
	home_target_caption(preview, store)
	# PLAY: the one big yellow action.
	var play = button(body, "PLAY", func(): action_requested.emit("play"), 132)
	play.name = "HomePlay"
	play.tooltip_text = "CHOOSE YOUR NEXT JOB"
	play.add_theme_font_override("font", display_font)
	play.add_theme_font_size_override("font_size", 64)
	play.add_theme_color_override("font_shadow_color", Color("2a0a4a", 0.35))
	play.add_theme_constant_override("shadow_offset_y", 3)
	for state in ["normal", "hover", "pressed"]:
		play.add_theme_stylebox_override(state, jobs_primary_button_style(false, state))
		play.add_theme_color_override("font_color" if state == "normal" else "font_" + state + "_color", Color("1d0f2e"))
	var play_icon = jobs_label(play, "▶", 52, Color("1d0f2e"), true)
	play_icon.anchor_left = 0.27
	play_icon.anchor_right = 0.27
	play_icon.anchor_top = 0.5
	play_icon.anchor_bottom = 0.5
	play_icon.offset_left = -34
	play_icon.offset_right = 34
	play_icon.offset_top = -36
	play_icon.offset_bottom = 36
	play_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	play_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	jobs_pulse(play)
	jobs_shine(play)
	var shortcuts = row(body, 12)
	home_shortcut(shortcuts, "UPGRADES", "upgrades", func(): action_requested.emit("shop"), store)
	home_shortcut(shortcuts, "GARAGE", "garage", func(): action_requested.emit("garage"), store)
	home_shortcut(shortcuts, "LOCKER", "cosmetics", func(): action_requested.emit("cosmetics"), store)
	lucky_meter_panel(body, store)
	if store.last_error != "": jobs_label(body, store.last_error, 18, Color("ffac94"))

# One line under the character says what the next run is for; tapping it goes there.
func home_target_caption(host: Control, store: SaveStore) -> Button:
	var target_info: Dictionary = Progression.next_result_target(store.data)
	var kicker := "NEXT TARGET"
	var title: String = str(target_info.title)
	var action := "locations"
	var upgrade_focus := str(target_info.get("upgrade_key", ""))
	var hint: String = str(target_info.hint)
	if not store.data.tutorial_completed:
		kicker = "FIRST JOB"
		title = "GRAB YOUR FIRST LOOT"
		action = "play"
	elif store.data.special_pending:
		kicker = "RUSH HOUR READY"
		title = str(Balance.LOCATIONS[store.data.special_location_id].name).to_upper()
		action = "play_special"
	elif upgrade_focus != "" or hint.begins_with("Upgrade Strength") or hint.begins_with("Upgrade the van"):
		action = "shop"
		if upgrade_focus == "": upgrade_focus = "strength" if hint.begins_with("Upgrade Strength") else "capacity"
	elif title == "STEAL EVERYTHING" and hint == "Complete the Apartment Final Job":
		kicker = "FINAL JOB READY"
		action = "play_final_job"
	elif title == "STEAL THE TIME MACHINE" and hint == "Complete the Museum Final Job":
		kicker = "CHAPTER 1 FINALE"
		action = "play_museum_final_job"
	var caption = button(host, "%s · %s  >" % [kicker, title], func():
		action_requested.emit(action)
		if action == "shop" and upgrade_focus != "": shop_select(upgrade_focus, true)
	, 44)
	caption.name = "HomeTargetPanel"
	caption.add_theme_font_override("font", body_font)
	caption.add_theme_font_size_override("font_size", 18)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: caption.add_theme_color_override(state, PAPER)
	caption.add_theme_color_override("font_outline_color", Color("1c0630"))
	caption.add_theme_constant_override("outline_size", 3)
	caption.add_theme_stylebox_override("normal", jobs_style(Color("2d0b47", 0.82), Color("8a44d6", 0.9), 22, 6, 3))
	caption.add_theme_stylebox_override("hover", jobs_style(Color("3a1160", 0.9), Color("a45cf0"), 22, 6, 3))
	caption.add_theme_stylebox_override("pressed", jobs_style(Color("22083a", 0.9), Color("8a44d6"), 22, 6, 3))
	caption.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caption.anchor_left = 0.5
	caption.anchor_right = 0.5
	caption.anchor_top = 1.0
	caption.anchor_bottom = 1.0
	caption.offset_top = -50
	caption.offset_bottom = -6
	var fit = func():
		var half: float = minf(host.size.x * 0.5 - 8.0, caption.get_combined_minimum_size().x * 0.5 + 18.0)
		caption.offset_left = -half
		caption.offset_right = half
	host.resized.connect(fit)
	caption.resized.connect(fit)
	fit.call()
	return caption

# The one progress bar that is always moving: every heist fills it, a full bar is a Lucky Block.
func lucky_meter_panel(body: VBoxContainer, store: SaveStore, compact: bool = false) -> PanelContainer:
	var shell = PanelContainer.new()
	shell.name = "LuckyMeterPanel"
	shell.add_theme_stylebox_override("panel", jobs_style(Color("2d0b47", 0.93), Color("8a44d6"), 20, 10 if compact else 12, 4))
	body.add_child(shell)
	var line = row(shell, 12)
	var cube = jobs_icon(line, "res://assets/ui/lucky_block.png", 56 if compact else 72)
	cube.name = "LuckyMeterCube"
	var copy = column(line, 4)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var head = row(copy, 8)
	var title = jobs_label(head, "LUCKY METER", 19 if compact else 22, Color("c9a6ec"), true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value = jobs_label(head, "%d/%d" % [int(store.data.lucky_meter), LuckyMeter.TARGET], 19 if compact else 22, PAPER, true, 3)
	value.name = "LuckyMeterValue"
	var bar = ProgressBar.new()
	bar.name = "LuckyMeterBar"
	bar.custom_minimum_size.y = 14 if compact else 18
	bar.show_percentage = false
	bar.value = 100.0 * int(store.data.lucky_meter) / LuckyMeter.TARGET
	var track = panel(Color("1a0630"), 8)
	track.set_content_margin_all(0)
	track.border_color = Color("5a2f80")
	track.set_border_width_all(1)
	var fill = panel(HudStyle.MONEY, 8)
	fill.set_content_margin_all(0)
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)
	copy.add_child(bar)
	var tokens = jobs_label(copy, "%d TOKEN%s · FULL METER = LUCKY BLOCK" % [int(store.data.lucky_tokens), "" if int(store.data.lucky_tokens) == 1 else "S"], 14 if compact else 16, Color("b79ad0"))
	tokens.name = "LuckyTokensLabel"
	tokens.clip_text = true
	var open_shop = button(line, "LUCKY\nSHOP >", func(): action_requested.emit("lucky_shop"), 60 if compact else 78)
	open_shop.name = "LuckyShopButton"
	open_shop.custom_minimum_size.x = 120 if compact else 150
	open_shop.size_flags_horizontal = Control.SIZE_SHRINK_END
	open_shop.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	open_shop.add_theme_font_override("font", body_font)
	open_shop.add_theme_font_size_override("font_size", 18 if compact else 22)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: open_shop.add_theme_color_override(state, PAPER)
	open_shop.add_theme_stylebox_override("normal", jobs_style(Color("6a2aa6"), Color("b578ff"), 16, 4, 4))
	open_shop.add_theme_stylebox_override("hover", jobs_style(Color("7a35bf"), Color("c894ff"), 16, 4, 4))
	open_shop.add_theme_stylebox_override("pressed", jobs_style(Color("55208a"), Color("b578ff"), 16, 4, 4))
	return shell

func home_reward_icon(parent: Control, artwork: Texture2D, callback: Callable) -> Button:
	var control := Button.new()
	control.custom_minimum_size = Vector2(150,150)
	control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","disabled","focus"]:
		control.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	parent.add_child(control)
	# Soft purple pool under the reward, like a spotlight on the garage floor.
	var glow := TextureRect.new()
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color("9b3cff", 0.55), Color("9b3cff", 0.18), Color("9b3cff", 0.0)])
	var disc := GradientTexture2D.new()
	disc.width = 96
	disc.height = 96
	disc.gradient = gradient
	disc.fill = GradientTexture2D.FILL_RADIAL
	disc.fill_from = Vector2(0.5, 0.5)
	disc.fill_to = Vector2(1.0, 0.5)
	glow.texture = disc
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.anchor_left = 0.5
	glow.anchor_right = 0.5
	glow.anchor_top = 1.0
	glow.anchor_bottom = 1.0
	glow.offset_left = -80
	glow.offset_right = 80
	glow.offset_top = -46
	glow.offset_bottom = 8
	control.add_child(glow)
	var picture := TextureRect.new()
	picture.texture = artwork
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.offset_bottom = -14
	control.add_child(picture)
	var spark = jobs_label(control, "✦", 22, Color("ffe37a"))
	spark.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	spark.offset_left = 4
	spark.offset_top = 2
	spark.offset_right = 30
	spark.offset_bottom = 30
	var twinkle = spark.create_tween().set_loops()
	twinkle.tween_property(spark, "modulate:a", 0.2, 0.9).set_trans(Tween.TRANS_SINE)
	twinkle.tween_property(spark, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
	control.pressed.connect(callback)
	UiJuice.button_touch(control)
	return control

func refresh_home_gift(store: SaveStore) -> void:
	if not is_instance_valid(home_gift_button): return
	var remaining := store.daily_gift_remaining()
	home_gift_button.disabled = remaining > 0 or store.read_only
	home_gift_button.modulate = Color(0.7026, 0.6200, 0.7600) if home_gift_button.disabled else Color.WHITE
	home_gift_button.tooltip_text = "Daily Gift" if remaining == 0 else "Daily Gift · %dh %02dm" % [remaining / 3600,(remaining % 3600) / 60]

func show_daily_gift_reward(prize: Dictionary, old_cash: int, store: SaveStore) -> void:
	refresh_home_gift(store)
	if is_instance_valid(menu_wallet_label):
		UiJuice.count_label(menu_wallet_label, old_cash, int(store.data.wallet), 0.55)
	if is_instance_valid(home_gift_button): UiJuice.pulse(home_gift_button, 1.08, 0.25)

func home_shortcut(parent: HBoxContainer, label: String, icon_name: String, callback: Callable, store: SaveStore) -> void:
	var shortcut = button(parent, label, callback, 150)
	shortcut.tooltip_text = label
	shortcut.accessibility_name = label
	shortcut.clip_text = true
	shortcut.add_to_group("home_shortcut")
	shortcut.add_theme_font_override("font", body_font)
	shortcut.add_theme_font_size_override("font_size", 22)
	shortcut.add_theme_color_override("font_outline_color", Color("1c0630"))
	shortcut.add_theme_constant_override("outline_size", 4)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: shortcut.add_theme_color_override(state, PAPER)
	shortcut.add_theme_stylebox_override("normal", jobs_style(Color("5a1c9c"), Color("b57cff"), 22, 8, 6))
	shortcut.add_theme_stylebox_override("hover", jobs_style(Color("6a25b4"), Color("c894ff"), 22, 8, 6))
	shortcut.add_theme_stylebox_override("pressed", jobs_style(Color("471577"), Color("b57cff"), 22, 8, 6))
	# Artwork above the label, both drawn by the button itself.
	shortcut.alignment = HORIZONTAL_ALIGNMENT_CENTER
	shortcut.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	shortcut.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shortcut.icon = MenuArt.texture(icon_name)
	shortcut.expand_icon = true
	shortcut.add_theme_constant_override("icon_max_width", 96)
	shortcut.add_theme_constant_override("h_separation", 0)
	shortcut.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var spark = jobs_label(shortcut, "✦", 20, Color("ffe37a"))
	spark.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	spark.offset_left = -30
	spark.offset_right = -6
	spark.offset_top = 4
	spark.offset_bottom = 30
	if label == "UPGRADES":
		for key in Balance.UPGRADE_KEYS:
			var level: int = int(store.data.upgrades[key])
			if level < Balance.purchase_cap(key, store.data) and store.data.wallet >= Balance.upgrade_cost(key, level):
				var notice = Label.new()
				notice.name = "UpgradeNotice"
				notice.text = "●"
				notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
				notice.add_theme_font_size_override("font_size", 24)
				notice.add_theme_color_override("font_color", HudStyle.RARE)
				notice.anchor_left = 1.0
				notice.anchor_right = 1.0
				notice.offset_left = -30
				notice.offset_right = -4
				shortcut.add_child(notice)
				break

func page(kicker: String, title: String, wallet: int, diamonds: int = 0) -> VBoxContainer:
	var frame = base_menu()
	menu_header(frame,title,wallet,kicker,diamonds)
	return scroll_body(frame)

func locations(store: SaveStore) -> void:
	if jobs_index < 0 and store.data.special_pending:
		jobs_index = Balance.LOCATION_ORDER.find(store.data.special_location_id)
	var chapter_two_start := Balance.LOCATION_ORDER.find("pyramid")
	var entry_count := chapter_two_start + 1 if not store.unlocked("pyramid") else Balance.LOCATION_ORDER.size()
	jobs_index = clampi(jobs_index, 0, entry_count - 1)
	var frame = base_menu()
	frame.add_theme_constant_override("separation", 10)
	# Faint lucky blocks drift in the top corner of the page background.
	var decor = Control.new()
	decor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	decor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(decor)
	menu.move_child(decor, 1)
	for spot in [[0.80, 0.03, 96, 0.14], [0.94, 0.02, 60, 0.10]]:
		var ghost = jobs_icon(decor, "res://assets/ui/lucky_block.png", spot[2])
		ghost.anchor_left = spot[0]
		ghost.anchor_right = spot[0]
		ghost.anchor_top = spot[1]
		ghost.anchor_bottom = spot[1]
		ghost.offset_left = -spot[2] * 0.5
		ghost.offset_right = spot[2] * 0.5
		ghost.offset_top = -spot[2] * 0.5
		ghost.offset_bottom = spot[2] * 0.5
		ghost.modulate = Color(1, 1, 1, spot[3])
	currency_header(frame, store)
	var index := jobs_index
	var location: String = Balance.LOCATION_ORDER[index]
	# Chapter bar: name plate, heist type, page dots.
	var chapter_bar = PanelContainer.new()
	chapter_bar.add_theme_stylebox_override("panel", jobs_style(Color("3b1160"), Color("7a36bf"), 18, 6, 4))
	frame.add_child(chapter_bar)
	var chapter = row(chapter_bar, 12)
	var chapter_plate = PanelContainer.new()
	var plate_style = jobs_style(Color("5c1f97"), Color("a052f0"), 14, 4, 3)
	plate_style.content_margin_left = 12
	plate_style.content_margin_right = 12
	chapter_plate.add_theme_stylebox_override("panel", plate_style)
	chapter.add_child(chapter_plate)
	var chapter_number = jobs_label(chapter_plate, "CHAPTER %d" % [1 if index < chapter_two_start else 2], 30, PAPER, true, 5)
	chapter_number.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var chapter_divider = jobs_label(chapter, "|", 26, Color("a97fd0"))
	chapter_divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var chapter_name = jobs_label(chapter, "NORMAL HEISTS" if index < chapter_two_start else "BEYOND THE ORDINARY", 23, Color("d9b8f5"))
	chapter_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chapter_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapter_name.clip_text = true
	var chapter_start := 0 if index < chapter_two_start else chapter_two_start
	var chapter_end := mini(entry_count, chapter_two_start) if index < chapter_two_start else entry_count
	var dots = row(chapter, 8)
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	dots.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i in range(chapter_start, chapter_end):
		var dot = Button.new()
		dot.add_to_group("jobs_page_dot")
		dot.set_meta("location_index", i)
		dot.set_meta("active", i == index)
		dot.custom_minimum_size = Vector2(18, 18)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var dot_style = panel(HudStyle.MONEY if i == index else Color("5a4a6e"), 4)
		dot_style.set_content_margin_all(0)
		for state in ["normal", "hover", "pressed", "focus"]: dot.add_theme_stylebox_override(state, dot_style)
		dot.pressed.connect(func(): job_select(store, i))
		dots.add_child(dot)
		dot.pivot_offset = Vector2(9, 9)
		if i == index:
			dot.scale = Vector2.ONE * 0.72
			dot.create_tween().tween_property(dot, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var selector = column(frame, 6)
	if not store.data.lucky_pending.is_empty() and store.data.lucky_pending.seen:
		var effect_id: String = store.data.lucky_pending.id
		var next_effect = jobs_label(selector, "NEXT RUN · " + LuckyEffects.CATALOG[effect_id][0], 18, MINT if LuckyEffects.positive(effect_id) else HudStyle.SPECIAL)
		next_effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		next_effect.tooltip_text = LuckyEffects.CATALOG[effect_id][1]
	selector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	selector.alignment = BoxContainer.ALIGNMENT_BEGIN
	selector.clip_contents = true
	var card_panel = PanelContainer.new()
	card_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_panel.clip_contents = true
	card_panel.add_theme_stylebox_override("panel", jobs_card_style(not store.unlocked(location)))
	selector.add_child(card_panel)
	jobs_current_card = card_panel
	var content = column(card_panel, 10)
	# The hero expands into the remaining height. A percentage minimum could
	# push fixed actions below the safe area on a short phone with extra offers.
	jobs_hero(content, store, location, not store.unlocked(location), 200.0)
	if not store.unlocked(location):
		if location == "pyramid":
			jobs_chapter_lock(content, store)
		else:
			var previous: String = Balance.LOCATION_ORDER[index-1]
			var return_to_job = jobs_secondary_button(row(content, 0), "PLAY " + Balance.LOCATIONS[previous].name, func(): job_select(store, index - 1))
			return_to_job.add_to_group("jobs_locked_return")
	else:
		jobs_playable_content(content, store, location)
	if store.last_error != "": jobs_label(frame, store.last_error, 16, Color("ffac94"))
	jobs_navigation(frame, store)

func jobs_chapter_lock(content: VBoxContainer, store: SaveStore) -> void:
	var lock_screen = PanelContainer.new()
	lock_screen.add_to_group("jobs_chapter_lock_screen")
	lock_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lock_screen.add_theme_stylebox_override("panel", jobs_style(Color("2f1044"), HudStyle.FINAL.darkened(0.16), 19, 15, 5))
	content.add_child(lock_screen)
	var body = column(lock_screen, 7)
	var title = jobs_label(body, "CHAPTER 2 LOCKED", 28, HudStyle.FINAL, true, 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var requirement = jobs_label(body, "COMPLETE MUSEUM TO UNLOCK THIS CHAPTER", 21, PAPER)
	requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	requirement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var detail = jobs_label(body, "Finish the Museum Final Job", 17, MUTED)
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var visit = jobs_secondary_button(row(body, 0), "GO TO MUSEUM", func(): job_select(store, Balance.LOCATION_ORDER.find("museum")))
	visit.add_to_group("jobs_chapter_lock_action")

func jobs_hero(content: VBoxContainer, store: SaveStore, location: String, locked: bool, minimum_height: float) -> void:
	var hero = Control.new()
	hero.custom_minimum_size.y = minimum_height
	hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.clip_contents = true
	hero.mouse_filter = Control.MOUSE_FILTER_STOP
	hero.tooltip_text = Balance.LOCATIONS[location].name
	hero.gui_input.connect(func(event: InputEvent): jobs_preview_input(event, store))
	content.add_child(hero)
	var source: Texture2D = load(JOB_PREVIEWS[location])
	var image = TextureRect.new()
	image.texture = source
	image.add_to_group("jobs_hero_image")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material = ShaderMaterial.new()
	material.shader = JOB_COVER_SHADER
	material.set_shader_parameter("locked", 1.0 if locked else 0.0)
	material.set_shader_parameter("radius", 26.0)
	image.material = material
	hero.add_child(image)
	var fit = func():
		var texture_size: Vector2 = source.get_size()
		var scale_xy := Vector2(hero.size.x / maxf(texture_size.x, 1.0), hero.size.y / maxf(texture_size.y, 1.0))
		var cover: float = maxf(scale_xy.x, scale_xy.y)
		material.set_shader_parameter("cover_scale", scale_xy / maxf(cover, 0.0001))
		material.set_shader_parameter("rect_size", hero.size)
	hero.resized.connect(fit)
	fit.call()
	var hero_edge = PanelContainer.new()
	var edge_style = panel(Color.TRANSPARENT, 26)
	edge_style.set_content_margin_all(0)
	edge_style.border_color = Color("8e45d6")
	edge_style.set_border_width_all(3)
	hero_edge.add_theme_stylebox_override("panel", edge_style)
	hero_edge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hero_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(hero_edge)
	if locked:
		var lock_icon = jobs_icon(hero, "res://assets/hud/lock.svg", 66)
		lock_icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		lock_icon.position = Vector2(-33, -35)
	else:
		jobs_sparkles(hero, 7, 41, Rect2(0.72, 0.42, 0.26, 0.5))
		var block = jobs_lucky_block(hero, 132)
		block.anchor_left = 1.0
		block.anchor_right = 1.0
		block.anchor_top = 1.0
		block.anchor_bottom = 1.0
		block.offset_left = -144
		block.offset_right = -12
		block.offset_top = -126
		block.offset_bottom = -8
		block.pivot_offset = Vector2(66, 59)
	if location == "laboratory" and store.data.duplication.unlocked:
		var access = blue_button(hero, "IDLE LAB", func(): action_requested.emit("duplication"), 45)
		access.anchor_left = 1.0
		access.anchor_right = 1.0
		access.offset_left = -154
		access.offset_right = -13
		access.offset_top = 12
		access.offset_bottom = 57
		access.add_theme_font_override("font", body_font)
		access.add_theme_font_size_override("font_size", 19)
	var name = jobs_label(hero, Balance.LOCATIONS[location].name, 44 if str(Balance.LOCATIONS[location].name).length() <= 12 else 34, MUTED if locked else PAPER, true, 7)
	name.add_theme_color_override("font_shadow_color", Color("1a0529"))
	name.add_theme_constant_override("shadow_offset_y", 4)
	name.anchor_left = 0
	name.anchor_right = 1
	name.anchor_top = 1
	name.anchor_bottom = 1
	name.offset_left = 20
	name.offset_right = -150
	name.offset_top = -70
	name.offset_bottom = -12
	name.clip_text = true
	name.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

func jobs_card_style(locked: bool) -> StyleBoxFlat:
	var style = panel(Color.TRANSPARENT, 0)
	style.set_content_margin_all(0)
	return style

func jobs_playable_content(content: VBoxContainer, store: SaveStore, location: String) -> void:
	var config: Dictionary = Balance.LOCATIONS[location]
	var final_ready: bool = (location == "apartment" and Progression.final_job_unlocked(store.data) and not store.data.apartment_final_job_completed) or (location == "museum" and Progression.museum_final_job_unlocked(store.data) and not store.data.museum_final_job_completed)
	var final_action := "play_museum_final_job" if location == "museum" else "play_final_job"
	var special_offer: bool = store.data.special_pending and store.data.special_location_id == location
	var totals: Dictionary = Balance.totals(location)
	var capacity: int = Balance.van_capacity(store.data.upgrades.capacity)
	var focus_full_clear: bool = store.data.objectives[location].cash and store.data.objectives[location].signature and not store.data.objectives[location].full_clear
	# Reading order: what to steal, what it pays, PLAY. Stats, loadout and objectives follow.
	var target_info := {} if focus_full_clear else jobs_location_target(store, location)
	if not target_info.is_empty():
		var target_panel = PanelContainer.new()
		target_panel.add_to_group("jobs_target_panel")
		target_panel.add_theme_stylebox_override("panel", jobs_style(Color("4a1a78"), Color("8646d3"), 18, 10, 5))
		content.add_child(target_panel)
		var target_line = row(target_panel, 12)
		var icon_shell = PanelContainer.new()
		icon_shell.add_theme_stylebox_override("panel", jobs_style(Color("331052"), Color("6b3aa8"), 14, 7, 2))
		icon_shell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		target_line.add_child(icon_shell)
		jobs_icon(icon_shell, "res://assets/ui/jobs/icons/" + str(target_info.icon) + ".svg", 50)
		var target_copy = column(target_line, 0)
		target_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		target_copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		jobs_label(target_copy, "NEXT TARGET", 18, Color("c9a6ec"))
		var target_title = jobs_label(target_copy, str(target_info.title), 30 if str(target_info.title).length() <= 18 else 24, PAPER, true, 4)
		target_title.clip_text = true
		var needs_upgrade: bool = target_info.has("upgrade_key")
		jobs_label(target_copy, str(target_info.hint), 20, Color("e39bff") if needs_upgrade else MINT)
		var chevron = jobs_label(target_line, ">", 40, PAPER, true, 3)
		chevron.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if needs_upgrade:
			target_panel.mouse_filter = Control.MOUSE_FILTER_STOP
			target_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			target_panel.tooltip_text = "TAP TO UPGRADE"
			target_panel.gui_input.connect(func(event: InputEvent):
				if (event is InputEventScreenTouch and not event.pressed) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
					shop_selected_key = str(target_info.upgrade_key)
					action_requested.emit("shop"))
	var stats = row(content, 12)
	stats.name = "JobsRewardLine"
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	jobs_stat(stats, "res://assets/hud/cash.png", "$%s" % cash_text(totals.value), "LOOT")
	jobs_stat_divider(stats)
	jobs_stat(stats, "res://assets/hud/box.png", str(config.items.size()), "ITEMS")
	jobs_stat_divider(stats)
	jobs_stat(stats, "res://assets/hud/clock.png", "%ds" % config.duration, "")
	var final_playable: bool = final_ready and capacity >= config.expected_cargo
	var play_callback: Callable = func(): start_requested.emit(location, "normal")
	if final_playable: play_callback = func(): action_requested.emit(final_action)
	var play_row = row(content, 4)
	jobs_block_stage(play_row, 112, 7)
	var play = button(play_row, "PLAY FINAL JOB  ▶" if final_playable else "PLAY  ▶", play_callback, 100)
	play.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	play.add_theme_font_override("font", display_font)
	play.add_theme_font_size_override("font_size", 30 if final_playable else 48)
	play.add_theme_color_override("font_shadow_color", Color("2a0a4a", 0.45))
	play.add_theme_constant_override("shadow_offset_y", 3)
	for state in ["normal", "hover", "pressed"]:
		play.add_theme_stylebox_override(state, jobs_primary_button_style(final_playable, state))
		play.add_theme_color_override("font_color" if state == "normal" else "font_" + state + "_color", PAPER if final_playable else Color("4a1386"))
	jobs_pulse(play)
	jobs_shine(play)
	jobs_block_stage(play_row, 112, 13)
	var secondary = column(content, 6)
	if final_playable:
		jobs_secondary_button(secondary, "PLAY NORMAL", func(): start_requested.emit(location, "normal"))
	if special_offer:
		var special: Dictionary = SpecialJobs.definition(store.data.special_type)
		jobs_secondary_button(secondary, "⚡ %s · %ds · +40%%" % [special.display_name, int(special.time_override)], func(): action_requested.emit("play_special"), HudStyle.MONEY)
	if (location == "apartment" and store.data.apartment_final_job_completed) or (location == "museum" and store.data.museum_final_job_completed):
		jobs_secondary_button(secondary, "REPLAY FINAL JOB", func(): action_requested.emit(final_action), HudStyle.FINAL)
	if Progression.campaign_cleared(store.data) and Balance.CONTRACTS.has(location + ".rush"):
		jobs_secondary_button(secondary, "CONTRACTS", func(): contracts_page(store, location))
	if secondary.get_child_count() == 0: secondary.queue_free()
	jobs_van_capacity(content, capacity, int(totals.cargo))
	jobs_powerup_requirements(content, store, location)
	var objectives_heading = jobs_label(content, "OBJECTIVES", 20, Color("c9a6ec"))
	objectives_heading.custom_minimum_size.y = 24
	var objectives = row(content, 8)
	var signature_name := str(Balance.ITEMS[config.special].display_name).to_upper()
	if signature_name.length() > 12: signature_name = {"vending_machine":"VENDING", "large_statue":"STATUE", "museum_artifact":"DIAMOND", "dracula_coffin":"COFFIN"}.get(config.special, signature_name)
	var short_names = ["$%s" % cash_text(config.threshold), signature_name, "STEAL EVERYTHING"]
	var icon_paths = ["cash", str(config.special), "crown"]
	for i in range(3):
		var done: bool = store.data.objectives[location][Balance.OBJECTIVE_IDS[i]]
		jobs_objective(objectives, str(icon_paths[i]), str(short_names[i]), done, i == 2 and focus_full_clear, capacity, int(totals.cargo), location in ["apartment", "museum"], Progression.powerups_ready(store.data, location))

func jobs_stat(parent: Node, icon_path: String, value: String, caption: String) -> void:
	var cell = row(parent, 7)
	cell.add_to_group("jobs_stat_card")
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon = jobs_icon(cell, icon_path, 36)
	icon.add_to_group("jobs_stat_icon")
	jobs_label(cell, value, 26, HudStyle.MONEY, true, 3)
	if caption != "": jobs_label(cell, caption, 22, HudStyle.MONEY)

func jobs_stat_divider(parent: Node) -> void:
	var divider = jobs_label(parent, "|", 26, Color("8a63ad"))
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func jobs_secondary_button(parent: Node, label: String, callback: Callable, color: Color = PAPER) -> Button:
	var chip = button(parent, label, callback, 60)
	chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chip.add_theme_font_override("font", body_font)
	chip.add_theme_font_size_override("font_size", 25)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: chip.add_theme_color_override(state, color)
	chip.add_theme_stylebox_override("normal", jobs_style(Color("3f1466"), Color("8a44d6"), 16, 8, 4))
	chip.add_theme_stylebox_override("hover", jobs_style(Color("4d1a7c"), Color("a45cf0"), 16, 8, 4))
	chip.add_theme_stylebox_override("pressed", jobs_style(Color("33104f"), Color("8a44d6"), 16, 8, 4))
	var chevron = jobs_label(chip, ">", 30, PAPER, true, 2)
	chevron.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	chevron.offset_left = -40
	chevron.offset_right = -12
	chevron.offset_top = -20
	chevron.offset_bottom = 20
	chevron.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return chip

func jobs_powerup_requirements(parent: VBoxContainer, store: SaveStore, location: String) -> void:
	var block = column(parent, 4)
	var missing := Progression.missing_loadout(store.data, location)
	var done := Balance.UPGRADE_KEYS.size() - missing.size()
	jobs_label(block, "LOADOUT %d/%d · TAP TO UPGRADE" % [done, Balance.UPGRADE_KEYS.size()] if not missing.is_empty() else "LOADOUT COMPLETE · READY TO CLEAR", 16, Color("c9a6ec") if not missing.is_empty() else MINT)
	var short_names := {"grip": "PICKUP", "carry": "CARRY", "capacity": "VAN", "noise": "NOISE", "strength": "STR"}
	var line = row(block, 8)
	# One row keeps the card height stable; the next three missing stats are enough to act on.
	for key in (missing.slice(0, 3) if not missing.is_empty() else ["carry"]):
		var required: int = Balance.required_level(key, location)
		var current: int = store.data.upgrades[key]
		var ready = current >= required
		var label = "%s %d/%d  %s" % [short_names[key],mini(current,required),required,"✓" if ready else "›"]
		if missing.is_empty(): label = "LOADOUT %d/%d  ✓" % [done, Balance.UPGRADE_KEYS.size()]
		var chip = button(line, label, func():
			shop_selected_key = key
			action_requested.emit("shop"), 60)
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.icon = load("res://assets/ui/menu_violet/powerups/%s.png" % key)
		chip.expand_icon = true
		chip.add_theme_constant_override("icon_max_width", 34)
		chip.add_theme_constant_override("h_separation", 6)
		chip.add_theme_font_override("font", body_font)
		chip.add_theme_font_size_override("font_size", 21 if missing.size() < 3 else 18)
		for state in ["font_color", "font_hover_color", "font_pressed_color"]: chip.add_theme_color_override(state, MINT if ready else HudStyle.MONEY)
		chip.add_theme_stylebox_override("normal", jobs_style(Color("3f1466"), Color("8a44d6"), 14, 4, 4))
		chip.add_theme_stylebox_override("hover", jobs_style(Color("4d1a7c"), Color("a45cf0"), 14, 4, 4))
		chip.add_theme_stylebox_override("pressed", jobs_style(Color("33104f"), Color("8a44d6"), 14, 4, 4))
		chip.tooltip_text = "Required to clear %s and advance" % Balance.LOCATIONS[location].name
		chip.add_to_group("jobs_powerup_requirement")
		chip.set_meta("upgrade_key",key)

func jobs_objective(parent: HBoxContainer, icon_name: String, label: String, done: bool, focus: bool = false, capacity: int = 0, required: int = 0, has_final_job: bool = true, powerups_ready: bool = true) -> void:
	var slot = PanelContainer.new()
	slot.add_to_group("jobs_objective_slot")
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.custom_minimum_size.y = 118
	var slot_style = jobs_style(Color("034b42") if done else (Color("4d2a20") if focus else Color("3b1160")), HudStyle.PLAY if done else (HudStyle.FINAL if focus else Color("7a3fc0")), 16, 0, 4)
	slot.add_theme_stylebox_override("panel", slot_style)
	parent.add_child(slot)
	var item = Control.new()
	item.custom_minimum_size.y = 118
	slot.add_child(item)
	var icon = jobs_icon(item, "res://assets/ui/jobs/icons/" + icon_name + ".svg", 54)
	icon.add_to_group("jobs_objective_icon")
	icon.position = Vector2(12, 32)
	var ring = Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring_style = panel(HudStyle.PLAY if done else Color.TRANSPARENT, 14)
	ring_style.set_content_margin_all(0)
	ring_style.border_color = HudStyle.PLAY if done else (HudStyle.FINAL if focus else Color("b9a2d0"))
	ring_style.set_border_width_all(3)
	ring.add_theme_stylebox_override("panel", ring_style)
	ring.anchor_left = 1.0
	ring.anchor_right = 1.0
	ring.offset_left = -38
	ring.offset_right = -10
	ring.offset_top = 10
	ring.offset_bottom = 38
	item.add_child(ring)
	var status = jobs_label(ring, "✓" if done else ("−" if focus else ""), 20, INK if done else HudStyle.FINAL)
	status.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var has_footer: bool = done or focus
	var caption = jobs_label(item, label, 19 if label.length() > 12 else 22, HudStyle.FINAL if focus else (HudStyle.MONEY if label.begins_with("$") else PAPER), false, 2)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.anchor_right = 1.0
	caption.offset_left = 74
	caption.offset_right = -10
	caption.offset_top = 14 if has_footer else 22
	caption.offset_bottom = 88 if has_footer else 96
	if done:
		var claimed = jobs_label(item, "CLAIMED", 16, MINT)
		claimed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		claimed.anchor_right = 1.0
		claimed.offset_top = 92
		claimed.offset_bottom = 116
	elif focus and capacity < required:
		var lock_hint = jobs_label(item, "🔒 VAN: %d/%d" % [capacity, required], 14, HudStyle.FINAL)
		lock_hint.add_to_group("jobs_van_lock_hint")
		lock_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_hint.anchor_right = 1.0
		lock_hint.offset_top = 94
		lock_hint.offset_bottom = 116
	elif focus:
		var ready = jobs_label(item, ("FINAL JOB READY" if has_final_job else "READY TO CLEAR") if powerups_ready else "UPGRADE LOADOUT", 15, HudStyle.FINAL)
		ready.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ready.anchor_right = 1.0
		ready.offset_top = 92
		ready.offset_bottom = 116

func jobs_location_target(store: SaveStore, location: String) -> Dictionary:
	var config: Dictionary = Balance.LOCATIONS[location]
	if not store.data.objectives[location].signature:
		var loot: Dictionary = Balance.ITEMS[config.special]
		if store.data.upgrades.strength < loot.required_strength:
			return {"title": "STEAL THE " + str(loot.display_name), "hint": "STR %d REQUIRED" % loot.required_strength, "icon": str(config.special), "upgrade_key": "strength"}
		return {"title": "STEAL THE " + str(loot.display_name), "hint": "Bring to van", "icon": str(config.special)}
	if not store.data.objectives[location].cash:
		return {"title": "BANK $%s" % cash_text(config.threshold), "hint": "Collect more loot", "icon": "cash"}
	if location == "museum" and not store.data.museum_final_job_completed:
		return {"title": "STEAL TIME MACHINE", "hint": "Final Job", "icon": "time_machine"}
	return {}

func jobs_pulse(control: Control) -> void:
	control.resized.connect(func(): control.pivot_offset = control.size * 0.5)
	var tween = control.create_tween().set_loops()
	tween.tween_property(control, "scale", Vector2(1.012, 1.035), 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func jobs_van_capacity(parent: VBoxContainer, capacity: int, required: int) -> void:
	var block = row(parent, 8)
	block.add_to_group("jobs_capacity_block")
	var short: bool = capacity < required
	jobs_icon(block, "res://assets/ui/menu_violet/powerups/capacity.png", 44)
	jobs_label(block, "VAN SPACE", 21, PAPER, true, 3).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jobs_label(block, "%d / %d" % [capacity, required], 22, HudStyle.FINAL if short else HudStyle.MONEY, true, 3).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jobs_label(block, "CARGO", 21, PAPER, true, 3).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var segments = row(block, 4)
	segments.add_to_group("jobs_capacity_bar")
	segments.set_meta("capacity", capacity)
	segments.set_meta("required", required)
	segments.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segments.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var filled := roundi(8.0 * float(mini(capacity, required)) / float(maxi(required, 1)))
	if capacity > 0 and filled == 0: filled = 1
	for i in range(8):
		var segment = Panel.new()
		segment.custom_minimum_size = Vector2(0, 24)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var segment_style = panel((HudStyle.FINAL if short else HudStyle.MONEY) if i < filled else Color("3a1a55"), 5)
		segment_style.set_content_margin_all(0)
		segment_style.border_color = Color("5a2f80")
		segment_style.set_border_width_all(1)
		segment.add_theme_stylebox_override("panel", segment_style)
		segments.add_child(segment)

func jobs_shine(control: Button) -> void:
	control.clip_contents = true
	var highlight = Polygon2D.new()
	highlight.polygon = PackedVector2Array([Vector2(7, 2), Vector2(35, 2), Vector2(73, 84), Vector2(42, 84)])
	highlight.color = Color(1, 1, 1, 0.19)
	control.add_child(highlight)
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.12)
	flash.custom_minimum_size = Vector2(26, 110)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.rotation = -0.26
	flash.position.x = -60
	control.add_child(flash)
	control.resized.connect(func(): flash.position.y = -12)
	var sweep = flash.create_tween().set_loops()
	sweep.tween_interval(3.2)
	sweep.tween_property(flash, "position:x", 600.0, 0.65).from(-60.0).set_trans(Tween.TRANS_SINE)

func jobs_primary_button_style(final_job: bool, state: String = "normal") -> StyleBoxFlat:
	var base: Color = HudStyle.FINAL if final_job else Color("ffcf19")
	if state == "hover": base = base.lightened(0.08)
	elif state == "pressed": base = base.darkened(0.10)
	var style = jobs_style(base, Color("c2711a") if final_job else Color("e09a00"), 24, 6, 8)
	style.shadow_color = Color("ff951b", 0.35) if final_job else Color("ffcf19", 0.35)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 0)
	return style

func jobs_count_wallet(label: Label, amount: int) -> void:
	if jobs_last_wallet >= 0 and amount > jobs_last_wallet:
		jobs_wallet_tween = create_tween()
		jobs_wallet_tween.tween_method(jobs_wallet_set.bind(label), float(jobs_last_wallet), float(amount), 0.52).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	jobs_last_wallet = amount

func jobs_wallet_set(value: float, label: Label) -> void:
	if is_instance_valid(label): label.text = "$" + cash_text(roundi(value))

func jobs_navigation(frame: VBoxContainer, store: SaveStore) -> void:
	navigation(frame, "locations", 92, store)

func job_shift(store: SaveStore, step: int) -> void:
	job_select(store, jobs_index + step)

func job_select(store: SaveStore, index: int) -> void:
	var count := Balance.LOCATION_ORDER.find("pyramid") + 1 if not store.unlocked("pyramid") else Balance.LOCATION_ORDER.size()
	var selected := clampi(index, 0, count - 1)
	if selected == jobs_index: return
	if jobs_transition != null and jobs_transition.is_valid(): jobs_transition.kill()
	if is_instance_valid(jobs_current_card):
		jobs_current_card.scale = Vector2.ONE
		jobs_current_card.modulate.a = 1.0
		if jobs_current_card.has_meta("rest_position"): jobs_current_card.position = jobs_current_card.get_meta("rest_position")
	var previous_index := jobs_index
	var old_card := jobs_current_card
	var old_rect := Rect2()
	var transition_layer: Control
	if is_instance_valid(old_card):
		old_rect = old_card.get_global_rect()
		transition_layer = Control.new()
		transition_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		transition_layer.clip_contents = true
		transition_layer.z_index = 3
		root.add_child(transition_layer)
		transition_layer.position = old_rect.position - root.global_position
		transition_layer.size = old_rect.size
		old_card.theme = menu.theme
		old_card.reparent(transition_layer, false)
		old_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		old_card.position = Vector2.ZERO
		old_card.size = old_rect.size
		old_card.pivot_offset = old_card.size * 0.5
		old_card.scale = Vector2.ONE
		old_card.modulate.a = 1.0
		motion.ignore_pointer(old_card)
	jobs_index = selected
	locations(store)
	if not is_instance_valid(old_card): return
	transition_layer.add_to_group("jobs_transition_card")
	var direction := 1.0 if selected > previous_index else -1.0
	var fresh := jobs_current_card
	fresh.modulate.a = 0.0
	begin_job_swap.call_deferred(transition_layer, old_card, fresh, selected, direction)

func begin_job_swap(layer, outgoing, incoming, selected: int, direction: float) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(layer) or layer.is_queued_for_deletion() or not is_instance_valid(outgoing) or not is_instance_valid(incoming) or incoming != jobs_current_card or jobs_index != selected:
		if is_instance_valid(layer): layer.queue_free()
		return
	if incoming.size.x < 100.0:
		incoming.modulate.a = 1.0
		layer.queue_free()
		return
	layer.position = incoming.global_position - root.global_position
	layer.size = incoming.size
	outgoing.position = (layer.size - outgoing.size) * 0.5
	var outgoing_x: float = outgoing.position.x
	var incoming_x: float = incoming.position.x
	incoming.set_meta("rest_position", incoming.position)
	outgoing.pivot_offset = outgoing.size * 0.5
	incoming.pivot_offset = incoming.size * 0.5
	incoming.position.x = incoming_x + direction * 12.0
	incoming.scale = Vector2.ONE * 0.96
	incoming.modulate.a = 0.0
	jobs_transition = create_tween().set_parallel(true)
	jobs_transition.tween_property(outgoing, "position:x", outgoing_x - direction * 12.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	jobs_transition.tween_property(outgoing, "scale", Vector2.ONE * 0.96, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	jobs_transition.tween_property(outgoing, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Fade through the card's background: never stack two readable titles/images.
	jobs_transition.chain().tween_callback(layer.hide)
	jobs_transition.chain().tween_property(incoming, "position:x", incoming_x, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	jobs_transition.tween_property(incoming, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	jobs_transition.tween_property(incoming, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jobs_transition.chain().tween_callback(func():
		if is_instance_valid(layer): layer.queue_free()
	)

func jobs_preview_input(event: InputEvent, store: SaveStore) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			jobs_swipe_start = event.position
			jobs_swipe_time = Time.get_ticks_msec() / 1000.0
		else: jobs_finish_swipe(store, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			jobs_swipe_start = event.position
			jobs_swipe_time = Time.get_ticks_msec() / 1000.0
		else: jobs_finish_swipe(store, event.position)

func jobs_finish_swipe(store: SaveStore, end_position: Vector2) -> void:
	var travel := end_position - jobs_swipe_start
	var elapsed := Time.get_ticks_msec() / 1000.0 - jobs_swipe_time
	var minimum := 28.0 if elapsed < 0.25 else 45.0
	if absf(travel.x) < minimum or absf(travel.x) < absf(travel.y) * 1.25: return
	job_shift(store, -1 if travel.x > 0 else 1)

func save_status(body: VBoxContainer, store: SaveStore) -> void:
	if store.notice != "": text(body, store.notice, 18, MUTED)
	if store.last_error != "": text(body, store.last_error, 18, Color("ffac94"))

# Sub-page header: currency pills, a back button where Settings usually sits, then the title.
func back_header(frame: VBoxContainer, store: SaveStore, title: String, subtitle: String) -> void:
	var settings = currency_header(frame, store)
	settings.pressed.disconnect(settings.pressed.get_connections()[0].callable)
	settings.pressed.connect(func(): action_requested.emit("home"))
	settings.tooltip_text = "BACK"
	settings.get_child(0).queue_free()
	var back_glyph = jobs_label(settings, "<", 34, PAPER, true, 3)
	back_glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var heading = column(frame, 0)
	jobs_label(heading, title, 42, PAPER, true, 6)
	jobs_label(heading, subtitle, 18, Color("c9a6ec"))

func shop_page(store: SaveStore) -> void:
	var frame = base_menu()
	frame.add_theme_constant_override("separation", 8)
	back_header(frame, store, "UPGRADES", "MAKE YOUR ROBBER STRONGER")
	shop_next_target(frame, store)
	var body = scroll_body(frame)
	body.add_theme_constant_override("separation", 10)
	shop_scroll = body.get_parent() as ScrollContainer
	shop(body,store)
	if store.last_error != "": jobs_label(body, store.last_error, 16, Color("ffac94"))
	navigation(frame,"shop",53,store)

func shop_next_target(frame: VBoxContainer, store: SaveStore) -> void:
	var target_info: Dictionary = Progression.next_result_target(store.data)
	var hint: String = str(target_info.hint)
	var focus := str(target_info.get("upgrade_key", "strength" if hint.contains("Strength") else ("capacity" if hint.contains("van") else "")))
	var target_panel = PanelContainer.new()
	target_panel.name = "ShopTargetPanel"
	target_panel.add_theme_stylebox_override("panel", jobs_style(Color("4a1a78"), Color("8646d3"), 18, 10, 5))
	frame.add_child(target_panel)
	var line = row(target_panel, 12)
	var type_id: String = str(target_info.type_id)
	var icon_shell = PanelContainer.new()
	icon_shell.add_theme_stylebox_override("panel", jobs_style(Color("331052"), Color("6b3aa8"), 14, 6, 2))
	icon_shell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(icon_shell)
	var icon_path := "res://assets/ui/jobs/icons/%s.svg" % type_id
	if not ResourceLoader.exists(icon_path): icon_path = "res://assets/ui/jobs/icons/cash.svg"
	if focus in ["grip","carry","capacity","noise"] and type_id == "": icon_path = "res://assets/ui/menu_violet/powerups/%s.png" % focus
	jobs_icon(icon_shell, icon_path, 48)
	var copy = column(line, 0)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jobs_label(copy, "NEXT TARGET", 16, Color("c9a6ec"))
	var target_title = jobs_label(copy, str(target_info.title), 26 if str(target_info.title).length() <= 18 else 21, PAPER, true, 4)
	target_title.clip_text = true
	var need = jobs_label(copy, hint.to_upper(), 16, Color("b9a2ff"))
	need.clip_text = true
	var go = button(line, "GO ›", func():
		if focus != "": shop_select(focus, true)
		else: action_requested.emit("locations")
	, 64)
	go.custom_minimum_size.x = 118
	go.size_flags_horizontal = Control.SIZE_SHRINK_END
	go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	go.add_theme_font_override("font", body_font)
	go.add_theme_font_size_override("font_size", 26)
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: go.add_theme_color_override(state, PAPER)
	go.add_theme_stylebox_override("normal", jobs_style(Color("8b3cf0"), Color("c48bff"), 16, 4, 5))
	go.add_theme_stylebox_override("hover", jobs_style(Color("9d4dff"), Color("d6a8ff"), 16, 4, 5))
	go.add_theme_stylebox_override("pressed", jobs_style(Color("6f2ac4"), Color("c48bff"), 16, 4, 5))

func contracts_page(store: SaveStore, location: String) -> void:
	if not Progression.campaign_cleared(store.data) or not Balance.CONTRACTS.has(location + ".rush"): return
	var frame = base_menu()
	menu_header(frame, "MASTERY CONTRACTS", store.data.wallet, Balance.LOCATIONS[location].name,store.data.diamonds)
	var body = scroll_body(frame)
	text(body, "Special rules. Bigger challenges. Escape to keep your loot, even if you miss the target.", 21, MUTED)
	for mode in ["rush", "small_van", "client_order"]:
		var id = location + "." + mode
		var config: Dictionary = Balance.CONTRACTS[id]
		var c = card(body, Color("301245") if store.data.contracts[id] else Color("420a69"))
		var title_row = row(c, 12)
		HudStyle.icon(title_row, {"rush":"clock", "small_van":"box", "client_order":"hand"}[mode], 46)
		var title = headline(title_row, config.name, 29)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if store.data.contracts[id]:
			var medal = text(title_row, "✓ COMPLETE", 18, MINT)
			medal.autowrap_mode = TextServer.AUTOWRAP_OFF
		text(c, Balance.contract_description(id), 20)
		text(c, "YOUR CAPACITY: %d · FIRST WIN BONUS: $%d%s" % [Balance.session(location, mode, store.data.upgrades).capacity, config.bonus, " (CLAIMED)" if id in store.data.contract_bonuses else ""], 18, MUTED)
		if store.data.records[mode].has(location): text(c, "BEST %.1fs" % store.data.records[mode][location], 19, MINT)
		button(c, "START " + config.name + " →", func(): start_requested.emit(location, mode), 80)
	navigation(frame, "locations", 96, store)

func daily_wheel_page(store: SaveStore) -> void:
	var frame = base_menu()
	frame.add_theme_constant_override("separation", 0)
	var top = row(frame, 8)
	var back = blue_button(top, "‹", func(): action_requested.emit("home"), 52)
	back.custom_minimum_size.x = 58
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.tooltip_text = "Home"
	var info = blue_button(top, "i", func(): wheel_info(store), 52)
	info.custom_minimum_size.x = 52
	info.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	info.tooltip_text = "Rewards and chances"
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	wallet_chip(top, store.data.wallet, store.data.diamonds)
	wheel_balance = menu_diamond_label
	var art = LuckyWheelArt.new()
	art.name = "LuckyWheelArt"
	frame.add_child(art)
	art.setup(store.data, heavy_font, func(): action_requested.emit("daily_spin"))
	wheel_disc = art.disc
	wheel_result = art.result
	wheel_spin_button = art.spin
	wheel_reset = art.reset
	refresh_daily_wheel(store)

func wheel_info(store: SaveStore) -> void:
	var overlay = ColorRect.new()
	overlay.name = "WheelOdds"
	overlay.color = Color(0.0572, 0.0100, 0.0900, 0.94)
	menu.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var safe = margin(overlay, 30)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	apply_page_margins(safe)
	var center = CenterContainer.new()
	safe.add_child(center)
	var body = column(center, 10)
	body.custom_minimum_size.x = minf(590, root.size.x - 80)
	headline(body, "WHEEL REWARDS", 32, PAPER, true)
	var unit = DailyWheel.cash_unit(store.data)
	for prize in DailyWheel.PRIZES:
		var value = "$%d CASH" % (unit * int(prize.scale)) if prize.kind == "cash" else ("%d DIAMONDS" % prize.amount if prize.kind == "diamonds" else ("CHARACTER TICKET" if prize.ticket == "character" else "VAN TICKET"))
		var line = text(body, "%s  ·  %d%%" % [value, prize.weight], 23, HudStyle.MONEY if prize.kind == "cash" else HudStyle.INFO)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text(body, "Sectors are illustrated; chances are listed above. The two medium-cash sectors share 22%.", 19, MUTED)
	text(body, "Skin tickets are PROTOTYPE rewards: +10 diamonds now, +20 for a duplicate ticket. Skins are not available yet.", 19, MUTED)
	text(body, "One free spin each UTC day. No paid spins. Cash scales with unlocked locations.", 19, MUTED)
	if not store.data.wheel_jackpots.is_empty(): text(body, "YOUR TICKETS: " + ", ".join(store.data.wheel_jackpots).to_upper(), 19, HudStyle.RARE)
	blue_button(body, "GOT IT", func(): overlay.queue_free(), 62)
	UiJuice.modal_enter(overlay, body)

func refresh_daily_wheel(store: SaveStore) -> void:
	if not is_instance_valid(wheel_spin_button) or wheel_busy: return
	if is_instance_valid(menu_wallet_label): menu_wallet_label.text = "$" + cash_text(store.data.wallet)
	wheel_balance.text = str(store.data.diamonds)
	var now := int(Time.get_unix_time_from_system())
	var available := store.daily_spin_available(now)
	wheel_spin_button.disabled = not available
	wheel_spin_button.tooltip_text = "Spin for rewards" if available else "Free spin used today"
	if available:
		wheel_reset.text = "FREE SPINS · DEV" if store.dev_rewards_unlimited else "1 FREE SPIN"
	else:
		var remaining := DailyWheel.next_reset_seconds(now)
		wheel_reset.text = "NEXT SPIN · %02dh %02dm" % [remaining / 3600, (remaining % 3600) / 60]

func animate_daily_spin(prize: Dictionary, store: SaveStore) -> void:
	if not is_instance_valid(wheel_disc): return
	wheel_busy = true
	wheel_spin_button.disabled = true
	wheel_result.text = "SPINNING..."
	wheel_reset.text = "GOOD LUCK!"
	var target := DailyWheelView.target_rotation(int(prize.index), randi())
	var distance := fposmod(target - fposmod(wheel_disc.rotation, TAU), TAU)
	var disc := wheel_disc
	var tween := disc.create_tween()
	tween.tween_property(disc, "rotation", disc.rotation + TAU * 5.0 + distance, 3.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		if not is_instance_valid(disc) or wheel_disc != disc: return
		wheel_busy = false
		wheel_result.text = DailyWheel.caption(prize)
		if prize.kind == "jackpot":
			wheel_result.text = ("VAN" if prize.ticket == "van" else "SKIN") + " TICKET! +%d GEMS" % int(prize.amount)
		wheel_result.add_theme_font_size_override("font_size", 29 if prize.kind == "jackpot" else 35)
		wheel_result.add_theme_color_override("font_color", HudStyle.RARE if prize.kind == "jackpot" else (HudStyle.INFO if prize.kind == "diamonds" else HudStyle.MONEY))
		UiJuice.pulse(wheel_result, 1.10, 0.25)
		refresh_daily_wheel(store)
		wheel_reward_revealed.emit(prize)
	)

func lucky_shop_page(store: SaveStore) -> void:
	var frame = base_menu()
	menu_header(frame, "LUCKY SHOP", store.data.wallet, "Permanent rewards for Lucky Tokens", store.data.diamonds)
	lucky_meter_panel(frame, store, true)
	lucky_shop_list = scroll_body(frame)
	refresh_lucky_shop(store)
	navigation(frame, "home", 68, store)

func refresh_lucky_shop(store: SaveStore) -> void:
	if not is_instance_valid(lucky_shop_list): return
	for child in lucky_shop_list.get_children():
		lucky_shop_list.remove_child(child)
		child.queue_free()
	text(lucky_shop_list, "Every Lucky Block pays tokens. Unlucky twists pay double.", 16, MUTED)
	var groups := {"block_skin": "BLOCK SKINS", "load_vfx": "LOAD EFFECTS", "cash_vfx": "CASH EFFECTS", "escape_vfx": "ESCAPE EFFECTS", "cosmetic": "LOOKS", "upgrade_token": "BOOSTS", "diamonds": "BOOSTS"}
	var shown := {}
	for id in LuckyShop.CATALOG:
		var kind: String = str(LuckyShop.CATALOG[id].kind)
		if not shown.has(groups[kind]):
			shown[groups[kind]] = true
			text(lucky_shop_list, groups[kind], 20, HudStyle.SPECIAL)
		lucky_shop_card(lucky_shop_list, store, id)
	if store.last_error != "": text(lucky_shop_list, store.last_error, 18, Color("ffac94"))

func lucky_shop_card(parent: VBoxContainer, store: SaveStore, id: String) -> void:
	var entry: Dictionary = LuckyShop.CATALOG[id]
	var kind: String = str(entry.kind)
	var owned := LuckyShop.owned(store.data, id)
	var equipped := kind in LuckyShop.SLOTS and LuckyShop.equipped(store.data, kind) == id
	var c = card(parent, Color("3b1059") if equipped else Color("321049"))
	c.name = "LuckyShopCard_" + id
	var line = row(c)
	var swatch = ColorRect.new()
	swatch.color = Color(str(entry.get("color", Balance.COSMETICS.get(str(entry.get("cosmetic", "")), {}).get("color", "b578ff"))))
	swatch.custom_minimum_size = Vector2(12, 66)
	line.add_child(swatch)
	var info = column(line, 3)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	headline(info, str(entry.name), 22)
	text(info, str(entry.description), 15, MUTED)
	var status := ""
	if kind == "upgrade_token" and int(store.data.upgrade_tokens) > 0: status = "YOU HAVE %d" % int(store.data.upgrade_tokens)
	elif equipped: status = "EQUIPPED"
	elif owned: status = "OWNED · IN WARDROBE" if kind == "cosmetic" else "OWNED"
	if status != "": text(info, status, 15, MINT)
	var repeatable: bool = entry.get("repeatable", false)
	var label := "✦ %d" % int(entry.price)
	var action := "lucky_buy:" + id
	if owned and not repeatable:
		if kind in LuckyShop.SLOTS:
			label = "UNEQUIP" if equipped else "EQUIP"
			action = "lucky_equip:" + id
		else:
			label = "WARDROBE"
			action = "cosmetics"
	var b = button(line, label, func(): action_requested.emit(action), 56)
	b.name = "LuckyBuy_" + id
	b.size_flags_horizontal = Control.SIZE_SHRINK_END
	b.custom_minimum_size.x = 110
	b.add_theme_font_size_override("font_size", 18)
	b.disabled = (not owned or repeatable) and not LuckyShop.can_buy(store.data, id)

func cosmetics_page(store: SaveStore) -> void:
	var frame = base_menu()
	frame.add_theme_constant_override("separation", 8)
	back_header(frame, store, "LOCKER", "YOUR THIEF. YOUR GETAWAY. YOUR STYLE.")
	cosmetics_list = scroll_body(frame)
	cosmetics_list.add_theme_constant_override("separation", 12)
	locker_scroll = cosmetics_list.get_parent() as ScrollContainer
	locker_build(store)
	navigation(frame, "cosmetics", 68, store)

func refresh_cosmetics(store: SaveStore) -> void:
	if not is_instance_valid(cosmetics_list): return
	if is_instance_valid(menu_wallet_label): menu_wallet_label.text = "$" + cash_text(store.data.wallet)
	if is_instance_valid(menu_diamond_label): menu_diamond_label.text = str(store.data.diamonds)
	var scroll_position: int = locker_scroll.scroll_vertical if is_instance_valid(locker_scroll) else 0
	for child in cosmetics_list.get_children():
		cosmetics_list.remove_child(child)
		child.queue_free()
	locker_build(store)
	if is_instance_valid(locker_scroll):
		var target := locker_scroll
		(func(): if is_instance_valid(target): target.scroll_vertical = scroll_position).call_deferred()

func locker_build(store: SaveStore) -> void:
	locker_shop_panel(cosmetics_list, store)
	locker_equipped_row(cosmetics_list, store)
	locker_divider(cosmetics_list, "COLLECTION")
	locker_tabs(cosmetics_list, store)
	locker_grid(cosmetics_list, store)
	if store.last_error != "": jobs_label(cosmetics_list, store.last_error, 18, Color("ffac94"))

# Cards take their frame, glow and button colour from the look's rarity.
func locker_card_style(rarity: String, glow: bool = true) -> StyleBoxFlat:
	var color: Color = LockerCollection.RARITY_COLORS[rarity]
	var style = jobs_style(Color("22083a").lerp(color, 0.16), color, 18, 8, 4)
	style.set_border_width_all(2)
	style.border_width_bottom = 4
	if glow:
		style.shadow_color = Color(color, 0.32)
		style.shadow_size = 8
		style.shadow_offset = Vector2.ZERO
	return style

func locker_rarity_badge(parent: Node, rarity: String, size: int = 12) -> PanelContainer:
	var color: Color = LockerCollection.RARITY_COLORS[rarity]
	var badge = PanelContainer.new()
	badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var badge_style = panel(color.darkened(0.6), 10)
	badge_style.set_content_margin_all(2)
	badge_style.content_margin_left = 10
	badge_style.content_margin_right = 10
	badge_style.border_color = color
	badge_style.set_border_width_all(1)
	badge.add_theme_stylebox_override("panel", badge_style)
	parent.add_child(badge)
	jobs_label(badge, rarity, size, color.lightened(0.35))
	return badge

func locker_tint_button(action: Button, rarity: String) -> void:
	var color: Color = LockerCollection.RARITY_COLORS[rarity]
	var ink: Color = Color("14202a") if LockerCollection.RARITY_DARK_TEXT[rarity] else PAPER
	for state in ["font_color", "font_hover_color", "font_pressed_color"]: action.add_theme_color_override(state, ink)
	action.add_theme_stylebox_override("normal", jobs_style(color.darkened(0.12), color.lightened(0.35), 16, 4, 5))
	action.add_theme_stylebox_override("hover", jobs_style(color, color.lightened(0.45), 16, 4, 5))
	action.add_theme_stylebox_override("pressed", jobs_style(color.darkened(0.3), color, 16, 4, 5))
	action.add_theme_stylebox_override("disabled", jobs_style(Color("3c204f"), Color("5a3a73"), 16, 4, 5))

func locker_divider(parent: VBoxContainer, title: String) -> void:
	var line = row(parent, 12)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	for side in range(2):
		var rule = ColorRect.new()
		rule.color = Color("6b3aa8")
		rule.custom_minimum_size = Vector2(0, 3)
		rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if side == 1: jobs_label(line, title, 24, Color("d9b8f5"), true, 3)
		line.add_child(rule)

func locker_countdown_text() -> String:
	var remaining := PlayRewards.shop_refresh_remaining()
	return "New looks in %dh %02dm" % [remaining / 3600, (remaining % 3600) / 60]

func locker_shop_panel(parent: VBoxContainer, store: SaveStore) -> void:
	var shell = PanelContainer.new()
	shell.name = "TodayShopPanel"
	shell.add_theme_stylebox_override("panel", jobs_style(Color("2d0b47"), Color("8a44d6"), 22, 12, 5))
	parent.add_child(shell)
	var body = column(shell, 10)
	var head = row(body, 10)
	jobs_label(head, "TODAY'S SHOP", 30, HudStyle.MONEY, true, 4).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jobs_icon(head, "res://assets/hud/clock.png", 26)
	var countdown = jobs_label(head, locker_countdown_text(), 17, Color("d9b8f5"))
	countdown.name = "ShopCountdown"
	countdown.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	countdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	countdown.clip_text = true
	var ticker = Timer.new()
	ticker.wait_time = 1.0
	ticker.autostart = true
	ticker.timeout.connect(func(): if is_instance_valid(countdown): countdown.text = locker_countdown_text())
	countdown.add_child(ticker)
	var rotates = PanelContainer.new()
	rotates.add_theme_stylebox_override("panel", jobs_style(Color("3f1466"), Color("8a44d6"), 14, 4, 3))
	rotates.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(rotates)
	var rotate_line = row(rotates, 6)
	jobs_label(rotate_line, "⟳", 18, Color("d9b8f5"))
	jobs_label(rotate_line, "ROTATES DAILY", 15, Color("d9b8f5"))
	var offers = row(body, 8)
	for id in PlayRewards.today_shop(): locker_offer_card(offers, store, id)

func locker_offer_card(parent: HBoxContainer, store: SaveStore, id: String) -> void:
	var config: Dictionary = Balance.COSMETICS[id]
	var owned: bool = id in store.data.cosmetics.owned
	var wearing := LockerCollection.equipped(id, store.data)
	var rarity := LockerCollection.rarity(id)
	var card_shell = PanelContainer.new()
	card_shell.name = "TodayShopCard_" + id
	card_shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_shell.add_theme_stylebox_override("panel", locker_card_style(rarity))
	parent.add_child(card_shell)
	var body = column(card_shell, 4)
	var name = jobs_label(body, str(config.name), 18, PAPER, true, 3)
	name.clip_text = true
	jobs_label(body, LockerCollection.kind_label(id), 13, Color("c9a6ec")).clip_text = true
	locker_rarity_badge(body, rarity)
	locker_preview(body, store, id, 118)
	var price_line = row(body, 6)
	price_line.alignment = BoxContainer.ALIGNMENT_CENTER
	var gem_price := int(config.get("gem_price", 0))
	if wearing: jobs_label(price_line, "EQUIPPED", 18, MINT, true, 2)
	elif owned: jobs_label(price_line, "OWNED", 18, MINT, true, 2)
	elif gem_price > 0:
		jobs_icon(price_line, "res://assets/ui/diamond.png", 26)
		jobs_label(price_line, str(gem_price), 20, Color("8fd6ff"), true, 2)
	else:
		jobs_icon(price_line, "res://assets/hud/cash.png", 28)
		jobs_label(price_line, "$" + cash_text(int(config.price)), 20, HudStyle.MONEY, true, 2)
	var is_vehicle: bool = config.has("vehicle_style")
	var label := "VIEW" if is_vehicle else ("EQUIPPED" if wearing else ("EQUIP" if owned else "BUY"))
	var action = button(body, label, func():
		if is_vehicle: action_requested.emit("vehicle_preview:" + id)
		else: cosmetic_requested.emit(id, "equip" if owned else "buy")
	, 52)
	action.add_theme_font_override("font", body_font)
	action.add_theme_font_size_override("font_size", 22)
	var buy_now: bool = label == "BUY"
	if buy_now:
		for state in ["font_color", "font_hover_color", "font_pressed_color"]: action.add_theme_color_override(state, Color("2a0a4a"))
		action.add_theme_stylebox_override("normal", jobs_style(HudStyle.MONEY, Color("ffe680"), 16, 4, 5))
		action.add_theme_stylebox_override("hover", jobs_style(HudStyle.MONEY.lightened(0.1), Color("ffe680"), 16, 4, 5))
		action.add_theme_stylebox_override("pressed", jobs_style(HudStyle.MONEY.darkened(0.15), Color("ffe680"), 16, 4, 5))
		action.add_theme_stylebox_override("disabled", jobs_style(Color("3c204f"), Color("5a3a73"), 16, 4, 5))
	else: locker_tint_button(action, rarity)
	action.disabled = (wearing and not is_vehicle) or (buy_now and (store.data.diamonds < gem_price if gem_price > 0 else store.data.wallet < int(config.price)))

# A live look: the van shell for vehicles, the thief wearing the suit or set otherwise.
func locker_preview(parent: Node, store: SaveStore, id: String, height: float) -> Control:
	var config: Dictionary = Balance.COSMETICS.get(id, {})
	if str(config.get("slot", "")) == "van" or id == LockerCollection.ORIGINAL_VAN or (id == "" and locker_tab == "vehicles"):
		var preview := VehiclePreview.new()
		preview.custom_minimum_size = Vector2(0, height)
		preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		parent.add_child(preview)
		preview.setup(str(config.get("vehicle_style", "")), int(store.data.upgrades.capacity))
		preview.suspend(not menu_previews_active)
		if not config.has("vehicle_style") and id in Balance.COSMETICS:
			Models.tint_palette(preview.van.model, [Color("ffbd59"), Color("ffe1a4")], Color(str(config.color)))
		return preview
	var thief = add_preview(parent, store, "collection", height)
	thief.show_van(false)
	if id != "": thief.preview_cosmetic(id)
	return thief

func locker_equipped_row(parent: VBoxContainer, store: SaveStore) -> void:
	var line = row(parent, 10)
	for tab in ["skins", "vehicles"]:
		var worn := LockerCollection.worn(tab, store.data)
		var rarity := LockerCollection.rarity(worn)
		var shell = PanelContainer.new()
		shell.name = "EquippedSkinPanel" if tab == "skins" else "EquippedVehiclePanel"
		shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var shell_style = locker_card_style(rarity)
		shell_style.set_corner_radius_all(22)
		shell_style.set_content_margin_all(12)
		shell.add_theme_stylebox_override("panel", shell_style)
		line.add_child(shell)
		var body = column(shell, 6)
		jobs_label(body, "THIEF SKIN" if tab == "skins" else "GETAWAY VEHICLE", 15, Color("c9a6ec"))
		var name_line = row(body, 8)
		var name = jobs_label(name_line, LockerCollection.display_name(worn), 24 if LockerCollection.display_name(worn).length() <= 12 else 19, PAPER, true, 3)
		name.clip_text = true
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		locker_rarity_badge(name_line, rarity)
		var badge = PanelContainer.new()
		badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		badge.add_theme_stylebox_override("panel", jobs_style(Color("2a0a4a"), HudStyle.MONEY, 12, 3, 2))
		body.add_child(badge)
		var badge_text = jobs_label(badge, "EQUIPPED", 14, HudStyle.MONEY)
		badge_text.name = "EquippedBadge"
		var preview = locker_preview(body, store, worn if worn in Balance.COSMETICS else (LockerCollection.ORIGINAL_VAN if tab == "vehicles" else ""), 200)
		if tab == "skins" and preview is MenuCharacterPreview: preview.name = "EquippedThiefPreview"
		var customize = button(body, "CUSTOMIZE", func():
			locker_tab = tab
			refresh_cosmetics(store)
			locker_focus_collection.call_deferred()
		, 56)
		customize.name = "CustomizeSkins" if tab == "skins" else "CustomizeVehicles"
		customize.icon = MenuArt.texture("cosmetics") if tab == "skins" else load("res://assets/ui/menu_violet/powerups/capacity.png")
		customize.expand_icon = true
		customize.add_theme_constant_override("icon_max_width", 30)
		customize.add_theme_constant_override("h_separation", 8)
		customize.alignment = HORIZONTAL_ALIGNMENT_CENTER
		customize.add_theme_font_override("font", body_font)
		customize.add_theme_font_size_override("font_size", 22)
		locker_tint_button(customize, rarity)

func locker_focus_collection() -> void:
	await get_tree().process_frame
	if is_instance_valid(locker_scroll) and is_instance_valid(locker_grid_anchor):
		locker_scroll.ensure_control_visible(locker_grid_anchor)

func locker_tabs(parent: VBoxContainer, store: SaveStore) -> void:
	var line = row(parent, 8)
	line.name = "LockerTabs"
	locker_grid_anchor = line
	for entry in [["THIEF SKINS", "skins", MenuArt.texture("cosmetics")], ["VEHICLES", "vehicles", load("res://assets/ui/menu_violet/powerups/capacity.png")]]:
		var active: bool = locker_tab == entry[1]
		var tab = button(line, entry[0], func():
			locker_tab = entry[1]
			refresh_cosmetics(store)
		, 60)
		tab.name = "LockerTab_" + entry[1]
		tab.icon = entry[2]
		tab.expand_icon = true
		tab.add_theme_constant_override("icon_max_width", 34)
		tab.add_theme_constant_override("h_separation", 8)
		tab.alignment = HORIZONTAL_ALIGNMENT_CENTER
		tab.add_theme_font_override("font", body_font)
		tab.add_theme_font_size_override("font_size", 22)
		for state in ["font_color", "font_hover_color", "font_pressed_color"]: tab.add_theme_color_override(state, PAPER)
		var style = jobs_style(Color("6b2bb4") if active else Color("3a1160"), HudStyle.MONEY if active else Color("6b3aa8"), 16, 4, 5)
		tab.add_theme_stylebox_override("normal", style)
		tab.add_theme_stylebox_override("hover", style)
		tab.add_theme_stylebox_override("pressed", style)

func locker_grid(parent: VBoxContainer, store: SaveStore) -> void:
	var grid = GridContainer.new()
	grid.name = "LockerGrid"
	grid.columns = 3 if menu.size.x < 600.0 else 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(grid)
	var today := PlayRewards.today_shop()
	var slots := LockerCollection.slots(locker_tab)
	for index in range(slots.size()):
		var id: String = slots[index]
		var owned: bool = id != "" and LockerCollection.owned(id, store.data)
		var wearing: bool = owned and LockerCollection.equipped(id, store.data)
		var slot = PanelContainer.new()
		slot.name = "LockerSlot_%d" % (index + 1)
		slot.add_to_group("locker_slot")
		slot.set_meta("cosmetic_id", id)
		slot.set_meta("owned", owned)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.custom_minimum_size.y = 214
		if owned:
			var slot_style = locker_card_style(LockerCollection.rarity(id), wearing)
			if wearing: slot_style.set_border_width_all(3)
			slot.add_theme_stylebox_override("panel", slot_style)
		else: slot.add_theme_stylebox_override("panel", jobs_style(Color("22083a"), Color("4d2a6e"), 18, 8, 4))
		grid.add_child(slot)
		var body = column(slot, 4)
		body.alignment = BoxContainer.ALIGNMENT_CENTER
		if not owned:
			var mystery = PanelContainer.new()
			mystery.add_theme_stylebox_override("panel", jobs_style(Color("1a0630"), Color("4d2a6e"), 14, 0, 2))
			mystery.custom_minimum_size = Vector2(0, 108)
			body.add_child(mystery)
			var mark = jobs_label(mystery, "?", 60, Color("8f6bb8"), true)
			mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var hint = jobs_label(body, "IN TODAY'S SHOP" if id in today else "LOCKED", 13, HudStyle.MONEY if id in today else Color("8f6bb8"))
			hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hint.clip_text = true
			continue
		var art_shell = PanelContainer.new()
		art_shell.add_theme_stylebox_override("panel", jobs_style(Color("3a1160"), Color("6b3aa8"), 14, 0, 2))
		art_shell.custom_minimum_size = Vector2(0, 108)
		body.add_child(art_shell)
		var art_stage = Control.new()
		art_stage.custom_minimum_size = Vector2(0, 108)
		art_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art_shell.add_child(art_stage)
		var art = jobs_icon(art_stage, "res://assets/ui/menu_violet/cosmetics.png" if locker_tab == "skins" else "res://assets/ui/menu_violet/powerups/capacity.png", 84)
		art.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		art.offset_left = -42
		art.offset_right = 42
		art.offset_top = -42
		art.offset_bottom = 42
		art.modulate = LockerCollection.tint(id) if id in Balance.COSMETICS else Color.WHITE
		if wearing:
			var tick_plate = panel(HudStyle.MONEY, 13)
			tick_plate.set_content_margin_all(0)
			var tick_bg = Panel.new()
			tick_bg.add_theme_stylebox_override("panel", tick_plate)
			tick_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			art_stage.add_child(tick_bg)
			tick_bg.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			tick_bg.offset_left = -32
			tick_bg.offset_right = -6
			tick_bg.offset_top = 6
			tick_bg.offset_bottom = 32
			var tick = jobs_label(tick_bg, "✓", 20, Color("2a0a4a"))
			tick.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var name = jobs_label(body, LockerCollection.display_name(id), 14, PAPER, false, 2)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name.clip_text = true
		var rarity := LockerCollection.rarity(id)
		locker_rarity_badge(body, rarity, 11).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var equip = button(body, "EQUIPPED" if wearing else "EQUIP", func():
			if id == LockerCollection.ORIGINAL_SUIT: cosmetic_requested.emit("", "reset_suit")
			elif id == LockerCollection.ORIGINAL_VAN: cosmetic_requested.emit("", "reset_van")
			else: cosmetic_requested.emit(id, "equip")
		, 42)
		equip.disabled = wearing
		equip.add_theme_font_override("font", body_font)
		equip.add_theme_font_size_override("font_size", 17)
		for state in ["font_color", "font_hover_color", "font_pressed_color"]: equip.add_theme_color_override(state, Color("2a0a4a") if wearing else PAPER)
		equip.add_theme_color_override("font_disabled_color", Color("2a0a4a"))
		locker_tint_button(equip, rarity)
		equip.add_theme_stylebox_override("disabled", jobs_style(HudStyle.MONEY, Color("ffe680"), 12, 2, 4))

func garage_page(store: SaveStore) -> void:
	if garage_selected not in GarageDecor.CATALOG: garage_selected = ""
	var frame = base_menu()
	garage_wallet = menu_header(frame,"YOUR GARAGE",store.data.wallet,"MAKE YOUR GETAWAY FEEL LIKE HOME",store.data.diamonds)
	garage_live_preview = add_preview(frame,store,"garage",400)
	garage_live_preview.name = "GarageDiorama"
	garage_title = headline(frame,"",27,HudStyle.GOLD,true)
	garage_description = text(frame,"",19,MUTED)
	garage_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	garage_buy = button(frame,"",func(): action_requested.emit("garage_buy:" + garage_selected),72)
	garage_buy.name = "GarageBuy"
	text(frame,"DECOR ONLY · Yours to keep · No stat bonuses",17,HudStyle.CYAN)
	var list = scroll_body(frame)
	list.custom_minimum_size.y = 180
	for id in GarageDecor.CATALOG:
		var config: Dictionary = GarageDecor.CATALOG[id]
		var owned: bool = id in store.data.garage_owned
		var entry := blue_button(list,config.name + ("  ✓ OWNED" if owned else "  ·  $" + cash_text(config.price)),func():
			garage_selected = id
			refresh_garage_selection(store)
		,58)
		entry.name = "GarageOffer_" + id
		entry.add_theme_font_size_override("font_size",22)
	refresh_garage_selection(store)
	blue_button(frame,"TROPHIES & RARE LOOT",func(): action_requested.emit("trophies"),48)
	navigation(frame,"garage",68,store)

func refresh_garage_selection(store: SaveStore) -> void:
	if garage_selected not in GarageDecor.CATALOG:
		garage_live_preview.preview_furniture("")
		garage_title.text = "YOUR SPACE · %d / 8" % store.data.garage_owned.size()
		garage_description.text = "Choose a piece below to see it in your garage."
		garage_buy.text = "SELECT DECOR TO PREVIEW"
		garage_buy.disabled = true
		return
	var config: Dictionary = GarageDecor.CATALOG[garage_selected]
	var owned: bool = garage_selected in store.data.garage_owned
	garage_live_preview.preview_furniture(garage_selected)
	garage_title.text = config.name.to_upper() + (" · IN YOUR GARAGE" if owned else " · PREVIEW")
	garage_description.text = config.description
	garage_buy.text = "OWNED · IN YOUR GARAGE" if owned else "BUY & PLACE · $" + cash_text(config.price)
	garage_buy.disabled = owned or store.read_only or store.data.wallet < int(config.price)
	if not owned and store.data.wallet < int(config.price): garage_description.text = "$%s more to make it yours" % cash_text(int(config.price)-int(store.data.wallet))
	if store.last_error != "": garage_description.text = store.last_error

func vehicle_page(store: SaveStore) -> void:
	if selected_vehicle not in Balance.VEHICLE_ORDER: selected_vehicle = Balance.VEHICLE_ORDER[0]
	var config: Dictionary = Balance.COSMETICS[selected_vehicle]
	var frame = base_menu()
	vehicle_wallet = menu_header(frame,"GETAWAY VEHICLE",store.data.wallet,"COSMETICS · TODAY'S SHOP",store.data.diamonds)
	var hero := VehiclePreview.new()
	hero.custom_minimum_size.y = 330
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(hero)
	hero.setup(str(config.vehicle_style), int(store.data.upgrades.capacity), true)
	hero.suspend(not menu_previews_active)
	headline(frame,config.name,34,PAPER,true)
	var description = text(frame,config.description,21,MUTED)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rule = text(frame,"COSMETIC ONLY · Your Van Space upgrade sets capacity",18,HudStyle.CYAN)
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_status = text(frame,"",21,HudStyle.GOLD)
	vehicle_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_buy = button(frame,"",func():
		cosmetic_requested.emit(selected_vehicle,"equip" if selected_vehicle in store.data.cosmetics.owned else "buy")
	,88)
	vehicle_buy.name = "VehicleBuy"
	blue_button(frame,"BACK TO COSMETICS",func(): action_requested.emit("cosmetics"),68)
	refresh_vehicle(store)

func refresh_vehicle(store: SaveStore) -> void:
	if not is_instance_valid(vehicle_buy): return
	var config: Dictionary = Balance.COSMETICS[selected_vehicle]
	var owned: bool = selected_vehicle in store.data.cosmetics.owned
	var equipped: bool = store.data.cosmetics.equipped.van == selected_vehicle
	var featured: bool = selected_vehicle in PlayRewards.today_shop()
	vehicle_wallet.text = "$" + cash_text(int(store.data.wallet))
	vehicle_status.text = "YOUR GETAWAY · EQUIPPED" if equipped else ("OWNED · EQUIP ANY TIME" if owned else ("IN TODAY'S SHOP" if featured else "RETURNS TO TODAY'S SHOP"))
	vehicle_buy.text = "EQUIPPED" if equipped else ("EQUIP" if owned else ("BUY & EQUIP · $" + cash_text(int(config.price)) if featured else "BACK IN A FUTURE ROTATION"))
	vehicle_buy.disabled = equipped or (not owned and (not featured or int(store.data.wallet) < int(config.price)))
	if not owned and featured and int(store.data.wallet) < int(config.price): vehicle_status.text = "$%s MORE TO GO" % cash_text(int(config.price)-int(store.data.wallet))
	if store.last_error != "": vehicle_status.text = store.last_error

func animate_vehicle_purchase(previous_wallet: int, store: SaveStore) -> void:
	if not is_instance_valid(vehicle_buy): return
	vehicle_status.text = "NEW GETAWAY! · EQUIPPED"
	UiJuice.pulse(vehicle_buy, 1.04, 0.24)
	var target := vehicle_wallet
	var animation := target.create_tween()
	animation.tween_method(func(amount: float):
		if is_instance_valid(target): target.text = "$" + cash_text(roundi(amount))
	, float(previous_wallet), float(store.data.wallet), 0.45)

func settings_page(store: SaveStore, muted: bool, volume: float = 1.0, haptics_on: bool = true, camera_on: bool = true) -> void:
	var body = page("Make yourself at home.","SETTINGS",store.data.wallet,store.data.diamonds)
	blue_button(body,"PROFILE & STATS",func(): action_requested.emit("stats"),60)
	blue_button(body,"SOUND · OFF" if muted else "SOUND · ON",func(): action_requested.emit("toggle_sound"),76)
	var volume_label := text(body,"SFX VOLUME  %d%%" % roundi(volume * 100),20,HudStyle.CYAN)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.1
	slider.value = volume
	slider.custom_minimum_size.y = 68
	for entry in [["slider", Color("250938")], ["grabber_area", HudStyle.CYAN.darkened(0.3)], ["grabber_area_highlight", HudStyle.CYAN]]:
		var track = noise_style(entry[1])
		track.content_margin_top = 5
		track.content_margin_bottom = 5
		slider.add_theme_stylebox_override(entry[0], track)
	var handle = GradientTexture2D.new()
	handle.width = 28
	handle.height = 28
	handle.fill = GradientTexture2D.FILL_RADIAL
	handle.fill_from = Vector2(0.5, 0.5)
	handle.fill_to = Vector2(1.0, 0.5)
	handle.gradient = Gradient.new()
	handle.gradient.colors = PackedColorArray([PAPER, PAPER, Color(PAPER, 0)])
	handle.gradient.offsets = PackedFloat32Array([0, 0.83, 1])
	slider.add_theme_icon_override("grabber", handle)
	slider.add_theme_icon_override("grabber_highlight", handle)
	body.add_child(slider)
	slider.value_changed.connect(func(value: float):
		volume_label.text = "SFX VOLUME  %d%%" % roundi(value * 100)
		action_requested.emit("sfx_volume:%s" % value)
	)
	blue_button(body,"HAPTICS · ON" if haptics_on else "HAPTICS · OFF",func(): action_requested.emit("toggle_haptics"),76)
	blue_button(body,"VISUAL EFFECTS · ON" if camera_on else "VISUAL EFFECTS · OFF",func(): action_requested.emit("toggle_camera_effects"),76)
	blue_button(body,"REPLAY TUTORIAL",func(): action_requested.emit("replay_tutorial"),76)
	var c = card(body)
	headline(c,"HOW TO PLAY",28)
	text(c,"Drag to move, or use WASD / arrow keys. Stop near loot to lift it. Stop at the van to load. Escape with empty hands before the timer runs out.",22)
	text(c,"Escape / Ⅱ pauses the round. Resume when you are ready.",21,MUTED)
	text(body,"DEV build · progress resets on launch." if development_mode else "Progress saves automatically.",20,MINT)
	save_status(body,store)
	if development_mode:
		var drawer = column(body, 8)
		drawer.visible = false
		var toggle = blue_button(body, "DEV TOOLS ▾", func(): drawer.visible = not drawer.visible, 48)
		toggle.add_theme_font_size_override("font_size", 17)
		body.move_child(toggle, drawer.get_index())
		dev_button(drawer, store)

func stats_page(store: SaveStore) -> void:
	var body = page("Every heist counts.","YOUR RECORD",store.data.wallet,store.data.diamonds)
	var c = card(body)
	headline(c,"%d ESCAPES  ·  %d BUSTED" % [store.data.successes,store.data.failures],28)
	text(c,"%d / %d TROPHIES   ·   %d / %d MASTERY MEDALS" % [store.data.trophies.size(),Balance.TROPHIES.size(),Progression.contract_count(store.data),Balance.CONTRACTS.size()],20,MINT)
	for location in Balance.LOCATION_ORDER:
		var entry = card(body)
		headline(entry,Balance.LOCATIONS[location].name,26)
		text(entry,"OBJECTIVES %d / 3" % Progression.objective_count(store.data,location),20,MINT)
		var progress = ProgressBar.new()
		progress.custom_minimum_size.y = 10
		progress.show_percentage = false
		progress.value = 100.0 * Progression.objective_count(store.data,location) / 3.0
		progress.add_theme_stylebox_override("background", noise_style(Color("1e072e")))
		progress.add_theme_stylebox_override("fill", noise_style(MINT))
		entry.add_child(progress)
		if store.data.records.normal.has(location):
			text(entry,"BEST CLEAR  ·  %.2fs" % store.data.records.normal[location],20,MUTED)


func shop(body: VBoxContainer, store: SaveStore) -> void:
	upgrade_cards.clear()
	for key in Balance.UPGRADE_KEYS:
		var level: int = store.data.upgrades[key]
		var maxed = level >= Balance.max_level(key)
		var tier_locked = level >= Balance.purchase_cap(key, store.data)
		var shell = PanelContainer.new()
		shell.add_theme_stylebox_override("panel", shop_card_style(key, key == shop_selected_key))
		body.add_child(shell)
		var c = column(shell, 8)
		upgrade_cards[key] = c
		var top = row(c, 12)
		# Coloured art tile; tapping it selects the card and toggles the formula details.
		var icon_button = Button.new()
		icon_button.custom_minimum_size = Vector2(96, 96)
		icon_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		icon_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_button.focus_mode = Control.FOCUS_NONE
		icon_button.tooltip_text = "Upgrade details"
		icon_button.add_theme_stylebox_override("normal", jobs_style(SHOP_TILES[key], SHOP_ACCENTS[key], 18, 0, 5))
		icon_button.add_theme_stylebox_override("hover", jobs_style(SHOP_TILES[key].lightened(0.1), SHOP_ACCENTS[key], 18, 0, 5))
		icon_button.add_theme_stylebox_override("pressed", jobs_style(SHOP_TILES[key].darkened(0.15), SHOP_ACCENTS[key], 18, 0, 5))
		icon_button.pressed.connect(func(): shop_toggle_details(key))
		top.add_child(icon_button)
		var icon = TextureRect.new()
		icon.texture = MenuArt.texture("powerups/" + SHOP_ICONS[key])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_button.add_child(icon)
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 8
		icon.offset_top = 8
		icon.offset_right = -8
		icon.offset_bottom = -10
		c.set_meta("icon_button", icon_button)
		var info = column(top, 2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		jobs_label(info, SHOP_TITLES[key], 24, PAPER, true, 3)
		var level_line = row(info, 8)
		var level_label := jobs_label(level_line, "LEVEL %d / %d" % [level, Balance.max_level(key)], 16, SHOP_ACCENTS[key])
		c.set_meta("level_label", level_label)
		var required_now: int = Balance.required_level(key, Balance.LOCATION_ORDER[Balance.unlocked_tier(store.data)])
		if level < required_now:
			jobs_label(level_line, "·", 16, Color("8a63ad"))
			jobs_label(level_line, "NEED %d" % required_now, 16, HudStyle.MONEY)
		var blurb: String = SHOP_BLURBS[key]
		if key == "strength" and not maxed: blurb += " · %d%% less noise" % Balance.strength_noise_reduction(level)
		var desc = jobs_label(info, blurb, 16, Color("c9a6ec"))
		desc.clip_text = true
		# Segmented level bar: a real ProgressBar (animations tween its value) with dividers on top.
		var progress = ProgressBar.new()
		progress.custom_minimum_size = Vector2(0, 14)
		progress.show_percentage = false
		progress.value = 100.0 * level / Balance.max_level(key)
		var track = panel(Color("210931"), 5)
		track.set_content_margin_all(0)
		var fill = panel(SHOP_ACCENTS[key], 5)
		fill.set_content_margin_all(0)
		progress.add_theme_stylebox_override("background", track)
		progress.add_theme_stylebox_override("fill", fill)
		info.add_child(progress)
		for i in range(1, 5):
			var divider = ColorRect.new()
			divider.color = Color("2f1048")
			divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
			divider.anchor_left = i / 5.0
			divider.anchor_right = i / 5.0
			divider.anchor_bottom = 1.0
			divider.offset_left = -2
			divider.offset_right = 2
			progress.add_child(divider)
		c.set_meta("progress_bar", progress)
		var cost = Balance.upgrade_cost(key, level)
		var free_token: bool = int(store.data.get("upgrade_tokens", 0)) > 0 and not maxed and not tier_locked
		var label = "MAXED" if maxed else ("LOCKED" if tier_locked else ("FREE · TOKEN" if free_token else "BUY  $%s" % cash_text(cost)))
		var b = button(top, label, func():
			shop_selected_key = key
			buy_requested.emit(key)
		, 96)
		c.set_meta("buy_button", b)
		b.custom_minimum_size.x = 150
		b.size_flags_horizontal = Control.SIZE_SHRINK_END
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.autowrap_mode = TextServer.AUTOWRAP_WORD
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_font_override("font", display_font)
		b.add_theme_font_size_override("font_size", 22 if label.length() < 12 else 18)
		b.add_theme_color_override("font_shadow_color", Color("0b3f24", 0.5))
		b.add_theme_constant_override("shadow_offset_y", 2)
		b.disabled = maxed or tier_locked or (store.data.wallet < cost and not free_token)
		var affordable: bool = not b.disabled
		for state in ["font_color", "font_hover_color", "font_pressed_color"]: b.add_theme_color_override(state, PAPER)
		b.add_theme_color_override("font_disabled_color", Color("b9a2d0"))
		b.add_theme_stylebox_override("normal", jobs_style(Color("1fc25a"), Color("7cf5a6"), 18, 4, 6))
		b.add_theme_stylebox_override("hover", jobs_style(Color("2fd86c"), Color("9dffc0"), 18, 4, 6))
		b.add_theme_stylebox_override("pressed", jobs_style(Color("179a47"), Color("7cf5a6"), 18, 4, 6))
		b.add_theme_stylebox_override("disabled", jobs_style(Color("3c204f"), Color("5a3a73"), 18, 4, 6))
		if affordable and not free_token:
			b.icon = load("res://assets/hud/cash.png")
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.add_theme_constant_override("icon_max_width", 34)
			b.add_theme_constant_override("h_separation", 6)
		# Second line: what the next level gives.
		var effect_shell = PanelContainer.new()
		effect_shell.add_theme_stylebox_override("panel", jobs_style(Color("24093a", 0.85), Color("4d2a6e"), 12, 6, 2))
		c.add_child(effect_shell)
		var effect_line = row(effect_shell, 8)
		effect_line.alignment = BoxContainer.ALIGNMENT_BEGIN
		if key == "strength":
			shop_strength_unlocks(effect_line, mini(level + 1, Balance.max_level(key)), maxed)
		else:
			var benefit = jobs_label(effect_line, shop_benefit(key, level), 19, SHOP_ACCENTS[key], false, 2)
			benefit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			benefit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			if key == "capacity": shop_cargo_boxes(effect_line, level)
		var details = jobs_label(c, Balance.effect(key, level), 14, MUTED)
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		details.visible = false
		c.set_meta("details_label", details)
		if level > Balance.purchase_cap(key, store.data): jobs_label(c, "GRANDFATHERED · LEVEL STILL ACTIVE", 13, MINT)
		if tier_locked and not maxed: jobs_label(c, Balance.tier_message(key, store.data).split(" FOR LEVEL")[0], 13, MUTED)

func shop_card_style(key: String, selected: bool) -> StyleBoxFlat:
	var style = jobs_style(Color("331251") if selected else Color("2b0f44"), SHOP_ACCENTS[key] if selected else Color("5a2f80"), 20, 12, 5)
	style.set_border_width_all(3 if selected else 2)
	style.border_width_bottom = 5
	if selected:
		style.shadow_color = Color(SHOP_ACCENTS[key], 0.35)
		style.shadow_size = 8
		style.shadow_offset = Vector2.ZERO
	return style

func shop_strength_unlocks(parent: HBoxContainer, next_level: int, maxed: bool) -> void:
	if maxed:
		var all = jobs_label(parent, "ALL LOOT UNLOCKED", 18, SHOP_ACCENTS.strength)
		all.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		return
	var featured: Array = strength_featured(next_level)
	var total := 0
	for id in Balance.ITEMS:
		if int(Balance.ITEMS[id].required_strength) == next_level: total += 1
	var shown := 0
	for id in featured:
		if not Balance.ITEMS.has(id): continue
		var chip = row(parent, 5)
		chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var path := "res://assets/ui/jobs/icons/%s.svg" % id
		if ResourceLoader.exists(path): jobs_icon(chip, path, 34)
		var name := str(Balance.ITEMS[id].display_name).to_upper()
		if name == "ARCADE MACHINE": name = "ARCADE"
		if name == "GIANT DIAMOND": name = "DIAMOND"
		if name == "LARGE STATUE": name = "STATUE"
		var caption = jobs_label(chip, name, 16, PAPER)
		caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		shown += 1
	if total > shown:
		var more = jobs_label(parent, "+%d" % (total - shown), 15, Color("c9a6ec"))
		more.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func shop_benefit(key: String, level: int) -> String:
	var next_level = mini(level + 1, Balance.max_level(key))
	match key:
		"grip": return "+%d%% PICKUP SPEED" % roundi((Balance.grip_speed(next_level) / Balance.grip_speed(level) - 1.0) * 100) if next_level > level else "PICKUP SPEED MAXED"
		"carry": return "WALK +%d%% · HEAVY LOOT +%d%%" % [roundi((Balance.walk_factor(next_level) / Balance.walk_factor(level) - 1.0) * 100), roundi((Balance.carry_speed("VERY_HEAVY",next_level) / Balance.carry_speed("VERY_HEAVY",level) - 1.0) * 100)] if next_level > level else "CARRY SPEED MAXED"
		"capacity": return "%d  →  %d CARGO" % [Balance.van_capacity(level), Balance.van_capacity(next_level)] if next_level > level else "%d CARGO · MAX" % Balance.van_capacity(level)
		"noise": return "-%d%% NOISE" % roundi((Balance.noise_multiplier(level) - Balance.noise_multiplier(next_level)) * 100) if next_level > level else "NOISE CONTROL MAXED"
	return ""

func shop_cargo_boxes(parent: HBoxContainer, level: int) -> void:
	var current_boxes: int = Balance.van_capacity(level) / 2
	var next_boxes: int = Balance.van_capacity(mini(level + 1, Balance.max_level("capacity"))) / 2
	var boxes = row(parent, 4)
	boxes.size_flags_horizontal = Control.SIZE_SHRINK_END
	boxes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i in range(maxi(0, next_boxes - 7), next_boxes):
		var crate = Panel.new()
		crate.custom_minimum_size = Vector2(18, 18)
		var crate_style = panel(SHOP_TILES.capacity if i < current_boxes else Color("3a1a55"), 4)
		crate_style.set_content_margin_all(0)
		crate_style.border_color = SHOP_ACCENTS.capacity if i < current_boxes else Color("5a2f80")
		crate_style.set_border_width_all(1)
		crate.add_theme_stylebox_override("panel", crate_style)
		crate.add_to_group("shop_cargo_box")
		boxes.add_child(crate)

func shop_select(key: String, bring_into_view: bool = false) -> void:
	if not upgrade_cards.has(key): return
	shop_selected_key = key
	if is_instance_valid(shop_preview): shop_preview.set_upgrade_focus(key)
	for id in upgrade_cards:
		var c: VBoxContainer = upgrade_cards[id]
		if is_instance_valid(c):
			c.get_parent().add_theme_stylebox_override("panel", shop_card_style(id, id == key))
	if bring_into_view: shop_focus_card.call_deferred(key)

func shop_focus_card(key: String) -> void:
	await get_tree().process_frame
	if is_instance_valid(shop_scroll) and upgrade_cards.has(key) and is_instance_valid(upgrade_cards[key]):
		shop_scroll.ensure_control_visible(upgrade_cards[key])

func shop_toggle_details(key: String) -> void:
	shop_select(key)
	var label: Label = upgrade_cards[key].get_meta("details_label")
	var show := not label.visible
	for id in upgrade_cards:
		var detail: Label = upgrade_cards[id].get_meta("details_label")
		detail.visible = show and id == key
	if show: shop_focus_card.call_deferred(key)

func animate_upgrade_purchase(key: String, old_wallet: int, old_level: int, store: SaveStore) -> void:
	if is_instance_valid(menu_wallet_label):
		UiJuice.count_label(menu_wallet_label, old_wallet, store.data.wallet, 0.38)
	var card_node: Control = upgrade_cards.get(key)
	if is_instance_valid(card_node):
		UiJuice.pulse(card_node, 1.025, 0.30)
		UiJuice.flash(card_node, Color("baffdc"), 0.38)
		UiJuice.pulse(card_node.get_meta("buy_button"), 1.045, 0.18)
		UiJuice.pulse(card_node.get_meta("icon_button"), 1.12, 0.32)
		var progress: ProgressBar = card_node.get_meta("progress_bar")
		progress.value = 100.0 * old_level / Balance.max_level(key)
		progress.create_tween().tween_property(progress, "value", 100.0 * int(store.data.upgrades[key]) / Balance.max_level(key), 0.35)
		var level_label: Label = card_node.get_meta("level_label")
		level_label.text = "LEVEL %d / %d" % [old_level, Balance.max_level(key)]
		level_label.create_tween().tween_method(func(value: float):
			if is_instance_valid(level_label): level_label.text = "LEVEL %d / %d" % [roundi(value), Balance.max_level(key)]
		, float(old_level), float(store.data.upgrades[key]), 0.30)
	if key == "strength":
		show_strength_power_up(int(store.data.upgrades.strength))
	else:
		show_menu_badge("UPGRADED!\n%s LEVEL %d" % [SHOP_TITLES[key], store.data.upgrades[key]], SHOP_COLORS[key], 0.65)

func show_strength_power_up(level: int) -> void:
	if not is_instance_valid(menu): return
	var unlocked: Array[String] = []
	for id in strength_featured(level):
		unlocked.append(id)
	if unlocked.is_empty(): return
	var overlay := Control.new()
	overlay.name = "StrengthPowerUp"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_to_group("ui_juice_overlay")
	root.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color("1c062cb3")
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var plate := PanelContainer.new()
	plate.name = "PowerUpPlate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate_style = HudStyle.plate(Color("311048"),HudStyle.GOLD,26)
	plate_style.set_content_margin_all(18)
	plate_style.border_width_bottom = 7
	plate.add_theme_stylebox_override("panel",plate_style)
	var width := minf(600.0,root.size.x - safe_insets.x - safe_insets.z - PAGE_GUTTER * 2.0)
	plate.size = Vector2(width,280)
	plate.position = Vector2((root.size.x - width) * 0.5, safe_insets.y + (root.size.y - safe_insets.y - safe_insets.w - plate.size.y) * 0.46)
	overlay.add_child(plate)
	var content := column(plate,6)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var power_title := headline(content,"POWER UP!",43,HudStyle.GOLD,true)
	power_title.name = "PowerUpTitle"
	var level_title := headline(content,"STRENGTH %d" % level,30,PAPER,true)
	level_title.name = "PowerUpLevel"
	var loot_row := row(content,8)
	loot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	loot_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index in range(unlocked.size()):
		var id := unlocked[index]
		var loot := PanelContainer.new()
		loot.name = "UnlockedLoot_" + id
		loot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		loot.custom_minimum_size = Vector2((width - 58) / maxf(3.0,float(unlocked.size())),105)
		loot.add_theme_stylebox_override("panel",HudStyle.plate(Color("3e1759"),HudStyle.CYAN,14))
		loot_row.add_child(loot)
		var loot_content := column(loot,1)
		loot_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		var icon_path := "res://assets/ui/jobs/icons/%s.svg" % id
		if ResourceLoader.exists(icon_path): icon.texture = load(icon_path)
		icon.custom_minimum_size = Vector2(54,54)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		loot_content.add_child(icon)
		var caption := text(loot_content,str(Balance.ITEMS[id].display_name).to_upper(),17,PAPER)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loot.modulate.a = 0.0
		loot.scale = Vector2.ONE * 0.68
		loot.resized.connect(func(): loot.pivot_offset = loot.size * 0.5)
		var item_reveal := loot.create_tween().set_parallel(true)
		item_reveal.tween_property(loot,"modulate:a",1.0,0.13).set_delay(0.15 + index * 0.10)
		item_reveal.tween_property(loot,"scale",Vector2.ONE,0.27).set_delay(0.15 + index * 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var unlock_title := headline(content,"NEW LOOT UNLOCKED",22,HudStyle.GREEN,true)
	unlock_title.name = "PowerUpUnlockCaption"
	unlock_title.modulate.a = 0.0
	unlock_title.create_tween().tween_property(unlock_title,"modulate:a",1.0,0.14).set_delay(0.43)
	overlay.modulate.a = 0.0
	plate.scale = Vector2.ONE * 0.90
	plate.resized.connect(func(): plate.pivot_offset = plate.size * 0.5)
	var entrance := overlay.create_tween().set_parallel(true)
	entrance.tween_property(overlay,"modulate:a",1.0,0.12)
	entrance.tween_property(plate,"scale",Vector2.ONE,0.23).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var exit_tween := overlay.create_tween()
	exit_tween.tween_interval(0.80)
	exit_tween.tween_property(overlay,"modulate:a",0.0,0.16)
	exit_tween.tween_callback(overlay.queue_free)

func show_menu_badge(message: String, color: Color, seconds: float) -> void:
	if not is_instance_valid(menu): return
	var badge := Panel.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", HudStyle.plate(Color("371052"), color, 14))
	badge.position = Vector2(PAGE_GUTTER + safe_insets.x, maxf(145, safe_insets.y + PAGE_GUTTER))
	badge.size = Vector2(root.size.x - 2 * PAGE_GUTTER - safe_insets.x - safe_insets.z, 112)
	root.add_child(badge)
	badge.add_to_group("ui_juice_overlay")
	overlay_label(badge, message, 25, color, Vector2(12, 12), badge.size - Vector2(24, 24))
	UiJuice.pulse(badge, 1.04, 0.22)
	var tween := badge.create_tween()
	tween.tween_interval(seconds)
	tween.tween_property(badge, "modulate:a", 0.0, 0.18)
	tween.tween_callback(badge.queue_free)

func show_special_reveal() -> void:
	show_menu_badge("SPECIAL JOB!  ⚡ RUSH HOUR", HudStyle.SPECIAL, 0.78)

func show_final_job_complete() -> void:
	show_menu_badge("FINAL JOB COMPLETE!\nSUBURBAN HOUSE UNLOCKED", HudStyle.FINAL, 1.1)

func overlay_label(parent: Control, value: String, font_size: int, color: Color, at: Vector2, bounds: Vector2) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", heavy_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("180624"))
	label.add_theme_constant_override("outline_size", 5)
	parent.add_child(label)
	label.position = at
	label.size = bounds
	return label

func show_result_climax(result: Dictionary) -> void:
	if not is_instance_valid(menu): return
	if result.get("success", false) and result.get("earned", 0) > 0 and not result.get("tutorial", false) and is_instance_valid(menu_wallet_label):
		UiJuice.count_label(menu_wallet_label, int(menu_wallet_label.text.trim_prefix("$").replace(",", "")) - int(result.earned), int(menu_wallet_label.text.trim_prefix("$").replace(",", "")), 0.48)
	var overlay := Panel.new()
	result_overlay = overlay
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_theme_stylebox_override("panel", HudStyle.plate(Color("321248"), HudStyle.GREEN if result.get("success", false) else HudStyle.RED, 18))
	overlay.position = Vector2(PAGE_GUTTER + safe_insets.x, root.size.y * 0.40)
	overlay.size = Vector2(root.size.x - 2 * PAGE_GUTTER - safe_insets.x - safe_insets.z, 178)
	root.add_child(overlay)
	overlay.add_to_group("ui_juice_overlay")
	var success: bool = result.get("success", false)
	overlay_label(overlay, "ESCAPED!" if success else "BUSTED!", 43, HudStyle.GREEN if success else HudStyle.RED, Vector2(12, 23), Vector2(overlay.size.x - 24, 56))
	overlay_label(overlay, "+$%d BANKED" % result.get("earned", 0) if success else "$%d LOST" % result.get("lost", 0), 31, HudStyle.MONEY if success else HudStyle.RED, Vector2(12, 92), Vector2(overlay.size.x - 24, 46))
	if success and result.get("full_clear", false):
		overlay_label(overlay, "FULL CLEAR!", 20, HudStyle.GOLD, Vector2(12, 141), Vector2(overlay.size.x - 24, 28))
	elif not success and result.get("lost", 0) > 0:
		var drain := ProgressBar.new()
		drain.position = Vector2(26, 150)
		drain.size = Vector2(overlay.size.x - 52, 8)
		drain.show_percentage = false
		drain.value = 100
		drain.add_theme_stylebox_override("background", HudStyle.track(Color("250b37")))
		drain.add_theme_stylebox_override("fill", HudStyle.track(HudStyle.RED))
		overlay.add_child(drain)
		drain.create_tween().tween_property(drain, "value", 0.0, 0.42)
	UiJuice.pulse(overlay, 1.04, 0.20)
	var tween := overlay.create_tween()
	tween.tween_interval(0.62)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.18)
	tween.tween_callback(overlay.queue_free)

func show_new_trophy(names: Array, count: int, total: int) -> void:
	if names.is_empty() or not is_instance_valid(root): return
	close_trophy_modal()
	trophy_modal = PanelContainer.new()
	trophy_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trophy_modal.add_theme_stylebox_override("panel", panel(Color(0.0851, 0.0350, 0.1200, 0.93), 0))
	root.add_child(trophy_modal)
	var safe_content = margin(trophy_modal, PAGE_GUTTER)
	apply_page_margins(safe_content)
	var center = CenterContainer.new()
	safe_content.add_child(center)
	var frame = hud_plate(center, Color("371052"), HudStyle.RARE)
	frame.custom_minimum_size.x = minf(520.0, root.size.x - 2 * PAGE_GUTTER - safe_insets.x - safe_insets.z)
	var c = column(frame, 16)
	headline(c, "NEW TROPHY!", 34, HudStyle.RARE, true)
	for trophy_id in Balance.TROPHIES:
		var type_id: String = Balance.TROPHIES[trophy_id].type_id
		for trophy_name in names:
			if str(Balance.ITEMS[type_id].display_name).to_upper() == str(trophy_name).to_upper():
				loot_preview(c, type_id, 300, 190)
				break
	for trophy_name in names:
		headline(c, str(trophy_name).to_upper(), 24, PAPER, true)
	var count_label = text(c, "TROPHIES %d / %d" % [count, total], 22, MINT)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button(c, "VIEW TROPHIES", func():
		close_trophy_modal()
		action_requested.emit("trophies")
	, 72)
	blue_button(c, "CONTINUE", func(): close_trophy_modal(), 60)

func close_trophy_modal() -> void:
	if is_instance_valid(trophy_modal):
		trophy_modal.queue_free()
		trophy_modal = null

func loot_preview(parent: Node, type_id: String, width: int, height: int, zoom: float = 3.3) -> SubViewportContainer:
	var container = SubViewportContainer.new()
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	container.material = vivid
	container.custom_minimum_size = Vector2(width, height)
	container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.clip_contents = true
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	var viewport = SubViewport.new()
	viewport.size = Vector2i(width, height)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	container.add_child(viewport)
	var model = Models.loot(type_id)
	if type_id == "rubber_duck": model.scale = Vector3.ONE * 1.8
	viewport.add_child(model)
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(2.7, 2.4, 3.5)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = zoom
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 2
	viewport.add_child(light)
	return container

func dev_button(body: VBoxContainer, store: SaveStore) -> void:
	if not development_mode: return
	var done: bool = Progression.upgrades_maxed(store.data) and store.data.unlocked.size() == Balance.LOCATION_ORDER.size()
	var label := "DEV · MAXED + ALL LEVELS UNLOCKED" if done else "DEV · MAX ALL + UNLOCK ALL LEVELS"
	var b = button(body, label, func(): action_requested.emit("dev_max"), 56)
	b.add_theme_stylebox_override("normal", panel(Color("ffd086")))
	b.disabled = done

func tutorial_results(result: Dictionary, store: SaveStore) -> void:
	var normalized := result.duplicate(true)
	normalized["lost"] = 0
	normalized["items"] = 0
	normalized["mode"] = "tutorial"
	present_result(normalized, store, "tutorial")

func results(result: Dictionary, store: SaveStore, location: String) -> void:
	present_result(result, store, location)

func present_result(result: Dictionary, store: SaveStore, location: String) -> void:
	var body := base_menu()
	var success: bool = result.get("success", false)
	var training := location == "tutorial"
	var view := ResultPresentation.new()
	view.name = "ResultPresentation"
	body.add_child(view)
	var replay_mode: String = str(result.get("mode", "normal"))
	if replay_mode == SpecialJobs.MODE or result.get("final_job_completed", false): replay_mode = "normal"
	view.setup(success, "FIRST HEIST" if training else str(Balance.LOCATIONS[location].name), heavy_font,
		("CHOOSE A JOB" if success else "RETRY") if training else ("PLAY AGAIN" if success else "RETRY"),
		func():
			if training: action_requested.emit("tutorial_continue" if success else "retry_tutorial")
			else: start_requested.emit(location, replay_mode),
		func(): action_requested.emit("home"))
	# The backdrop fills the display; the interactive composition respects the safe area.
	(menu_background.material as ShaderMaterial).set_shader_parameter("accent",Color("25053b"))
	menu_wallet_label = view.wallet
	menu_diamond_label = view.diamonds
	view.diamonds.text = cash_text(int(store.data.diamonds))
	view.fit_text(view.diamonds,69,36)
	var earned := int(result.get("earned", 0))
	var before := int(result.get("wallet_before", maxi(0, int(store.data.wallet)-earned))) if success else int(store.data.wallet)
	view.set_wallet("$" + cash_text(before))
	var total := earned if success else int(result.get("lost", 0))
	var notice := ""
	if training:
		if result.get("replay", false):
			view.caption.text = "PRACTICE COMPLETE" if success else "PRACTICE ENDED"
			notice = "Progress unchanged · No cash awarded"
		else: notice = "Choose your next job" if success else "Your banked cash is safe"
	elif not success:
		notice = "RUN ABANDONED" if result.get("abandoned", false) else ("ALARM TRIGGERED" if result.get("alarm_triggered", false) else "TIME RAN OUT")
	elif result.get("final_job_completed", false): notice = "FINAL JOB COMPLETE"
	elif result.get("full_clear", false): notice = "STEAL EVERYTHING! · LOCATION CLEARED"
	elif not result.get("new_trophies", []).is_empty(): notice = "NEW TROPHY · " + str(result.new_trophies[0])
	elif not result.get("new_rare_loot", []).is_empty(): notice = "RARE LOOT ADDED TO COLLECTION"
	else: notice = "%d ITEMS STOLEN · %.0fs" % [int(result.get("items",0)),float(result.get("elapsed",0))]
	var unlocked: Array = result.get("unlocked_locations", [])
	if success and not unlocked.is_empty(): notice = str(Balance.LOCATIONS[unlocked[0]].name).to_upper() + " UNLOCKED"
	view.set_notice(notice + ("  ›" if not training else ""))
	view.notice.tooltip_text = "Run details" if not training else notice
	if not training: view.notice.pressed.connect(func(): result_details(result,store,location))
	else: view.notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.notice.modulate.a = 0.0
	if not training: view.add_meter(result.get("lucky_meter", {}), store.data.lucky_meter, LuckyMeter.TARGET)
	view.set_escape_style(LuckyShop.accent(store.data, "cash_vfx", Color.WHITE), LuckyShop.equipped(store.data, "escape_vfx") != "")
	var reveal := view.create_tween()
	reveal.tween_interval(0.70)
	reveal.tween_property(view.notice,"modulate:a",1.0,0.22)
	var counter := view.create_tween()
	counter.tween_method(func(value: float): view.set_amount(roundi(value),success),0.0,float(total),0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if success and earned > 0:
		var wallet_count := view.create_tween()
		wallet_count.tween_method(func(value: float): view.set_wallet("$" + cash_text(roundi(value))),float(before),float(store.data.wallet),0.60).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		wallet_count.tween_callback(func(): UiJuice.pulse(view.wallet,1.06,0.2))
	if store.last_error != "":
		view.set_notice(store.last_error)
		view.notice.add_theme_color_override("font_color",HudStyle.RED)

func result_details(result: Dictionary, store: SaveStore, location: String) -> void:
	if is_instance_valid(modal): return
	modal = PanelContainer.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_theme_stylebox_override("panel",panel(Color("160423f5"),0))
	root.add_child(modal)
	var safe := margin(modal,PAGE_GUTTER)
	apply_page_margins(safe)
	var content := column(safe,14)
	headline(content,"HEIST DETAILS",32,PAPER,true)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var body := column(scroll,14)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(body,str(Balance.LOCATIONS[location].name),25,HudStyle.CYAN)
	text(body,"%d items %s · %.0fs active" % [int(result.get("items",0)),"stolen" if result.success else "lost",float(result.get("elapsed",0))],22,PAPER)
	if result.success:
		result_haul(body,result.get("loot_types",[]))
		if result.get("final_job_completed",false): headline(body,"FINAL JOB COMPLETE",27,HudStyle.GOLD,true)
		elif result.get("full_clear",false): headline(body,"STEAL EVERYTHING!",27,HudStyle.GOLD,true)
		for id in result.get("unlocked_locations",[]): headline(body,str(Balance.LOCATIONS[id].name)+" UNLOCKED",25,HudStyle.GOLD,true)
		if not result.get("new_trophies",[]).is_empty(): result_trophy(body,result.new_trophies,store.data.trophies.size())
		for id in result.get("new_rare_loot",[]):
			var rare := LootRarity.variant(str(id))
			if not rare.is_empty(): headline(body,"NEW %s · %s" % [rare.tier,rare.name],24,rare.color,true)
		if result.get("special_unlocked",false): text(body,"RUSH HOUR AVAILABLE IN JOBS",22,HudStyle.SPECIAL)
		if result.get("mode","") == SpecialJobs.MODE: text(body,"Loot $%s · Rush bonus +$%s" % [cash_text(int(result.get("loot_value",0))),cash_text(int(result.get("rush_bonus",0)))],22,HudStyle.GOLD)
		elif result.get("mode","normal") not in ["normal","FINAL_JOB"]: text(body,"CONTRACT COMPLETE · MEDAL EARNED" if result.get("contract_met",false) else "CONTRACT INCOMPLETE",22,HudStyle.GOLD)
	else: text(body,"Your banked cash is safe. Try a shorter route.",23,HudStyle.CYAN)
	blue_button(content,"CLOSE",func(): close_pause(true),72)
	UiJuice.modal_enter(modal,content)

func result_target(body: VBoxContainer, store: SaveStore) -> void:
	var target_data = Progression.next_result_target(store.data)
	var shell = PanelContainer.new()
	var style = panel(Color("2b103e"), 16)
	style.set_content_margin_all(12)
	style.border_color = Color("5e3779")
	style.set_border_width_all(1)
	shell.add_theme_stylebox_override("panel", style)
	body.add_child(shell)
	var line = row(shell, 12)
	var icon_path := "res://assets/ui/jobs/icons/%s.svg" % str(target_data.type_id)
	if str(target_data.title) == "STEAL EVERYTHING": icon_path = "res://assets/ui/jobs/icons/crown.svg"
	var icon = TextureRect.new()
	icon.texture = load(icon_path) if ResourceLoader.exists(icon_path) else HudStyle.ICONS["clock" if str(target_data.title).contains("TIME") else "cash"]
	icon.custom_minimum_size = Vector2(58, 58)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	line.add_child(icon)
	var copy = column(line, 1)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text(copy, "NEXT TARGET", 15, HudStyle.CYAN)
	headline(copy, str(target_data.title), 25, PAPER)
	text(copy, str(target_data.hint), 18, MUTED)

func result_haul(body: VBoxContainer, type_ids: Array) -> void:
	if type_ids.is_empty(): return
	var unique: Array = []
	var counts: Dictionary = {}
	for type_id in type_ids:
		if not Balance.ITEMS.has(type_id): continue
		counts[type_id] = int(counts.get(type_id, 0)) + 1
		if type_id not in unique: unique.append(type_id)
	if unique.is_empty(): return
	var centered := CenterContainer.new()
	body.add_child(centered)
	var strip = row(centered, 7)
	for i in range(mini(3, unique.size())):
		var type_id: String = str(unique[i])
		var cell = column(strip, 0)
		cell.custom_minimum_size.x = 102
		loot_preview(cell, type_id, 98, 68, 2.4)
		var label = text(cell, "%s%s" % [str(Balance.ITEMS[type_id].display_name).substr(0, 11), " ×%d" % counts[type_id] if counts[type_id] > 1 else ""], 12, MUTED)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if unique.size() > 3: text(strip, "+%d MORE" % (unique.size() - 3), 15, MUTED)

func result_trophy(body: VBoxContainer, names: Array, owned: int) -> void:
	var shell = PanelContainer.new()
	var style = panel(Color("352a42"), 14)
	style.set_content_margin_all(10)
	style.border_color = HudStyle.RARE.darkened(0.26)
	style.set_border_width_all(1)
	shell.add_theme_stylebox_override("panel", style)
	body.add_child(shell)
	var ribbon = row(shell, 10)
	ribbon.name = "ResultTrophy"
	ribbon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ribbon.custom_minimum_size.y = 82
	ribbon.modulate.a = 0.0
	var trophy_type := ""
	for trophy_id in Balance.TROPHIES:
		var candidate: String = str(Balance.TROPHIES[trophy_id].type_id)
		if str(Balance.ITEMS[candidate].display_name).to_upper() == str(names[0]).to_upper():
			trophy_type = candidate
			break
	if trophy_type != "": loot_preview(ribbon, trophy_type, 82, 72, 2.5)
	var copy = column(ribbon, 2)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var kicker = text(copy, "NEW TROPHY! · %d / %d" % [owned, Balance.TROPHIES.size()], 15, HudStyle.RARE)
	kicker.autowrap_mode = TextServer.AUTOWRAP_OFF
	var trophy_name = headline(copy, str(names[0]).to_upper(), 22, PAPER)
	trophy_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var reveal = ribbon.create_tween()
	reveal.tween_interval(0.68)
	reveal.tween_property(ribbon, "modulate:a", 1.0, 0.24)

func result_final_job(body: VBoxContainer, location: String) -> void:
	headline(body, "TIME MACHINE STOLEN" if location == "museum" else "FINAL JOB COMPLETE", 28, HudStyle.FINAL, true)
	var shell = PanelContainer.new()
	var style = panel(Color("20352f"), 18)
	style.set_content_margin_all(12)
	style.border_color = HudStyle.FINAL.darkened(0.24)
	style.set_border_width_all(1)
	shell.add_theme_stylebox_override("panel", style)
	body.add_child(shell)
	var line = row(shell, 15)
	var thumbnail = TextureRect.new()
	if location == "museum":
		thumbnail.texture = preload("res://assets/ui/jobs/pyramid.png")
	else:
		thumbnail.texture = preload("res://assets/ui/jobs/house.png")
	thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumbnail.custom_minimum_size = Vector2(170, 125)
	thumbnail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(thumbnail)
	var copy = column(line, 5)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text(copy, "MUSEUM CLEARED" if location == "museum" else "APARTMENT CLEARED", 17, MINT)
	headline(copy, "PYRAMID UNLOCKED" if location == "museum" else "SUBURBAN HOUSE UNLOCKED", 26, HudStyle.FINAL)
	text(copy, "Your next heist awaits.", 18, MUTED)

func show_heist_briefing(location: String) -> void:
	close_pause()
	input.enabled = false
	input.reset()
	modal = PanelContainer.new()
	modal.name = "FirstHeistBriefing"
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_theme_stylebox_override("panel", panel(Color(0.0810, 0.0250, 0.1200, 0.94), 0))
	root.add_child(modal)
	var safe_content = margin(modal, PAGE_GUTTER)
	apply_page_margins(safe_content)
	var center = CenterContainer.new()
	safe_content.add_child(center)
	var frame = hud_plate(center)
	frame.custom_minimum_size.x = minf(590.0, root.size.x - 2 * PAGE_GUTTER - safe_insets.x - safe_insets.z)
	var content = column(frame, 22)
	headline(content, "YOUR FIRST HEIST", 34, HudStyle.GREEN, true)
	var place = text(content, str(Balance.LOCATIONS[location].name).to_upper(), 23, HudStyle.CYAN)
	place.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tips = [
		["clock", "%ds TO GET OUT" % int(Balance.LOCATIONS[location].duration), "The clock starts when you move."],
		["box", "CHOOSE YOUR LOOT", "Limited van space. Escape to keep the cash."],
		["noise", "WATCH THE NOISE", "An alarm brings police. Head back to the van."]
	]
	for tip in tips:
		var line = row(content, 14)
		HudStyle.icon(line, tip[0], 52)
		var copy = column(line, 4)
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		headline(copy, tip[1], 24, PAPER)
		text(copy, tip[2], 21, MUTED)
	var locks = text(content, "Locked loot? Upgrade Strength to lift it.", 21, HudStyle.CYAN)
	locks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button(content, "START HEIST", func(): action_requested.emit("begin_heist"), 84)
	blue_button(content, "BACK TO JOBS", func(): action_requested.emit("locations"), 68)
	UiJuice.modal_enter(modal, frame)

func show_pause() -> void:
	if is_instance_valid(modal): return
	input.enabled = false
	input.reset()
	modal = PanelContainer.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_theme_stylebox_override("panel", panel(Color(0.0851, 0.0350, 0.1200, 0.93), 0))
	root.add_child(modal)
	var safe_content = margin(modal, PAGE_GUTTER)
	apply_page_margins(safe_content)
	var center = CenterContainer.new()
	safe_content.add_child(center)
	var frame = hud_plate(center)
	frame.custom_minimum_size.x = minf(520.0, root.size.x - 2 * PAGE_GUTTER - safe_insets.x - safe_insets.z)
	var c = column(frame, 20)
	var badge = HudStyle.icon(c, "pause", 66)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	headline(c, "TAKE A BREATHER.", 36, PAPER, true)
	var explanation = text(c, "The clock is paused.", 23, HudStyle.CYAN)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var resume = button(c, "RESUME", func(): action_requested.emit("resume"), 82)
	HudStyle.action(resume, "play", Color("14be86"), Color("66ffbe"), heavy_font)
	var abandon = button(c, "ABANDON RUN", func(): confirm_abandon(c), 72)
	HudStyle.action(abandon, "warning", Color("562776"), Color("7a479d"), heavy_font)
	UiJuice.modal_enter(modal, frame)

func confirm_abandon(content: VBoxContainer) -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	headline(content, "LEAVE THIS HEIST?", 34, PAPER, true)
	var hint = text(content, "The loot in your van will be lost. Your banked cash stays safe.", 23, MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var keep = button(content, "KEEP PLAYING", func(): action_requested.emit("resume"), 82)
	HudStyle.action(keep, "play", Color("14be86"), Color("66ffbe"), heavy_font)
	var leave = blue_button(content, "LEAVE & LOSE LOOT", func(): action_requested.emit("abandon"), 72)
	leave.add_theme_color_override("font_color", HudStyle.RED)
	UiJuice.pulse(content, 0.985, 0.18)

func close_pause(animated: bool = false) -> void:
	if is_instance_valid(modal):
		if animated: UiJuice.dismiss(modal)
		else: modal.queue_free()
		modal = null

func loot_model_preview(parent: Node, type_id: String, height: int, rare_id: String = "") -> SubViewportContainer:
	var container = SubViewportContainer.new()
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	container.material = vivid
	container.custom_minimum_size.y = height
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	var viewport = SubViewport.new()
	viewport.size = Vector2i(560, height)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	container.add_child(viewport)
	var model = Models.loot(type_id)
	if rare_id != "": LootRarity.decorate_model(model, LootRarity.variant(rare_id))
	viewport.add_child(model)
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(2.6, 2.3, 4.2)
	camera.look_at(Vector3(0, 0.65, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.3
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -30, 0)
	light.light_energy = 2.0
	viewport.add_child(light)
	return container

func collection(store: SaveStore) -> void:
	garage_page(store)

func trophy_shelf(store: SaveStore) -> void:
	var frame = base_menu()
	menu_header(frame,"TROPHY SHELF",store.data.wallet,"TROPHIES & RARE LOOT",store.data.diamonds)
	var tally = row(frame)
	var collected = headline(tally, "%d / %d COLLECTED" % [store.data.trophies.size(), Balance.TROPHIES.size()], 25, HudStyle.RARE)
	collected.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var collection_hint = text(tally, "Escape with trophies", 19, MUTED)
	collection_hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	collection_hint.size_flags_horizontal = Control.SIZE_SHRINK_END
	var body = scroll_body(frame)
	if not store.data.level_gifts.is_empty():
		headline(body,"LEVEL GIFTS · PROTOTYPE OUTFITS",23,HudStyle.RARE)
		for location in Balance.LOCATION_ORDER:
			if not store.data.level_gifts.has(location): continue
			var rarity: int = store.data.level_gifts[location].rarity
			var gift_button := blue_button(body,Balance.LOCATIONS[location].name + " · " + LevelGifts.RARITIES[rarity],func(): action_requested.emit("gift_view:"+location),62)
			gift_button.add_theme_color_override("font_color",LevelGifts.COLORS[rarity])
	for id in Balance.TROPHIES:
		var owned = id in store.data.trophies
		var c = card(body, Color("392944") if owned else Color("281038"))
		var line = row(c, 18)
		var container = SubViewportContainer.new()
		var vivid := ShaderMaterial.new()
		vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
		container.material = vivid
		container.custom_minimum_size = Vector2(180, 175)
		container.stretch = true
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(container)
		var viewport = SubViewport.new()
		viewport.size = Vector2i(180, 175)
		viewport.transparent_bg = true
		viewport.own_world_3d = true
		# Trophy models are static (fixed camera/light, no animation), so one render is enough —
		# avoids up to 6 SubViewports continuously re-rendering (including off-screen ones) on mobile.
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		container.add_child(viewport)
		var type_id: String = Balance.TROPHIES[id].type_id
		var model = Models.loot(type_id)
		if type_id == "rubber_duck": model.scale = Vector3.ONE * 1.8
		viewport.add_child(model)
		if not owned:
			trophy_silhouette(model)
		var camera = Camera3D.new()
		viewport.add_child(camera)
		camera.position = Vector3(2.5, 2.5, 4)
		camera.look_at(Vector3(0, 0.7, 0))
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 3.6
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-45, -30, 0)
		light.light_energy = 2
		viewport.add_child(light)
		var copy = column(line, 8)
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		text(copy, "✓ COLLECTED" if owned else "UNDISCOVERED", 18, MINT if owned else MUTED)
		headline(copy, Balance.ITEMS[type_id].display_name if owned else "MYSTERY TROPHY", 28)
		text(copy, Balance.LOCATIONS[Balance.TROPHIES[id].location].name, 20, MUTED)
	var rare_count = headline(body, "RARE LOOT  %d / %d" % [store.data.rare_loot.size(), LootRarity.all_ids().size()], 28, HudStyle.GOLD)
	rare_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text(body, "Found in Normal jobs. Escape with it to keep the discovery.", 18, MUTED)
	if not store.data.rare_loot.is_empty():
		var featured: Dictionary = LootRarity.variant(str(store.data.rare_loot.back()))
		if not featured.is_empty():
			var featured_card = card(body, Color("361a49"))
			loot_model_preview(featured_card, LootRarity.visual_type(featured), 155, str(featured.id))
			headline(featured_card, str(featured.name), 24, featured.color, true)
	for location in Balance.LOCATION_ORDER:
		var location_card = card(body, Color("281038"))
		var owned_here := 0
		for tier in LootRarity.TIERS:
			if location + "_" + tier.to_lower() in store.data.rare_loot: owned_here += 1
		headline(location_card, "%s  %d / 3" % [Balance.LOCATIONS[location].name, owned_here], 21, PAPER)
		for tier in LootRarity.TIERS:
			var rare_id: String = location + "_" + tier.to_lower()
			var rare_choice: Dictionary = LootRarity.variant(rare_id)
			var owned: bool = rare_id in store.data.rare_loot
			text(location_card, "%s  %s" % [tier, rare_choice.name if owned else "UNDISCOVERED"], 19, rare_choice.color if owned else MUTED)
	blue_button(body,"OUTFITS & VAN COLORS",func(): action_requested.emit("cosmetics"),76)
	navigation(frame,"collection",68,store)

func trophy_silhouette(node: Node) -> void:
	if node is MeshInstance3D: node.material_override = Models.material(Color("3e2450"))
	for child in node.get_children(): trophy_silhouette(child)

func duplication_lab(store: SaveStore) -> void:
	Duplication.settle(store.data,int(Time.get_unix_time_from_system()))
	var machine: Dictionary = store.data.duplication
	var frame = base_menu()
	frame.add_theme_constant_override("separation",7)
	menu_header(frame,"DUPLICATION LAB",store.data.wallet,"HELIX LAB · AUTOMATIC COPIES",store.data.diamonds)
	var body = scroll_body(frame)
	var known: Array = machine.known.duplicate()
	known.sort_custom(func(a,b): return float(Duplication.copy_value(a))/Duplication.duration(a) > float(Duplication.copy_value(b))/Duplication.duration(b))
	if duplication_selected_type not in known: duplication_selected_type = str(known[0]) if not known.is_empty() else ""
	duplication_preview(body,duplication_selected_type)
	var intro = card(body)
	headline(intro,"WORKS WHILE YOU'RE AWAY",23,HudStyle.CYAN,true).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var explanation = text(intro,"Copies repeat automatically. Stores 3 per chamber.\nCollect to make room for more.",18,MUTED)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not known.is_empty():
		var chooser = OptionButton.new()
		chooser.custom_minimum_size.y = 64
		chooser.clip_text = true
		chooser.add_theme_font_size_override("font_size",21)
		for i in range(known.size()):
			var id = str(known[i])
			chooser.add_item("%s · $%s / %ds" % [Balance.ITEMS[id].display_name,cash_text(Duplication.copy_value(id)),Duplication.duration(id)],i)
		chooser.select(known.find(duplication_selected_type))
		chooser.item_selected.connect(func(index: int):
			duplication_selected_type = str(known[index])
			call_deferred("duplication_lab",store))
		body.add_child(chooser)
		text(body,"Original $%s → replica $%s every %ds" % [cash_text(int(Balance.ITEMS[duplication_selected_type].cash_value)),cash_text(Duplication.copy_value(duplication_selected_type)),Duplication.duration(duplication_selected_type)],18,MUTED)
	else:
		text(body,"Escape with loot to unlock its blueprint.",19,MUTED)
	for i in range(Duplication.MAX_SLOTS):
		var slot_index = i
		var slot = card(body)
		var line = row(slot,8)
		var details = column(line,2)
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text(details,"CHAMBER %d" % (i+1),15,HudStyle.CYAN)
		if i >= int(machine.slot_level):
			headline(details,"LOCKED",21,MUTED)
			continue
		var job: Dictionary = machine.jobs[i]
		if job.is_empty():
			headline(details,"CHOOSE A BLUEPRINT",19,PAPER)
			var start_button = blue_button(line,"START AUTO",func(): action_requested.emit("duplicate:%d:%s" % [slot_index,duplication_selected_type]),68)
			start_button.disabled = duplication_selected_type == ""
			start_button.custom_minimum_size.x = 158
		else:
			headline(details,str(Balance.ITEMS[job.type_id].display_name),20,PAPER)
			var timer = text(details,"",15,HudStyle.GREEN)
			timer.add_to_group("duplication_slot_label")
			timer.set_meta("slot_index",i)
			var claim_button = button(line,"",func(): action_requested.emit("duplication_claim:%d" % slot_index),68)
			claim_button.add_to_group("duplication_claim_button")
			claim_button.set_meta("slot_index",i)
			claim_button.custom_minimum_size.x = 158
			claim_button.add_theme_font_size_override("font_size",21)
			var progress = ProgressBar.new()
			progress.custom_minimum_size.y = 10
			progress.show_percentage = false
			progress.add_theme_stylebox_override("background",noise_style(Color("1e072e")))
			progress.add_theme_stylebox_override("fill",noise_style(HudStyle.CYAN))
			progress.add_to_group("duplication_progress")
			progress.set_meta("slot_index",i)
			slot.add_child(progress)
			if duplication_selected_type != job.type_id:
				var swap = blue_button(slot,"USE SELECTED · RESTART CYCLE",func(): action_requested.emit("duplicate:%d:%s" % [slot_index,duplication_selected_type]),40)
				swap.add_theme_font_size_override("font_size",16)
				swap.add_to_group("duplication_swap_button")
				swap.set_meta("slot_index",i)
	if int(machine.slot_level) < Duplication.MAX_SLOTS:
		var cost = Duplication.SLOT_COSTS[int(machine.slot_level)-1]
		var upgrade = blue_button(body,"ADD CHAMBER · $%s" % cash_text(cost),func(): action_requested.emit("duplication_upgrade"),56)
		upgrade.disabled = store.data.wallet < cost
	text(body,"Originals earn full value in heists. Replicas sell for less.\nNew stolen originals unlock better blueprints.",17,MUTED)
	navigation(frame,"",68,store)
	update_duplication_timers(store)

func update_duplication_timers(store: SaveStore) -> void:
	if not is_instance_valid(menu): return
	var now = int(Time.get_unix_time_from_system())
	Duplication.settle(store.data,now)
	for group in ["duplication_progress","duplication_slot_label","duplication_claim_button","duplication_swap_button"]:
		for control in get_tree().get_nodes_in_group(group):
			if not is_instance_valid(control) or not menu.is_ancestor_of(control): continue
			var job: Dictionary = store.data.duplication.jobs[int(control.get_meta("slot_index"))]
			if job.is_empty(): continue
			var full = int(job.stored) >= Duplication.BUFFER_COPIES
			match group:
				"duplication_progress": control.value = 100.0 if full else 100.0*int(job.progress)/Duplication.duration(job.type_id)
				"duplication_slot_label":
					control.text = "%d / 3 COPIES · %s" % [int(job.stored),"STORAGE FULL" if full else "NEXT IN %ds" % Duplication.seconds_left(job,now)]
					if int(job.get("legacy_value",0)) > 0: control.text += "\nOriginal copy: $%d%s" % [int(job.legacy_value)," ready" if now >= int(job.legacy_ready_at) else " in %ds" % (int(job.legacy_ready_at)-now)]
				"duplication_claim_button":
					var earned = Duplication.available_cash(job,now)
					control.disabled = earned <= 0
					control.text = "COLLECT $%s" % cash_text(earned) if earned > 0 else "COPYING…"
				"duplication_swap_button":
					control.disabled = int(job.stored) > 0 or int(job.get("legacy_value",0)) > 0
					if control.disabled: control.text = "COLLECT BEFORE CHANGING"

func duplication_preview(parent: Node, type_id: String) -> void:
	var holder = PanelContainer.new()
	holder.custom_minimum_size.y = 220
	holder.add_theme_stylebox_override("panel", menu_style(Color("2d0b44"), Color("9f55d2"), 18))
	parent.add_child(holder)
	var container = SubViewportContainer.new()
	var vivid := ShaderMaterial.new()
	vivid.shader = preload("res://assets/shaders/vivid_preview.gdshader")
	container.material = vivid
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(container)
	var viewport = SubViewport.new()
	viewport.size = Vector2i(560, 250)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	container.add_child(viewport)
	var stage = Node3D.new()
	viewport.add_child(stage)
	Models.box(stage, Vector3(3.9, 0.25, 2.5), Vector3(0, -0.12, 0), Color("391950"))
	Models.box(stage, Vector3(2.8, 0.14, 1.8), Vector3(0, 0.07, 0), Color("a155d6"))
	for side in [-1.0, 1.0]:
		Models.box(stage, Vector3(0.18, 1.5, 0.2), Vector3(side * 1.55, 0.7, 0), Color("9d7bb4"))
		Models.box(stage, Vector3(0.28, 0.18, 0.34), Vector3(side * 1.55, 1.46, 0), Color("ab53e9"))
	Models.box(stage, Vector3(3.4, 0.16, 0.25), Vector3(0, 1.5, 0), Color("4b355a"))
	if Balance.ITEMS.has(type_id):
		var model = Models.loot(type_id)
		model.scale = Vector3.ONE * 0.9
		model.position = Vector3(0, 0.18, 0)
		stage.add_child(model)
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(3.6, 2.7, 4.3)
	camera.look_at(Vector3(0, 0.55, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.8
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -35, 0)
	light.light_energy = 2.1
	viewport.add_child(light)


