@icon("../icons/icon_trail_3d.svg")
class_name Trail3D
extends MeshInstance3D
# Author: miziziziz
## Creates a variable-length trail on a [MeshInstance3D] Node using an
## [ImmediateMesh] Resource.

## An array of the points in the trail. Normally, it is unnecessary to do
## anything with this because the [method update_trail] method already does
## everything automatically.
var _points = []

## The size of each segment. Normally, it is unnecessary to change this because
## it is already calculated automatically
## (e.g. [member length] / [member density_lengthwise]).
var _segment_length = 1.0

## The number of vertices in each loop.
@export var density_around: int = 5

## The number of vertex loops in the trail.
@export var density_lengthwise: int = 25

## The length of the trail.
@export var length: float = 10.0

## The maximum radius of a loop.
@export var max_radius = 0.5

## The curve used to shape the trail. Right click on this option in the
## inspector to see different pre-set curve options.
@export_exp_easing() var shape: float = 1.0


func _ready():
	mesh = ImmediateMesh.new()
	if length <= 0:
		length = 2
	if density_around < 3:
		density_around = 3
	if density_lengthwise < 2:
		density_lengthwise = 2

	_segment_length = length / density_lengthwise
	for i in range(density_lengthwise):
		_points.append(global_position)


func _process(_delta):
	update_trail()
	render_trail()


## Updates the trail.
func update_trail():
	var ind = 0
	var last_p = global_position
	for p in _points:
		var dis = p.distance_to(last_p)
		var seg_len = _segment_length
		if ind == 0:
			seg_len = 0.05
		if dis > seg_len:
			p = last_p + (p - last_p) / dis * seg_len
		last_p = p
		_points[ind] = p
		ind += 1


## Renders the trail.
func render_trail():
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var local_points = []
	for p in _points:
		local_points.append(p - global_position)
	var last_p = Vector3()
	var verts = []
	var ind = 0
	var first_iteration = true
	var last_first_vec = Vector3()
	# Create vertex loops around points.
	for p in local_points:
		var new_last_points = []
		var offset = last_p - p
		if offset == Vector3():
			continue
		# Get vector pointing from this point to last point.
		var y_vec = offset.normalized()
		var x_vec = Vector3()
		if first_iteration:
			# Cross product with random vector to get a perpendicular vector.
			x_vec = y_vec.cross(y_vec.rotated(Vector3.RIGHT, 0.3))
		else:
			# Keep each loop at the same rotation as the previous.
			x_vec = y_vec.cross(last_first_vec).cross(y_vec).normalized()
		var width = max_radius
		if shape != 0:
			width = (1 - ease((ind + 1.0) / density_lengthwise, shape)) * max_radius
		var seg_verts = []
		var f_iter = true
		for i in range(density_around): # Set up row of verts for each level.
			var new_vert = p + width * x_vec.rotated(y_vec, i * TAU / density_around).normalized()
			if f_iter:
				last_first_vec = new_vert - p
				f_iter = false
			seg_verts.append(new_vert)
		verts.append(seg_verts)
		last_p = p
		ind += 1
		first_iteration = false

	# Create tris.
	for j in range(len(verts) - 1):
		var cur = verts[j]
		var nxt = verts[j + 1]
		var uv = (j + 1.0) / (len(verts) + 1);
		var uvnxt = (j + 2.0) / (len(verts) + 1);
		for i in range(density_around):
			var nxt_i = (i + 1) % density_around
			# Order added affects normal.
			mesh.surface_set_uv(Vector2(uv, 0.0))
			mesh.surface_add_vertex(cur[i])
			mesh.surface_add_vertex(cur[nxt_i])
			mesh.surface_set_uv(Vector2(uvnxt, 0.0))
			mesh.surface_add_vertex(nxt[i])
			mesh.surface_set_uv(Vector2(uv, 0.0))
			mesh.surface_add_vertex(cur[nxt_i])
			mesh.surface_set_uv(Vector2(uvnxt, 0.0))
			mesh.surface_add_vertex(nxt[nxt_i])
			mesh.surface_add_vertex(nxt[i])

	if verts.size() > 1:
		# Cap off top.
		for i in range(density_around):
			var nxt = (i + 1) % density_around
			mesh.surface_set_uv(Vector2(0, 0))
			mesh.surface_add_vertex(verts[0][i])
			mesh.surface_add_vertex(Vector3())
			mesh.surface_add_vertex(verts[0][nxt])

		# Cap off bottom.
		for i in range(density_around):
			var nxt = (i + 1) % density_around
			mesh.surface_set_uv(Vector2(1, 0))
			mesh.surface_add_vertex(verts[verts.size() - 1][i])
			mesh.surface_add_vertex(verts[verts.size() - 1][nxt])
			mesh.surface_add_vertex(last_p)
	mesh.surface_end()
