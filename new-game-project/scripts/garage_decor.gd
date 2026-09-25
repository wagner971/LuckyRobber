class_name GarageDecor
extends Node3D

const CATALOG := {
	"sofa": {"name":"Sofa", "price":2000, "description":"Your first proper place to unwind."},
	"tv": {"name":"Big TV", "price":4000, "description":"A big screen for your lounge corner."},
	"arcade": {"name":"Arcade Machine", "price":7500, "description":"One more game after one more heist."},
	"pool": {"name":"Pool Table", "price":12000, "description":"The centerpiece of your getaway lounge."},
	"jukebox": {"name":"Jukebox", "price":15000, "description":"A little neon. A lot of character."},
	"safe": {"name":"Giant Safe", "price":25000, "description":"Big enough to make a statement."},
	"statue": {"name":"Gold Statue", "price":40000, "description":"A golden tribute to your success."},
	"floor": {"name":"Luxury Garage Floor", "price":50000, "description":"Polished tiles with champagne trim."},
}

var props: Node3D

func build(owned: Array, preview_id: String = "") -> void:
	for child in get_children(): child.free()
	name = "OwnedGarage"
	var luxury := "floor" in owned or preview_id == "floor"
	Models.box(self,Vector3(9,0.18,7),Vector3(0,-0.13,0),Color("23152d") if luxury else Color("584863")).name = "GarageFloor"
	Models.box(self,Vector3(9,2.9,0.17),Vector3(0,1.35,-3.4),Color("402850"))
	Models.box(self,Vector3(0.17,1.3,7),Vector3(-4.4,0.55,0),Color("483058"))
	Models.box(self,Vector3(0.17,0.35,7),Vector3(4.4,0.12,0),Color("483058"))
	# Closed shutter and one warm bulb establish a modest working garage.
	for i in range(10): Models.box(self,Vector3(2.1,0.19,0.035),Vector3(0,0.14+i*0.22,-3.29),Color("573e68"))
	Models.box(self,Vector3(0.04,0.46,0.04),Vector3(0,2.58,-2.95),Color("291735"))
	var bulb := Models.ball(self,Vector3(0.23,0.24,0.23),Vector3(0,2.29,-2.95),Color("ffdda4"))
	var material := bulb.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = Color("ffba6c")
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0,2.2,-2.6)
	lamp.light_color = Color("ffce92")
	lamp.light_energy = 1.4
	lamp.omni_range = 6
	add_child(lamp)
	Models.box(self,Vector3(1.3,0.12,0.74),Vector3(-2.75,0.72,1.65),Color("92734e")).name = "StarterTable"
	for x in [-3.25,-2.25]:
		for z in [1.4,1.9]: Models.box(self,Vector3(0.09,0.68,0.09),Vector3(x,0.34,z),Color("34293b"))
	if luxury:
		for x in range(-4,5): Models.box(self,Vector3(0.016,0.009,6.7),Vector3(x,-0.031,0),Color("61536a"))
		for z in range(-3,4): Models.box(self,Vector3(8.7,0.009,0.016),Vector3(0,-0.031,z),Color("61536a"))
		for x in [-4.1,4.1]: Models.box(self,Vector3(0.055,0.012,6.4),Vector3(x,-0.022,0),Color("d2b979"))
		for z in [-3.15,3.15]: Models.box(self,Vector3(8.2,0.012,0.055),Vector3(0,-0.022,z),Color("d2b979"))
	props = Node3D.new()
	props.name = "PurchasedFurniture"
	add_child(props)
	for id in CATALOG:
		if id == "floor" or (id not in owned and id != preview_id): continue
		var prop := make_prop(id)
		prop.name = "Decor_" + id
		props.add_child(prop)
		match id:
			"sofa": prop.position = Vector3(-2.7,0,-0.35); prop.rotation.y = -PI/2
			"tv": prop.position = Vector3(-3.85,1.15,-0.75); prop.rotation.y = PI/3
			"arcade": prop.position = Vector3(-2.95,0,-2.5)
			"jukebox": prop.position = Vector3(-1.5,0,-2.6)
			"safe": prop.position = Vector3(3.05,0,-2.45)
			"statue": prop.position = Vector3(1.55,0,-2.55)
			"pool": prop.position = Vector3(0,0,-0.25)
		if id == preview_id and id not in owned:
			prop.set_meta("unowned_preview",true)

static func make_prop(id: String) -> Node3D:
	if id == "sofa": return Models.loot("sofa")
	if id == "arcade": return Models.loot("arcade_machine")
	var prop := Node3D.new()
	match id:
		"safe":
			var safe := Models.loot("small_safe")
			prop.add_child(safe)
			safe.scale = Vector3(1.4,1.65,1.3)
		"tv":
			Models.box(prop,Vector3(1.9,1.08,0.12),Vector3.ZERO,Color("20102b"))
			Models.box(prop,Vector3(1.72,0.9,0.025),Vector3(0,0,0.075),Color("9639d6"))
			Models.box(prop,Vector3(1.18,0.04,0.028),Vector3(-0.13,-0.26,0.095),Color("d8b0f3"))
		"pool":
			Models.box(prop,Vector3(2.2,0.23,1.35),Vector3(0,0.82,0),Color("644b3d"))
			Models.box(prop,Vector3(1.98,0.035,1.12),Vector3(0,0.955,0),Color("287e68"))
			for x in [-0.91,0.91]:
				for z in [-0.48,0.48]:
					Models.box(prop,Vector3(0.16,0.71,0.16),Vector3(x,0.36,z),Color("3e302b"))
					Models.cylinder(prop,0.09,0.012,Vector3(x,0.979,z),Color("1c1025"))
			for i in range(5): Models.ball(prop,Vector3.ONE*0.08,Vector3(0.12+i%3*0.09,1.008,-0.06+i/3*0.09),[Color("ffc74b"),Color("e7efed"),Color("de5b66")][i%3])
			Models.box(prop,Vector3(1.6,0.025,0.025),Vector3(-0.2,0.98,0.48),Color("e6c38a")).rotation.y = -0.1
		"jukebox":
			Models.box(prop,Vector3(0.88,1.28,0.55),Vector3(0,0.66,0),Color("633a55"))
			Models.ball(prop,Vector3(0.88,0.65,0.55),Vector3(0,1.3,0),Color("dbab65"))
			Models.box(prop,Vector3(0.68,0.69,0.045),Vector3(0,0.60,0.30),Color("2e193d"))
			for x in [-0.35,0.35]: Models.box(prop,Vector3(0.065,1.12,0.055),Vector3(x,0.81,0.31),Color("6fe4cf"))
			for y in [0.38,0.5,0.62,0.74]: Models.box(prop,Vector3(0.51,0.03,0.055),Vector3(0,y,0.34),Color("b8a783"))
			Models.box(prop,Vector3(0.45,0.27,0.06),Vector3(0,1.18,0.34),Color("ffe0a0"))
		"statue":
			Models.box(prop,Vector3(0.92,0.36,0.82),Vector3(0,0.18,0),Color("301840"))
			var thief := Models.thief()
			prop.add_child(thief)
			thief.position.y = 0.36
			thief.scale = Vector3.ONE * 0.7
			# The same recognizable thief silhouette, cast entirely in gold.
			for mesh in thief.find_children("*","MeshInstance3D",true,false):
				mesh.material_override = Models.material(Color("edc267"))
				mesh.material_override.metallic = 0.45
				mesh.material_override.roughness = 0.28
	return prop
