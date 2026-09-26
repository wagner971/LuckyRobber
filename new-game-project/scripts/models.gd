class_name Models
extends RefCounted

static func material(color: Color, _profile: ToonMaterial.Profile = ToonMaterial.Profile.PROP) -> StandardMaterial3D:
	var surface := StandardMaterial3D.new()
	surface.albedo_color = color
	surface.roughness = 1.0
	surface.metallic = 0.0
	surface.metallic_specular = 0.0
	return surface

static func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh = BoxMesh.new()
	mesh.size = size
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material(color)
	node.position = at
	parent.add_child(node)
	return node

static func ball(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh = SphereMesh.new()
	mesh.radial_segments = 12
	mesh.rings = 6
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.scale = size
	node.position = at
	node.material_override = material(color)
	parent.add_child(node)
	return node

static func cylinder(parent: Node3D, radius: float, height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material(color)
	parent.add_child(node)
	return node

# Headline loot reads bigger than any decor (Dracula's Castle hierarchy). Scaling lives on
# an inner node, so pickup/highlight tweens on the returned root keep working unchanged.
# Pickup radius and gameplay stay untouched; only the silhouette grows.
# Very large: Coffin, Throne. Large: Organ, Mirror. Medium: Gargoyle, Relic Chest, Bat Idol,
# Portrait. Small (unscaled): Crown, Chalice, Candelabrum.
const LOOT_SCALE = {
	"canopic_jar": 1.14, "pharaoh_mask": 1.28, "treasure_chest": 1.1,
	"giant_scarab": 1.15, "pharaoh_bust": 1.16, "obelisk_fragment": 1.1,
	"giant_anubis": 1.12, "golden_throne": 1.2, "sarcophagus": 1.13,
	"dracula_coffin": 1.4, "vampire_throne": 1.5, "pipe_organ": 1.35,
	"gothic_mirror": 1.3, "gargoyle_statue": 1.1, "relic_chest": 1.1,
	"vampire_portrait": 1.3, "time_machine": 1.1, "ancient_relic": 1.13,
	"grand_piano": 1.12,
}

static func loot(type_id: String) -> Node3D:
	var body = loot_body(type_id)
	if not LOOT_SCALE.has(type_id): return body
	body.scale = Vector3.ONE * LOOT_SCALE[type_id]
	# The Coffin lies lengthwise toward the breach so its bigger body clears the Crypt walls.
	if type_id == "dracula_coffin": body.rotation_degrees.y = 90
	if type_id == "sarcophagus": body.rotation_degrees.y = 90
	var holder = Node3D.new()
	holder.add_child(body)
	return holder

static func loot_body(type_id: String) -> Node3D:
	var root = Node3D.new()
	var cream = Color("f0eedf")
	var dark = Color("253748")
	var mint = Color("72d9bb")
	match type_id:
		"floor_lamp":
			cylinder(root,0.30,0.075,Vector3(0,0.05,0),dark)
			cylinder(root,0.045,1.25,Vector3(0,0.69,0),Color("a78a58"))
			var shade = cylinder(root,0.4,0.42,Vector3(0,1.40,0),Color("efcf91"))
			(shade.mesh as CylinderMesh).top_radius = 0.24
			cylinder(root,0.40,0.028,Vector3(0,1.195,0),cream)
			cylinder(root,0.245,0.035,Vector3(0,1.62,0),Color("c8a367"))
		"table_fan":
			box(root,Vector3(0.46,0.065,0.35),Vector3(0,0.06,0),Color("719b94"))
			box(root,Vector3(0.075,0.32,0.085),Vector3(0,0.22,0),cream)
			var housing = cylinder(root,0.315,0.11,Vector3(0,0.58,0),Color("416c73"))
			housing.rotation_degrees.x = 90
			var face = cylinder(root,0.28,0.025,Vector3(0,0.58,0.065),Color("aac4b7"))
			face.rotation_degrees.x = 90
			for i in range(3):
				var blade = box(root,Vector3(0.115,0.32,0.025),Vector3(0,0.58,0.09),Color("dce5d4"))
				blade.rotation.z = i*TAU/3
			var hub = cylinder(root,0.07,0.04,Vector3(0,0.58,0.115),dark)
			hub.rotation_degrees.x = 90
			for i in range(4):
				var guard = box(root,Vector3(0.018,0.59,0.016),Vector3(0,0.58,0.145),Color("73958e"))
				guard.rotation.z = i*PI/4
		"laptop":
			box(root,Vector3(0.78,0.055,0.51),Vector3(0,0.05,0),Color("b7c5c7"))
			box(root,Vector3(0.67,0.012,0.24),Vector3(0,0.085,-0.03),dark)
			for x in [-0.24,-0.12,0.0,0.12,0.24]:
				for z in [-0.1,0.0]: box(root,Vector3(0.08,0.005,0.06),Vector3(x,0.094,z),Color("69848f"))
			box(root,Vector3(0.18,0.012,0.09),Vector3(0,0.085,0.16),Color("829aa1"))
			box(root,Vector3(0.78,0.48,0.05),Vector3(0,0.30,-0.23),dark)
			box(root,Vector3(0.66,0.36,0.015),Vector3(0,0.31,-0.197),Color("469ba9"))
			box(root,Vector3(0.35,0.035,0.008),Vector3(-0.09,0.22,-0.184),mint)
		"microwave":
			box(root,Vector3(0.86,0.49,0.57),Vector3(0,0.28,0),cream)
			box(root,Vector3(0.61,0.36,0.025),Vector3(-0.085,0.29,0.30),dark)
			box(root,Vector3(0.45,0.23,0.015),Vector3(-0.10,0.29,0.319),Color("526e74"))
			box(root,Vector3(0.035,0.25,0.035),Vector3(0.18,0.29,0.338),Color("b7c8c7"))
			box(root,Vector3(0.10,0.065,0.025),Vector3(0.32,0.39,0.303),mint)
			for y in [0.19,0.27]:
				var knob = cylinder(root,0.035,0.026,Vector3(0.32,y,0.32),dark)
				knob.rotation_degrees.x = 90
		"small_tv", "monitor":
			var s = 1.0 if type_id == "small_tv" else 0.7
			box(root, Vector3(1.18, 0.78, 0.18) * s, Vector3(0, 0.66 * s, 0), dark)
			box(root, Vector3(1.02, 0.60, 0.02) * s, Vector3(0, 0.68 * s, 0.10 * s), Color("47b8cb"))
			box(root, Vector3(0.72, 0.07, 0.025) * s, Vector3(-0.08, 0.50 * s, 0.12 * s), mint)
			box(root, Vector3(0.10, 0.27, 0.12), Vector3(0, 0.2, 0), dark)
			box(root, Vector3(0.55, 0.07, 0.38), Vector3(0, 0.06, 0), dark)
		"chair":
			box(root, Vector3(0.64, 0.13, 0.64), Vector3(0, 0.48, 0), Color("e6ad62"))
			box(root, Vector3(0.64, 0.58, 0.12), Vector3(0, 0.81, -0.26), Color("f6c276"))
			for x in [-0.23, 0.23]:
				for z in [-0.23, 0.23]: box(root, Vector3(0.08, 0.44, 0.08), Vector3(x, 0.23, z), dark)
		"printer":
			box(root, Vector3(0.83, 0.47, 0.65), Vector3(0, 0.30, 0), cream)
			box(root, Vector3(0.64, 0.08, 0.5), Vector3(0, 0.57, -0.04), dark)
			box(root, Vector3(0.56, 0.05, 0.32), Vector3(0, 0.26, 0.44), Color.WHITE)
			box(root, Vector3(0.09, 0.04, 0.1), Vector3(0.28, 0.56, 0.22), mint)
		"rubber_duck":
			var yellow := Color("ffda4c")
			ball(root, Vector3(0.60, 0.39, 0.48), Vector3(0, 0.22, -0.04), yellow)
			ball(root, Vector3(0.34, 0.35, 0.34), Vector3(0, 0.45, 0.18), yellow)
			box(root, Vector3(0.22, 0.08, 0.19), Vector3(0, 0.37, 0.39), Color("f58c39"))
			for side in [-1.0, 1.0]:
				ball(root, Vector3(0.22, 0.13, 0.28), Vector3(side * 0.25, 0.25, -0.06), Color("efc73d"))
				ball(root, Vector3(0.035, 0.04, 0.035), Vector3(side * 0.12, 0.51, 0.32), dark)
		"fridge":
			box(root, Vector3(1.0, 1.85, 0.86), Vector3(0, 0.95, 0), Color("b9e1d9"))
			box(root, Vector3(0.94, 0.55, 0.06), Vector3(0, 1.55, 0.46), cream)
			box(root, Vector3(0.94, 1.05, 0.06), Vector3(0, 0.70, 0.46), cream)
			for y in [0.96, 1.43]: box(root, Vector3(0.07, 0.25, 0.08), Vector3(-0.32, y, 0.53), dark)
			box(root, Vector3(0.19, 0.21, 0.012), Vector3(0.19, 1.61, 0.5), Color("ffbe5c"))
		"toilet":
			cylinder(root, 0.24, 0.40, Vector3(0, 0.22, 0.12), cream)
			ball(root, Vector3(0.83, 0.28, 1.0), Vector3(0, 0.48, 0.18), cream)
			ball(root, Vector3(0.53, 0.035, 0.64), Vector3(0, 0.75, 0.19), dark)
			box(root, Vector3(0.70, 0.85, 0.32), Vector3(0, 0.59, -0.37), cream)
			box(root, Vector3(0.15, 0.07, 0.08), Vector3(0.21, 0.86, -0.18), mint)
		"small_safe":
			box(root, Vector3(0.94, 1.05, 0.90), Vector3(0, 0.55, 0), dark)
			box(root, Vector3(0.77, 0.85, 0.04), Vector3(0, 0.55, 0.48), Color("608090"))
			var wheel = cylinder(root, 0.21, 0.06, Vector3(0.05, 0.57, 0.54), cream)
			wheel.rotation_degrees.x = 90
			box(root, Vector3(0.32, 0.06, 0.07), Vector3(0.05, 0.57, 0.60), dark)
		"tool_cabinet":
			box(root, Vector3(0.72, 0.87, 0.50), Vector3(0, 0.45, 0), Color("bb514b"))
			box(root, Vector3(0.77, 0.10, 0.55), Vector3(0, 0.92, 0), Color("394a56"))
			for y in [0.23, 0.46, 0.69]:
				box(root, Vector3(0.62, 0.025, 0.04), Vector3(0, y, 0.27), Color("773b3f"))
				box(root, Vector3(0.23, 0.045, 0.05), Vector3(0, y + 0.07, 0.30), Color("e0b77e"))
			for x in [-0.25, 0.25]:
				var wheel = cylinder(root, 0.085, 0.09, Vector3(x, 0.07, 0), dark)
				wheel.rotation_degrees.x = 90
		"bathtub":
			box(root, Vector3(1.40, 0.48, 0.82), Vector3(0, 0.27, 0), Color("e7eee9"))
			box(root, Vector3(1.22, 0.035, 0.62), Vector3(0, 0.52, 0), Color("9fcbd0"))
			for x in [-0.66, 0.66]:
				box(root, Vector3(0.055, 0.14, 0.87), Vector3(x, 0.53, 0), Color("fbf7e9"))
			for z in [-0.39, 0.39]:
				box(root, Vector3(1.42, 0.14, 0.055), Vector3(0, 0.53, z), Color("fbf7e9"))
			box(root, Vector3(0.08, 0.25, 0.08), Vector3(0.42, 0.66, -0.28), Color("718c9a"))
			box(root, Vector3(0.22, 0.045, 0.07), Vector3(0.34, 0.77, -0.28), Color("718c9a"))
		"sofa":
			box(root, Vector3(1.62, 0.36, 0.72), Vector3(0, 0.31, 0), Color("537f70"))
			box(root, Vector3(1.66, 0.69, 0.19), Vector3(0, 0.60, -0.34), Color("436c60"))
			for x in [-0.72, 0.72]:
				box(root, Vector3(0.17, 0.42, 0.76), Vector3(x, 0.48, 0), Color("436c60"))
			for x in [-0.36, 0.36]:
				box(root, Vector3(0.67, 0.12, 0.58), Vector3(x, 0.55, 0.04), Color("6e9c86"))
			for x in [-0.59, 0.59]:
				for z in [-0.25, 0.25]: box(root, Vector3(0.10, 0.12, 0.10), Vector3(x, 0.06, z), dark)
		"pink_flamingo":
			var pink = Color("fc77aa")
			ball(root, Vector3(0.70, 0.38, 0.85), Vector3(0, 0.75, 0), pink)
			cylinder(root, 0.075, 0.70, Vector3(0.0, 1.10, 0.26), pink)
			ball(root, Vector3(0.33, 0.20, 0.36), Vector3(0, 1.48, 0.28), pink)
			box(root, Vector3(0.13, 0.12, 0.3), Vector3(0, 1.43, 0.49), dark)
			for x in [-0.13, 0.13]: cylinder(root, 0.035, 0.63, Vector3(x, 0.33, 0), Color("f7bb6c"))
			cylinder(root, 0.30, 0.05, Vector3(0, 0.03, 0), pink)
		"gaming_pc":
			box(root, Vector3(0.65, 1.05, 0.75), Vector3(0, 0.54, 0), dark)
			box(root, Vector3(0.48, 0.89, 0.03), Vector3(0, 0.55, 0.40), Color("172639"))
			for y in [0.27, 0.55, 0.83]:
				var fan = cylinder(root, 0.14, 0.035, Vector3(0, y, 0.43), mint)
				fan.rotation_degrees.x = 90
			box(root, Vector3(0.025, 0.70, 0.45), Vector3(0.34, 0.58, 0), Color("527b98"))
		"arcade_machine":
			box(root, Vector3(0.96, 1.95, 0.80), Vector3(0, 0.98, -0.05), Color("8756a5"))
			box(root, Vector3(0.79, 0.62, 0.08), Vector3(0, 1.31, 0.39), dark)
			box(root, Vector3(0.62, 0.43, 0.02), Vector3(0, 1.33, 0.44), mint)
			box(root, Vector3(1.0, 0.15, 0.50), Vector3(0, 0.91, 0.43), Color("ffc45a"))
			cylinder(root, 0.045, 0.20, Vector3(-0.22, 1.08, 0.48), dark)
			ball(root, Vector3(0.13, 0.08, 0.13), Vector3(-0.22, 1.20, 0.48), Color("ff7070"))
			box(root, Vector3(0.75, 0.18, 0.035), Vector3(0, 1.80, 0.39), Color("ffcf69"))
		"vending_machine":
			box(root, Vector3(1.1, 2.0, 0.9), Vector3(0, 1.02, 0), Color("bf636e"))
			box(root, Vector3(0.75, 1.20, 0.04), Vector3(-0.09, 1.30, 0.47), dark)
			for x in [-0.29, -0.06, 0.17]:
				for y in [0.87, 1.24, 1.61]: cylinder(root, 0.07, 0.20, Vector3(x, y, 0.53), mint if x < 0 else Color("ffcf69"))
			box(root, Vector3(0.70, 0.22, 0.04), Vector3(0, 0.33, 0.47), dark)
			box(root, Vector3(0.12, 0.31, 0.06), Vector3(0.44, 0.94, 0.48), cream)
		"piano", "grand_piano":
			box(root, Vector3(1.7, 1.23, 0.72), Vector3(0, 0.94, -0.18), Color("4c3449") if type_id == "piano" else Color("1d1720"))
			box(root, Vector3(1.8, 0.15, 0.66), Vector3(0, 0.77, 0.40), dark)
			for i in range(14):
				box(root, Vector3(0.105, 0.06, 0.45), Vector3(-0.72 + i * 0.11, 0.88, 0.44), cream)
				if i % 7 not in [2, 6]: box(root, Vector3(0.06, 0.06, 0.26), Vector3(-0.68 + i * 0.11, 0.94, 0.35), dark)
			for x in [-0.65, 0.65]: box(root, Vector3(0.16, 0.65, 0.2), Vector3(x, 0.34, 0.46), dark)
		"large_statue":
			var stone = Color("b9c5d0")
			box(root, Vector3(1.1, 0.32, 1.1), Vector3(0, 0.17, 0), dark)
			for x in [-0.2, 0.2]: cylinder(root, 0.15, 0.9, Vector3(x, 0.76, 0), stone)
			box(root, Vector3(0.83, 0.88, 0.43), Vector3(0, 1.49, 0), stone)
			ball(root, Vector3(0.59, 0.39, 0.59), Vector3(0, 2.21, 0), stone)
			box(root, Vector3(1.35, 0.22, 0.23), Vector3(0, 1.83, 0), stone)
			cylinder(root, 0.12, 1.3, Vector3(0.64, 1.6, 0), Color("d0a657"))
		"jeweled_horse_statue":
			var stone = Color("b3bdc8")
			box(root, Vector3(1.8, 0.25, 1.3), Vector3(0, 0.13, 0), dark)
			for x in [-0.42, 0.42]:
				for z in [-0.37, 0.37]:
					box(root, Vector3(0.18, 0.87, 0.2), Vector3(x, 0.68, z), stone)
			box(root, Vector3(1.0, 0.58, 0.7), Vector3(0, 1.32, 0), stone)
			box(root, Vector3(0.38, 0.75, 0.36), Vector3(0, 1.77, -0.43), stone)
			box(root, Vector3(0.4, 0.29, 0.54), Vector3(0, 2.14, -0.64), stone)
			for x in [-0.13, 0.13]:
				box(root, Vector3(0.11, 0.29, 0.12), Vector3(x, 2.42, -0.57), stone)
				ball(root, Vector3(0.065, 0.065, 0.065), Vector3(x, 2.18, -0.92), Color("5ec9eb"))
			box(root, Vector3(0.28, 0.18, 0.4), Vector3(0, 1.78, 0.43), Color("6b8a9e"))
			box(root, Vector3(0.78, 0.12, 0.46), Vector3(0, 1.69, 0), Color("d3a755"))
			for x in [-0.35, 0.35]: ball(root, Vector3(0.12, 0.12, 0.12), Vector3(x, 1.71, 0.13), Color("5edbef"))
		"museum_artifact":
			cylinder(root, 0.70, 0.18, Vector3(0, 0.10, 0), Color("4a5368"))
			cylinder(root, 0.51, 0.46, Vector3(0, 0.38, 0), Color("d4b66f"))
			var lower = CylinderMesh.new()
			lower.top_radius = 0.72
			lower.bottom_radius = 0.05
			lower.height = 0.68
			lower.radial_segments = 8
			var lower_gem = MeshInstance3D.new()
			lower_gem.mesh = lower
			lower_gem.material_override = material(Color("55cdd8"))
			lower_gem.position.y = 1.02
			root.add_child(lower_gem)
			var upper = CylinderMesh.new()
			upper.top_radius = 0.42
			upper.bottom_radius = 0.72
			upper.height = 0.52
			upper.radial_segments = 8
			var upper_gem = MeshInstance3D.new()
			upper_gem.mesh = upper
			upper_gem.material_override = material(Color("b4f5f1"))
			upper_gem.position.y = 1.62
			root.add_child(upper_gem)
			box(root, Vector3(0.30, 0.06, 0.30), Vector3(0, 1.91, 0), Color("eafff4"))
		"time_machine":
			var steel = Color("49586d")
			var bronze = Color("cb9a59")
			box(root, Vector3(1.68, 0.35, 1.95), Vector3(0, 0.20, 0), steel)
			box(root, Vector3(1.46, 0.08, 1.70), Vector3(0, 0.41, 0), bronze)
			for i in range(8):
				var angle = TAU * float(i) / 8.0
				var ring_segment = box(root, Vector3(0.84, 0.26, 0.24), Vector3(cos(angle) * 0.83, 0.77, sin(angle) * 0.83), steel)
				ring_segment.rotation.y = -angle + PI / 2.0
				box(root, Vector3(0.10, 0.12, 0.10), Vector3(cos(angle) * 0.83, 0.95, sin(angle) * 0.83), Color("77e3e4"))
			var core = ball(root, Vector3(0.61, 0.68, 0.61), Vector3(0, 0.87, 0), Color("6ddce2"))
			core.name = "ChronoCore"
			box(root, Vector3(0.35, 0.19, 0.14), Vector3(0, 0.63, 1.06), bronze)
		"ancient_relic":
			var gold = Color("edc767")
			cylinder(root, 0.45, 0.13, Vector3(0, 0.07, 0), Color("5b565a"))
			box(root, Vector3(0.37, 0.36, 0.33), Vector3(0, 0.37, 0), gold)
			ball(root, Vector3(0.30, 0.32, 0.30), Vector3(0, 0.77, 0), Color("66b9ae"))
			for side in [-1, 1]:
				box(root, Vector3(0.14, 0.43, 0.13), Vector3(side * 0.29, 0.53, 0), gold)
			box(root, Vector3(0.20, 0.08, 0.09), Vector3(0, 0.75, 0.28), Color("b97744"))
		"lab_microscope", "lab_analyzer", "lab_centrifuge", "lab_server", "lab_robot_arm", "lab_laser", "lab_specimen", "lab_cryo_pod", "lab_quantum_core":
			LabModels.build(root, type_id)
		"pirate_spyglass", "pirate_sextant", "pirate_compass", "pirate_parrot", "pirate_rum", "pirate_cannon", "pirate_anchor", "pirate_wheel", "pirate_chest", "pirate_figurehead":
			PirateModels.build(root, type_id)
		"viking_runestone", "viking_anvil", "viking_shield", "viking_axe", "viking_helmet", "viking_horn", "viking_cauldron", "viking_loom", "viking_throne", "viking_raven":
			VikingModels.build(root,type_id)
		"pub_billiards", "pub_clock", "pub_settee", "pub_register", "pub_beer_engine", "pub_gramophone", "pub_radio", "pub_darts", "pub_tankard", "pub_sign":
			PubModels.build(root,type_id)
		"prehistoric_skull", "prehistoric_saber", "prehistoric_mortar", "prehistoric_hide", "prehistoric_spear", "prehistoric_drum", "prehistoric_amber", "prehistoric_painting", "prehistoric_fur", "prehistoric_necklace":
			PrehistoricModels.build(root,type_id)
		"canopic_jar", "pharaoh_mask", "treasure_chest", "giant_scarab", "pharaoh_bust", "obelisk_fragment", "giant_anubis", "golden_throne", "sarcophagus":
			PyramidModels.build(root, type_id)
		"crown_display":
			var crown_gold = Color("f2c14e")
			box(root, Vector3(0.5, 0.3, 0.5), Vector3(0, 0.15, 0), Color("3a2f40"))
			box(root, Vector3(0.44, 0.08, 0.44), Vector3(0, 0.34, 0), Color("9e1f2a"))
			cylinder(root, 0.17, 0.14, Vector3(0, 0.45, 0), crown_gold)
			for i in range(5):
				var angle = TAU * i / 5.0
				box(root, Vector3(0.06, 0.12, 0.06), Vector3(cos(angle) * 0.15, 0.57, sin(angle) * 0.15), crown_gold)
			ball(root, Vector3(0.08, 0.08, 0.08), Vector3(0, 0.46, 0.17), Color("d0243a"))
		"blood_chalice":
			var chalice_gold = Color("f2c14e")
			cylinder(root, 0.16, 0.05, Vector3(0, 0.03, 0), chalice_gold)
			cylinder(root, 0.04, 0.3, Vector3(0, 0.2, 0), chalice_gold)
			cylinder(root, 0.17, 0.22, Vector3(0, 0.46, 0), chalice_gold)
			cylinder(root, 0.14, 0.03, Vector3(0, 0.57, 0), Color("a0101e"))
		"vampire_portrait":
			box(root, Vector3(0.6, 0.12, 0.4), Vector3(0, 0.06, 0), Color("3a2f40"))
			box(root, Vector3(0.62, 0.8, 0.08), Vector3(0, 0.52, 0), Color("d9a13a"))
			box(root, Vector3(0.48, 0.66, 0.03), Vector3(0, 0.52, 0.05), Color("2a1f33"))
			box(root, Vector3(0.18, 0.2, 0.02), Vector3(0, 0.62, 0.07), Color("e8d9c8"))
			box(root, Vector3(0.2, 0.08, 0.02), Vector3(0, 0.74, 0.075), Color("15101c"))
			box(root, Vector3(0.3, 0.2, 0.02), Vector3(0, 0.4, 0.07), Color("9e1f2a"))
		"relic_chest":
			box(root, Vector3(0.82, 0.44, 0.56), Vector3(0, 0.24, 0), Color("4a2a3a"))
			box(root, Vector3(0.86, 0.2, 0.6), Vector3(0, 0.56, 0), Color("6a3048"))
			for x in [-0.3, 0.3]: box(root, Vector3(0.07, 0.66, 0.62), Vector3(x, 0.35, 0), Color("c9a24a"))
			box(root, Vector3(0.14, 0.14, 0.04), Vector3(0, 0.42, 0.3), Color("c9a24a"))
			box(root, Vector3(0.05, 0.22, 0.03), Vector3(0, 0.58, 0.31), Color("d0243a"))
		"bat_idol":
			var idol = Color("3a3148")
			box(root, Vector3(0.6, 0.18, 0.5), Vector3(0, 0.09, 0), Color("c9a24a"))
			box(root, Vector3(0.26, 0.5, 0.24), Vector3(0, 0.43, 0), idol)
			box(root, Vector3(0.2, 0.16, 0.18), Vector3(0, 0.75, 0), idol)
			for side in [-1, 1]:
				var bat_wing = box(root, Vector3(0.36, 0.3, 0.05), Vector3(side * 0.28, 0.52, -0.02), idol)
				bat_wing.rotation.z = side * 0.35
				box(root, Vector3(0.05, 0.14, 0.05), Vector3(side * 0.07, 0.88, 0), idol)
			for x in [-0.05, 0.05]: box(root, Vector3(0.035, 0.03, 0.02), Vector3(x, 0.77, 0.1), Color("ff3040"))
		"gargoyle_statue":
			var granite = Color("5a6078")
			box(root, Vector3(0.8, 0.26, 0.7), Vector3(0, 0.13, 0), Color("3a3f55"))
			box(root, Vector3(0.42, 0.5, 0.38), Vector3(0, 0.5, 0), granite)
			box(root, Vector3(0.3, 0.28, 0.3), Vector3(0, 0.88, 0.06), granite)
			for side in [-1, 1]:
				var stone_wing = box(root, Vector3(0.42, 0.44, 0.06), Vector3(side * 0.36, 0.72, -0.12), granite)
				stone_wing.rotation.z = side * 0.45
				box(root, Vector3(0.06, 0.14, 0.06), Vector3(side * 0.1, 1.07, 0.02), granite)
			for x in [-0.07, 0.07]: box(root, Vector3(0.05, 0.04, 0.02), Vector3(x, 0.92, 0.22), Color("ff3040"))
		"gothic_mirror":
			var mirror_gold = Color("b9c2d6")
			box(root, Vector3(0.7, 0.22, 0.5), Vector3(0, 0.11, 0), Color("3a2f40"))
			box(root, Vector3(0.62, 1.2, 0.12), Vector3(0, 0.84, 0), mirror_gold)
			ball(root, Vector3(0.62, 0.36, 0.12), Vector3(0, 1.44, 0), mirror_gold)
			box(root, Vector3(0.48, 1.04, 0.03), Vector3(0, 0.84, 0.07), Color("6f6aa8"))
			ball(root, Vector3(0.48, 0.28, 0.03), Vector3(0, 1.36, 0.07), Color("6f6aa8"))
			box(root, Vector3(0.1, 0.8, 0.02), Vector3(-0.1, 0.9, 0.09), Color("b8c0e0"))
		"pipe_organ":
			box(root, Vector3(1.2, 0.7, 0.6), Vector3(0, 0.35, 0.05), Color("5a3422"))
			box(root, Vector3(1.1, 0.06, 0.24), Vector3(0, 0.66, 0.33), Color("f0eedf"))
			for i in range(7):
				var pipe_height = 0.7 + 0.18 * (3 - absi(i - 3))
				cylinder(root, 0.065, pipe_height, Vector3(-0.45 + i * 0.15, 0.7 + pipe_height / 2, -0.12), Color("d9a13a"))
			box(root, Vector3(1.24, 0.12, 0.66), Vector3(0, 0.74, 0.05), Color("4a2c1e"))
		"skull_candelabrum":
			box(root, Vector3(0.36, 0.08, 0.36), Vector3(0, 0.04, 0), Color("3a2f40"))
			cylinder(root, 0.04, 0.5, Vector3(0, 0.3, 0), Color("3a2f40"))
			box(root, Vector3(0.26, 0.24, 0.24), Vector3(0, 0.66, 0), Color("e8e2d0"))
			for x in [-0.06, 0.06]: box(root, Vector3(0.06, 0.06, 0.02), Vector3(x, 0.69, 0.12), Color("15101c"))
			for x in [-0.18, 0.0, 0.18]:
				cylinder(root, 0.03, 0.18, Vector3(x, 0.88 + (0.06 if x == 0.0 else 0.0), 0), Color("f0eedf"))
				ball(root, Vector3(0.05, 0.08, 0.05), Vector3(x, 1.0 + (0.06 if x == 0.0 else 0.0), 0), Color("ffb057"))
		"vampire_throne":
			var velvet = Color("9e2236")
			var throne_trim = Color("d9a13a")
			box(root, Vector3(0.9, 0.46, 0.8), Vector3(0, 0.28, 0.05), Color("3a2f40"))
			box(root, Vector3(0.74, 0.1, 0.66), Vector3(0, 0.56, 0.08), velvet)
			box(root, Vector3(0.9, 1.2, 0.14), Vector3(0, 1.0, -0.32), Color("3a2f40"))
			box(root, Vector3(0.6, 0.9, 0.03), Vector3(0, 1.0, -0.24), velvet)
			for side in [-1, 1]:
				box(root, Vector3(0.1, 0.3, 0.7), Vector3(side * 0.42, 0.72, 0.05), throne_trim)
				var throne_wing = box(root, Vector3(0.62, 0.5, 0.05), Vector3(side * 0.66, 1.3, -0.36), Color("4a2032"))
				throne_wing.rotation.z = side * -0.35
			ball(root, Vector3(0.22, 0.2, 0.1), Vector3(0, 1.66, -0.32), throne_trim)
		"dracula_coffin":
			var coffin_wood = Color("46303f")
			box(root, Vector3(1.36, 0.42, 0.62), Vector3(0, 0.22, 0), coffin_wood)
			box(root, Vector3(1.4, 0.12, 0.66), Vector3(0, 0.48, 0), Color("5c3a52"))
			box(root, Vector3(1.4, 0.03, 0.08), Vector3(0, 0.46, 0.33), Color("9e1f2a"))
			box(root, Vector3(0.62, 0.05, 0.08), Vector3(0.05, 0.56, 0), Color("d9a13a"))
			box(root, Vector3(0.08, 0.05, 0.36), Vector3(0.18, 0.56, 0), Color("d9a13a"))
			for x in [-0.66, 0.66]: box(root, Vector3(0.05, 0.3, 0.64), Vector3(x, 0.26, 0), Color("d9a13a"))
	return root

static func thief() -> ThiefVisual:
	return ThiefVisual.new()

static func apply_appearance(thief_model: Node3D, van_model: Node3D, equipped: Dictionary) -> void:
	thief_model.reset_suit()
	var van_id: String = equipped.get("set", "") if equipped.get("set", "") != "" else equipped.get("van", "")
	var suit_id: String = equipped.get("set", "") if equipped.get("set", "") != "" else equipped.get("suit", "")
	var vehicle_style := str(Balance.COSMETICS.get(van_id, {}).get("vehicle_style", ""))
	if is_instance_valid(van_model.get_parent()) and van_model.get_parent().has_method("set_vehicle"):
		van_model.get_parent().set_vehicle(vehicle_style)
	restore_palette(van_model)
	if van_id in Balance.COSMETICS and vehicle_style == "":
		tint_palette(van_model, [Color("ffbd59"), Color("ffe1a4")], Color(Balance.COSMETICS[van_id].color))
	if suit_id in Balance.COSMETICS:
		thief_model.set_suit_color(Color(Balance.COSMETICS[suit_id].color))

static func tint_palette(model: Node3D, palette: Array, color: Color) -> void:
	for part in model.get_children():
		if part is MeshInstance3D and part.material_override is StandardMaterial3D:
			if part.material_override.albedo_color in palette:
				if not part.has_meta("original_tint"): part.set_meta("original_tint", part.material_override.albedo_color)
				part.material_override.albedo_color = color
		tint_palette(part, palette, color)

static func restore_palette(model: Node3D) -> void:
	for part in model.get_children():
		if part is MeshInstance3D and part.has_meta("original_tint"):
			part.material_override.albedo_color = part.get_meta("original_tint")
		restore_palette(part)

static func set_toon_profile(model: Node, profile: ToonMaterial.Profile) -> void:
	# Compatibility hook for existing model builders. All stylization is now on the camera.
	pass
