class_name HudStyle
extends RefCounted

const BLUE = Color("6607a8")
const EDGE = Color("a627ff")
const CYAN = Color("dfb5ff")
const GREEN = Color("21ff9e")
const GOLD = Color("ffcf19")
const RED = Color("ff5c61")
# Action and reward colors stay semantic across menus and the in-game HUD.
const PLAY = GREEN
const MONEY = GOLD
const FINAL = Color("ff951b")
const SPECIAL = Color("b578ff")
const RARE = Color("ff4bae")
const INFO = CYAN
const ICONS = {
	"lock": preload("res://assets/hud/lock.svg"),
	"clock": preload("res://assets/hud/clock.png"),
	"cash": preload("res://assets/hud/cash.png"),
	"box": preload("res://assets/hud/box.png"),
	"noise": preload("res://assets/hud/noise.png"),
	"warning": preload("res://assets/hud/warning.png"),
	"strength": preload("res://assets/ui/menu_violet/powerups/strength.png"),
	"pause": preload("res://assets/hud/pause.svg"),
	"play": preload("res://assets/hud/play.svg"),
	"escape": preload("res://assets/hud/escape.svg"),
	"drop": preload("res://assets/hud/drop.svg"),
	"hand": preload("res://assets/hud/hand.svg"),
}

static func plate(color: Color = BLUE, edge: Color = EDGE, radius: int = 20) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = edge
	style.set_border_width_all(2)
	style.border_width_bottom = 5
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(12)
	style.shadow_color = Color("190725b3")
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 4)
	return style

static func track(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(5)
	return style

static func icon(parent: Node, key: String, width: float = 52) -> TextureRect:
	var image = TextureRect.new()
	image.texture = ICONS[key]
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(width, width)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

static func action(button: Button, key: String, color: Color, edge: Color, font: Font) -> void:
	button.icon = ICONS[key]
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 46)
	button.add_theme_constant_override("h_separation", 12)
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", Color("ffffff"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color("2a0841"))
	button.add_theme_constant_override("outline_size", 6)
	button.add_theme_stylebox_override("normal", plate(color, edge))
	button.add_theme_stylebox_override("hover", plate(color.lightened(0.12), edge.lightened(0.2)))
	button.add_theme_stylebox_override("pressed", plate(color.darkened(0.15), edge.darkened(0.1)))

static func pass_through(node: Node) -> void:
	# Only actual buttons intercept touches; decoration must allow the joystick.
	if node is Control and not node is Button:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): pass_through(child)
