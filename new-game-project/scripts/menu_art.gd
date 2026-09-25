class_name MenuArt
extends RefCounted

static var cache: Dictionary = {}

static func texture(key: String) -> Texture2D:
	if cache.has(key): return cache[key]
	var source := load("res://assets/ui/menu_violet/" + key + ".png") as Texture2D
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	# Fit the supplied artwork, not its transparent export padding.
	atlas.region = Rect2(source.get_image().get_used_rect())
	atlas.filter_clip = true
	cache[key] = atlas
	return atlas
