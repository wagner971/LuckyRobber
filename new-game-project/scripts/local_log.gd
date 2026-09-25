class_name LocalLog
extends RefCounted

static var enabled = true

static func tutorial_attempted(profile: String) -> bool:
	var path = "user://onboarding_events.jsonl"
	if not FileAccess.file_exists(path): return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var attempted = false
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty(): continue
		var parser = JSON.new()
		if parser.parse(line) != OK: continue
		var entry = parser.data
		if entry is Dictionary and entry.get("profile", "") == profile and entry.get("event", "") == "tutorial_started": attempted = true
	return attempted

# Onboarding telemetry stays available in DEV even when verbose gameplay logs
# are disabled. It contains no run checkpoint or claim on unbanked money.
static func onboarding_event(kind: String, details: Dictionary) -> void:
	var record = details.duplicate(true)
	record.event = kind
	record.time = Time.get_datetime_string_from_system()
	var path = "user://onboarding_events.jsonl"
	var file = FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
	if file == null: return
	if file.get_length() > 1048576:
		file.close()
		DirAccess.rename_absolute(path, "user://onboarding_events.previous.jsonl")
		file = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(record))

static func event(kind: String, details: Dictionary = {}) -> void:
	if not enabled: return
	var record = details.duplicate(true)
	record["event"] = kind
	record["time"] = Time.get_datetime_string_from_system()
	var line = JSON.stringify(record)
	print(line)
	var path = "user://events.jsonl"
	if FileAccess.file_exists(path):
		var existing = FileAccess.open(path, FileAccess.READ)
		if existing != null and existing.get_length() > 1048576:
			existing.close()
			DirAccess.rename_absolute(path, "user://events.previous.jsonl")
	var file = FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(line)
