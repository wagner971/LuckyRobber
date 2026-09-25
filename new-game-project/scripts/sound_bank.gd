class_name SoundBank
extends Node

# PLACEHOLDER SFX — REPLACE BEFORE FINAL RELEASE. Files live in assets/sfx.
const MAX_VOICES := 3
const MIX_DB := {
	"pickup_light": -15.0, "pickup_heavy": -12.0,
	"impact_light": -13.0, "impact_medium": -10.0,
	"impact_heavy": -6.0, "impact_very_heavy": -4.0,
	"cash_burst": -11.0, "cash_collect": -10.0,
	"noise_tick": -18.0, "noise_warning": -11.0,
	"alarm_trigger": -5.0, "timer_tick": -16.0,
	"escape_success": -6.0, "busted": -8.0,
	"upgrade_purchase": -10.0, "strength_unlock": -7.0,
	"special_reveal": -9.0, "drop": -14.0, "blocked": -18.0,
}
const ALIASES := {
	"pickup": "pickup_light", "load": "cash_burst", "wham": "impact_medium",
	"noise": "noise_tick", "alarm": "alarm_trigger", "tick": "timer_tick",
	"success": "escape_success", "failure": "busted", "upgrade": "upgrade_purchase",
	"security_spotted": "blocked",
}

var clips: Dictionary = {}
var groups: Dictionary = {}
var active_players: Array[AudioStreamPlayer] = []
var volume := 1.0
var played: Dictionary = {}
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()
	for kind in MIX_DB:
		var files: Array[AudioStream] = []
		var number := 3 if kind in ["pickup_light", "pickup_heavy"] else (2 if kind.begins_with("impact_") else 1)
		for variant in range(1, number + 1):
			var filename: String = "%s_%d" % [kind, variant] if number > 1 else kind
			var stream: AudioStream = load("res://assets/sfx/%s.wav" % filename)
			if stream != null: files.append(stream)
		if files.is_empty(): continue
		groups[kind] = files
		clips[kind] = files[0]
	for alias in ALIASES:
		if clips.has(ALIASES[alias]): clips[alias] = clips[ALIASES[alias]]

func set_sfx_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	for player in active_players:
		if is_instance_valid(player): player.volume_db = MIX_DB.get(player.get_meta("sfx_kind", "pickup_light"), -12.0) + linear_to_db(maxf(volume, 0.001))

func play(kind: String) -> void:
	if volume <= 0.001: return
	var category: String = ALIASES.get(kind, kind)
	if not groups.has(category): return
	if active_players.size() >= MAX_VOICES:
		var oldest: AudioStreamPlayer = active_players.pop_front()
		if is_instance_valid(oldest):
			oldest.stop()
			oldest.queue_free()
	var options: Array = groups[category]
	var player := AudioStreamPlayer.new()
	player.stream = options[random.randi_range(0, options.size() - 1)]
	player.volume_db = MIX_DB[category] + linear_to_db(maxf(volume, 0.001))
	player.pitch_scale = random.randf_range(0.94, 1.06) if category in ["pickup_light", "pickup_heavy", "impact_light", "impact_medium", "impact_heavy", "impact_very_heavy"] else 1.0
	player.set_meta("sfx_kind", category)
	add_child(player)
	active_players.append(player)
	played[category] = int(played.get(category, 0)) + 1
	player.finished.connect(func():
		active_players.erase(player)
		player.queue_free()
	)
	player.play()
