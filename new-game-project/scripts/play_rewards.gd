class_name PlayRewards
extends RefCounted

# Cash vehicles and other purchasable cosmetics share the daily rotation.
# New paid catalog entries join automatically; earned rewards stay in the wardrobe.
const SHOP_SIZE := 3

static func shop_pool() -> Array[String]:
	var vehicles: Array[String] = []
	var other: Array[String] = []
	for id in Balance.COSMETICS:
		var config: Dictionary = Balance.COSMETICS[id]
		if config.reward != "" or (Balance.cosmetic_price(id) <= 0 and int(config.get("gem_price", 0)) <= 0): continue
		if config.has("vehicle_style"): vehicles.append(id)
		else: other.append(id)
	var pool: Array[String] = []
	for i in range(maxi(vehicles.size(), other.size())):
		if i < vehicles.size(): pool.append(vehicles[i])
		if i < other.size(): pool.append(other[i])
	return pool

static func shop_day(now: int = -1) -> int:
	if now < 0: now = int(Time.get_unix_time_from_system())
	return maxi(0, now / 86400)

static func today_shop(now: int = -1) -> Array[String]:
	var today: int = shop_day(now)
	var selected: Array[String] = []
	var pool := shop_pool()
	for offset in range(mini(SHOP_SIZE, pool.size())):
		selected.append(pool[(today + offset) % pool.size()])
	return selected

static func shop_refresh_remaining(now: int = -1) -> int:
	if now < 0: now = int(Time.get_unix_time_from_system())
	return (shop_day(now) + 1) * 86400 - now


