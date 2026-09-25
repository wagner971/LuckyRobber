class_name VehicleModels
extends RefCounted

# Only the visual shell changes. The +X cab / -X loading orientation is shared.
static func customize(root: Node3D, style: String, length: float) -> void:
	var rear := -length * 0.5
	var front := length * 0.5
	var mid := -0.525
	var bed_length := length - 1.05
	var paint: Color = {"black":Color("242c39"), "pickup":Color("be593e"), "box":Color("d4e1e6"), "armored":Color("526763"), "luxury":Color("e9e0c5"), "hearse":Color("292134"), "pirate":Color("225965"), "pharaoh":Color("214d83")}.get(style, Color("ffbd59"))
	var trim: Color = Color("d9b465") if style in ["luxury", "hearse", "pirate", "pharaoh"] else Color("97aab5")
	Models.tint_palette(root, [Color("ffbd59"), Color("ffe1a4")], paint)
	# Palette replacement metadata is for ordinary color skins, not this shell's factory paint.
	clear_tint_metadata(root)
	for name in ["Hubcap", "SideStripe", "Grille", "RoofRail"]: recolor(root, name, trim)
	match style:
		"black":
			recolor(root, "CabRoof", Color("141e2a"))
			for side in [-1.0, 1.0]:
				box(root,"BlackWindow",Vector3(bed_length-0.55,0.33,0.025),Vector3(mid,1.61,side*0.83),Color("102536"))
				box(root,"ChromeSill",Vector3(length-0.2,0.045,0.05),Vector3(0,0.73,side*0.85),trim)
		"pickup":
			for name in ["CargoRoof","RoofRail","SlidingDoor","SideStripe","RearDoorHinge"]: hide_parts(root,name)
			for part in parts(root,"CargoSide"):
				(part.mesh as BoxMesh).size.y = 0.5
				part.position.y = 0.96
			for side in [-1.0,1.0]:
				box(root,"BedRail",Vector3(bed_length,0.08,0.16),Vector3(mid,1.25,side*0.75),trim)
				box(root,"TruckStep",Vector3(0.9,0.1,0.19),Vector3(front-0.57,0.62,side*0.84),Color("293949"))
			for z in [-0.45,-0.15,0.15,0.45]: box(root,"BedRib",Vector3(bed_length-0.1,0.045,0.05),Vector3(mid,0.78,z),Color("53616a"))
			box(root,"OpenTailgate",Vector3(0.44,0.075,1.42),Vector3(rear-0.12,0.78,0),paint)
			box(root,"CabBackWindow",Vector3(0.025,0.33,1.08),Vector3(front-1.08,1.68,0),Color("182d3e"))
		"box":
			for part in parts(root,"CargoRoof"): part.position.y = 2.35
			for part in parts(root,"CargoSide"):
				(part.mesh as BoxMesh).size.y = 1.68
				part.position.y = 1.52
			for part in parts(root,"RearDoorHinge"): part.position.y += 0.18
			for part in parts(root,"RearDoor"):
				if part is MeshInstance3D and part.name.to_lower().begins_with("reardoor") and not "Panel" in str(part.name) and not "Handle" in str(part.name):
					(part.mesh as BoxMesh).size.y = 1.62
			hide_parts(root,"RoofRail")
			for side in [-1.0,1.0]:
				box(root,"BoxBlueBand",Vector3(bed_length,0.3,0.03),Vector3(mid,1.27,side*0.835),Color("34759d"))
				for i in range(5): box(root,"BoxRib",Vector3(0.035,1.43,0.035),Vector3(rear+0.17+i*(bed_length-0.34)/4,1.55,side*0.85),trim)
				for x in [rear+0.12,front-1.17]: box(root,"ClearanceLight",Vector3(0.13,0.085,0.045),Vector3(x,2.34,side*0.83),Color("ffb454"))
		"armored":
			hide_parts(root,"SideStripe")
			for side in [-1.0,1.0]:
				box(root,"ArmorPanel",Vector3(bed_length-0.16,0.85,0.12),Vector3(mid,1.4,side*0.84),Color("3d504c"))
				for x in [rear+0.22,front-1.27]:
					for y in [1.04,1.75]: bolt(root,Vector3(x,y,side*0.91),trim)
				box(root,"ArmoredWindow",Vector3(0.38,0.19,0.06),Vector3(front-0.74,1.7,side*0.81),Color("0e222c"))
			box(root,"BullBar",Vector3(0.16,0.43,1.4),Vector3(front+0.10,0.86,0),Color("283637"))
			for z in [-0.5,0.0,0.5]: box(root,"GrilleGuard",Vector3(0.09,0.62,0.065),Vector3(front+0.20,1.03,z),trim)
			box(root,"RoofHatch",Vector3(0.75,0.12,0.85),Vector3(mid,2.1,0),Color("344641"))
		"luxury":
			recolor(root,"CabRoof",Color("243746"))
			recolor(root,"CargoRoof",Color("243746"))
			for side in [-1.0,1.0]:
				box(root,"GoldWindowFrame",Vector3(bed_length-0.27,0.59,0.04),Vector3(mid,1.55,side*0.84),trim)
				box(root,"PanoramaGlass",Vector3(bed_length-0.38,0.46,0.045),Vector3(mid,1.57,side*0.866),Color("213a4b"))
				box(root,"WindowPillar",Vector3(0.07,0.5,0.05),Vector3(mid,1.56,side*0.90),trim)
			for z in [-0.27,-0.135,0.0,0.135,0.27]: box(root,"LuxuryGrille",Vector3(0.06,0.3,0.035),Vector3(front+0.065,1.04,z),trim)
		"hearse":
			hide_parts(root,"RoofRail")
			box(root,"HearseRoof",Vector3(bed_length,0.18,1.47),Vector3(mid,2.12,0),Color("342a41"))
			for side in [-1.0,1.0]:
				box(root,"HearseWindowFrame",Vector3(bed_length-0.24,0.69,0.06),Vector3(mid,1.54,side*0.84),trim)
				box(root,"HearseGlass",Vector3(bed_length-0.35,0.56,0.07),Vector3(mid,1.56,side*0.88),Color("4c3c5c"))
				for x in [mid-0.55,mid,mid+0.55]: box(root,"GothicMullion",Vector3(0.045,0.6,0.04),Vector3(x,1.56,side*0.93),trim)
				box(root,"CoffinBadge",Vector3(0.30,0.25,0.045),Vector3(mid,1.52,side*0.96),Color("bd9b64")).rotation.z = 0.2
			for x in [rear+0.18,front-1.22]:
				for z in [-0.61,0.61]: bolt(root,Vector3(x,2.28,z),trim)
		"pirate":
			for side in [-1.0,1.0]:
				for i in range(4): box(root,"WoodPlank",Vector3(bed_length-0.08,0.16,0.045),Vector3(mid,0.99+i*0.2,side*0.84),Color("9f734a") if i%2==0 else Color("78543b"))
				for x in [rear+0.18,front-1.22]: box(root,"GoldBinding",Vector3(0.075,0.83,0.055),Vector3(x,1.29,side*0.88),trim)
				var skull = Models.ball(root,Vector3(0.24,0.23,0.065),Vector3(mid,1.48,side*0.91),Color("eee4c5"))
				skull.name = "PirateSkull"
				for x in [-0.055,0.055]: box(root,"SkullEye",Vector3(0.045,0.06,0.02),Vector3(mid+x,1.50,side*0.95),Color("1c343b"))
			box(root,"FlagMast",Vector3(0.055,0.54,0.055),Vector3(mid,2.28,0),trim)
			box(root,"PirateFlag",Vector3(0.42,0.25,0.035),Vector3(mid+0.2,2.42,0),Color("172b37"))
			box(root,"FlagMark",Vector3(0.11,0.11,0.045),Vector3(mid+0.2,2.42,0.02),Color("eee4c5"))
		"pharaoh":
			for side in [-1.0,1.0]:
				box(root,"RoyalBand",Vector3(bed_length-0.1,0.11,0.05),Vector3(mid,1.03,side*0.84),trim)
				for i in range(4): box(root,"RoyalStripe",Vector3(0.09,0.64,0.04),Vector3(rear+0.25+i*(bed_length-0.5)/3,1.54,side*0.85),trim)
				box(root,"AnkhStem",Vector3(0.06,0.37,0.045),Vector3(mid,1.49,side*0.90),trim)
				box(root,"AnkhCross",Vector3(0.27,0.06,0.045),Vector3(mid,1.60,side*0.90),trim)
				var loop = Models.ball(root,Vector3(0.16,0.18,0.06),Vector3(mid,1.78,side*0.90),trim)
				loop.name = "AnkhCrown"
			var crown := MeshInstance3D.new()
			var pyramid := CylinderMesh.new()
			pyramid.top_radius = 0
			pyramid.bottom_radius = 0.49
			pyramid.height = 0.40
			pyramid.radial_segments = 4
			crown.mesh = pyramid
			crown.material_override = Models.material(trim)
			crown.position = Vector3(mid,2.21,0)
			crown.rotation.y = PI/4
			crown.name = "PharaohCrown"
			root.add_child(crown)

static func box(root: Node3D, label: String, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var node := Models.box(root,size,at,color)
	node.name = label
	return node

static func bolt(root: Node3D, at: Vector3, color: Color) -> void:
	var node := Models.ball(root,Vector3(0.075,0.075,0.075),at,color)
	node.name = "TrimBolt"

static func parts(root: Node, prefix: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for child in root.get_children():
		if child is Node3D and str(child.name).begins_with(prefix): found.append(child)
		found.append_array(parts(child,prefix))
	return found

static func hide_parts(root: Node3D, prefix: String) -> void:
	for part in parts(root,prefix): part.hide()

static func recolor(root: Node3D, prefix: String, color: Color) -> void:
	for part in parts(root,prefix):
		if part is MeshInstance3D: part.material_override = Models.material(color)

static func clear_tint_metadata(root: Node) -> void:
	if root.has_meta("original_tint"): root.remove_meta("original_tint")
	for child in root.get_children(): clear_tint_metadata(child)
