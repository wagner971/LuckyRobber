extends "res://tests/test_balance_v1.gd"

func test() -> void:
	LocalLog.enabled = false
	await test_settlement()
	print("SETTLEMENT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
