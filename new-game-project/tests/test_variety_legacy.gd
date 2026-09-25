extends "res://tests/test_challenge_v2.gd"

func test() -> void:
	LocalLog.enabled = false
	test_v2_migration()
	print("LEGACY MIGRATION SUMMARY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
