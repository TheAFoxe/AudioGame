extends Node3D

class_name Level3D

signal _3d_to_2d(position: PackedVector2Array, index)
signal _define_shadow_casters(shadow_casters: MeshInstance3D)

var projectors: Array
var shadow_casters: Array


func define_projectors() -> Array:
	projectors = get_tree().get_nodes_in_group("Projector")
	return projectors


func define_shadow_casters() -> Array:
	shadow_casters = get_tree().get_nodes_in_group("ShadowCaster")
	_define_shadow_casters.emit(shadow_casters)
	return shadow_casters


func make_projection():
	#for i in get_tree().get_nodes_in_group("Remove"):
		#i.queue_free()
	
	for shadow_caster in shadow_casters:
		if not shadow_caster.is_in_group("Active"):
			continue
		
		var mesh = shadow_caster.mesh
		var arrays = mesh.surface_get_arrays(0)
		var verts = arrays[Mesh.ARRAY_VERTEX]
		var vertices = []
		var vertices_2d: PackedVector2Array
		
		for v in verts:
			if v in vertices: continue
			vertices.append(v)
			v = shadow_caster.global_basis * v + shadow_caster.global_position
			for p in projectors:
				var hit = calculate_projection(p.global_position, v)
				vertices_2d.append(hit)
				#debug_lines(p.global_position, v)
		
		var index = shadow_casters.find(shadow_caster)
		emit_signal("_3d_to_2d", Geometry2D.convex_hull(vertices_2d), index)


func calculate_projection(p: Vector3, v: Vector3) -> Vector2:
	var x = (0.0 - p.x) / (p.x - v.x)
	var y = (p - v) * x + p
	y *= (2560.0 / 32.0)
	y.y -= 396
	return Vector2(y.z, -y.y)


#func debug_lines(p: Vector3, v: Vector3) -> void:
	#var im := ImmediateMesh.new()
	#var material := StandardMaterial3D.new()
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#material.albedo_color = Color(1, 0, 0)
	#im.surface_begin(Mesh.PRIMITIVE_LINES, material)
	#im.surface_add_vertex(p)
	#im.surface_add_vertex(v)
	#im.surface_end()
	#var line_instance := MeshInstance3D.new()
	#line_instance.mesh = im
	#line_instance.add_to_group("Remove")
	#add_child(line_instance)
