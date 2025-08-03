class_name Array2D
extends RefCounted
# Author: willnationsdev
## A 2D Array.
##
## Creates a 2-dimensional [Array] (also known as a matrix), much like those
## built into other programming/scripting languages.
## [br][br]
##
## [b]Example:[/b]
## [codeblock]
## var array2d = Array2D.new(2, 3)
## [/codeblock]
## [br]
## Keep in mind that the [Array2D] is zero-indexed, meaning that
## the first row and column would be [code](0, 0)[/code].
## [br][br]
## [b]For example:[/b]
## [codeblock]
## var array2d = Array2D.new(2, 3)
## array2d.get_cell(2, 3)
## [/codeblock]
## would give you an out-of-bounds error, whereas
## [codeblock]
## var array2d = Array2D.new(2, 3)
## array2d.get_cell(1, 2)
## [/codeblock]
## would actually give you the data in the last cell.
## [br][br]
## The [method Array2D.new] constructor creates an [Array2D] from the base [Array].
## [codeblock]
## Array2D.new(width: int, height: int, type: StringName = &"", p_class_name: StringName = &"", script: Variant = null, p_array: Array = [])
## [/codeblock]
##
## You can also create a typed [Array2D]. A typed [Array2D] can only contain
## elements of the given type, or that inherit from the given class, as
## described by this constructor's parameters:
## [br][br]
## - [param type] is the built-in [Variant] type, such as [Object], [int] or
## [Quaternion], formatted as a [StringName] (i.e. [code]&"float"[/code]).
## It should be able to take any [Variant] type, including [Array].
## [br]
## - [param p_class_name] is the built-in class name
## (see [method Object.get_class]).
## [br]
## - [param script] is the associated script. It must be a [Script] instance or
## [code]null[/code].
## [br]
## - [param p_array] is the [Array] used as the base for the [Array2D].
## [codeblock]
## class_name Sword
## extends Node
##
## class Stats:
##     pass
##
## var Swords = Array2D.new(3, 4, &"Object", &"Node", Sword)
## [/codeblock][br]
## [b]Note:[/b] If [param type] is not [Object], [param p_class_name] must be an
## empty [StringName] and [param script] must be null.


## The data stored in the [Array2D].
var data: Array = []


func _init(
		width: int = 0,
		height: int = 0,
		type: StringName = &"",
		p_class_name: StringName = &"",
		script: Variant = null,
		p_array: Array = []
):
	p_array.resize(width)
	for i in width:
		p_array[i] = _create_typed_array(type, p_class_name, script)
		p_array[i].resize(height)
	data = p_array


func _create_typed_array(type: StringName, p_class_name: StringName,
		script: Variant) -> Array:
	match type:
		&"bool":
			return Array([], TYPE_BOOL, &"", null)
		&"int":
			return Array([], TYPE_INT, &"", null)
		&"float":
			return Array([], TYPE_FLOAT, &"", null)
		&"String":
			return Array([], TYPE_STRING, &"", null)
		&"Vector2":
			return Array([], TYPE_VECTOR2, &"", null)
		&"Vector2i":
			return Array([], TYPE_VECTOR2I, &"", null)
		&"Rect2":
			return Array([], TYPE_RECT2, &"", null)
		&"Rect2i":
			return Array([], TYPE_RECT2I, &"", null)
		&"Vector3":
			return Array([], TYPE_VECTOR3, &"", null)
		&"Vector3i":
			return Array([], TYPE_VECTOR3I, &"", null)
		&"Transform2D":
			return Array([], TYPE_TRANSFORM2D, &"", null)
		&"Vector4":
			return Array([], TYPE_VECTOR4, &"", null)
		&"Vector4i":
			return Array([], TYPE_VECTOR4I, &"", null)
		&"Plane":
			return Array([], TYPE_PLANE, &"", null)
		&"Quaternion":
			return Array([], TYPE_QUATERNION, &"", null)
		&"AABB":
			return Array([], TYPE_AABB, &"", null)
		&"Basis":
			return Array([], TYPE_BASIS, &"", null)
		&"Transform3D":
			return Array([], TYPE_TRANSFORM3D, &"", null)
		&"Projection":
			return Array([], TYPE_PROJECTION, &"", null)
		&"Color":
			return Array([], TYPE_COLOR, &"", null)
		&"StringName":
			return Array([], TYPE_STRING_NAME, &"", null)
		&"NodePath":
			return Array([], TYPE_NODE_PATH, &"", null)
		&"RID":
			return Array([], TYPE_RID, &"", null)
		&"Object":
			return Array([], TYPE_OBJECT, p_class_name, script)
		&"Callable":
			return Array([], TYPE_CALLABLE, &"", null)
		&"Signal":
			return Array([], TYPE_SIGNAL, &"", null)
		&"Dictionary":
			return Array([], TYPE_DICTIONARY, &"", null)
		&"Array":
			return Array([], TYPE_ARRAY, &"", null)
		&"PackedByteArray":
			return Array([], TYPE_PACKED_BYTE_ARRAY, &"", null)
		&"PackedInt32Array":
			return Array([], TYPE_PACKED_INT32_ARRAY, &"", null)
		&"PackedInt64Array":
			return Array([], TYPE_PACKED_INT64_ARRAY, &"", null)
		&"PackedFloat32Array":
			return Array([], TYPE_PACKED_FLOAT32_ARRAY, &"", null)
		&"PackedFloat64Array":
			return Array([], TYPE_PACKED_FLOAT64_ARRAY, &"", null)
		&"PackedStringArray":
			return Array([], TYPE_PACKED_STRING_ARRAY, &"", null)
		&"PackedVector2Array":
			return Array([], TYPE_PACKED_VECTOR2_ARRAY, &"", null)
		&"PackedVector3Array":
			return Array([], TYPE_PACKED_VECTOR3_ARRAY, &"", null)
		&"PackedColorArray":
			return Array([], TYPE_PACKED_COLOR_ARRAY, &"", null)
		&"PackedVector4Array":
			return Array([], TYPE_PACKED_VECTOR4_ARRAY, &"", null)
		_:
			return []


## Returns the contents of the [Array2D] as an [Array].
func get_data() -> Array:
	return data


## Checks to see if a cell exists at the given coordinates.
func has_cell(p_row: int, p_col: int) -> bool:
	return len(data) > p_row and len(data[p_row]) > p_col


## Sets the value of the cell at the given coordinates.
func set_cell(p_row: int, p_col: int, p_value) -> void:
	assert(has_cell(p_row, p_col))
	data[p_row][p_col] = p_value


## Returns value of the cell at the given coordinates.[br][br]
## [b]Example:[/b]
## [codeblock]Array2D.get_cell(2,5)[/codeblock]
## Returns the value of the cell in the third row of the sixth column.
func get_cell(p_row: int, p_col: int) -> Variant:
	assert(has_cell(p_row, p_col))
	return data[p_row][p_col]


## Checks to see if a cell exists at the given coordinates. If it does exist,
## sets the value of the cell.
func set_cell_if_exists(p_row: int, p_col: int, p_value) -> bool:
	if has_cell(p_row, p_col):
		set_cell(p_row, p_col, p_value)
		return true
	return false


## Checks to see if a cell exists at the given [Vector2] coordinates.
func has_cell_at_vector2(p_pos: Vector2) -> bool:
	return len(data) > p_pos.x and len(data[p_pos.x]) > p_pos.y


## Sets the value of the cell at the given [Vector2] coordinates.
func set_cell_at_vector2(p_pos: Vector2, p_value) -> void:
	assert(has_cell_at_vector2(p_pos))
	data[p_pos.x][p_pos.y] = p_value


## Returns value of the cell at the given [Vector2] coordinates.[br][br]
## [b]Example:[/b]
## [codeblock]
## var value = Vector2(3,1)
## Array2D.get_cell_at_vector2(value)
## [/codeblock]
## Returns the value of the cell in the fourth row of the second column.
func get_cell_at_vector2(p_pos: Vector2) -> Variant:
	assert(has_cell_at_vector2(p_pos))
	return data[p_pos.x][p_pos.y]


## Checks to see if a cell exists at the given [Vector2] coordinates. If it does
## exist, sets the value of the cell.
func set_cell_at_vector2_if_exists(p_pos: Vector2, p_value) -> bool:
	if has_cell_at_vector2(p_pos):
		set_cell_at_vector2(p_pos, p_value)
		return true
	return false


## Returns the data in the given row.
func get_row(p_idx: int) -> Array:
	assert(len(data) > p_idx)
	assert(p_idx >= 0)
	return data[p_idx].duplicate()


## Returns the data in the given column.
func get_col(p_idx: int) -> Array:
	var result = []
	for a_row in data:
		assert(len(a_row) > p_idx)
		assert(p_idx >= 0)
		result.push_back(a_row[p_idx])
	return result


## Returns a reference to the data in the given row.
func get_row_ref(p_idx: int) -> Variant:
	assert(len(data) > p_idx)
	assert(p_idx >= 0)
	return data[p_idx]


## Returns all of the data in the [Array2D] as an [Array] of data.
func get_rows() -> Array:
	var rows: Array = []
	for i in data:
		rows.append_array(i)
	return rows


func set_row(p_idx: int, p_row) -> void:
	assert(len(data) > p_idx)
	assert(p_idx >= 0)
	assert(len(data) == len(p_row))
	data[p_idx] = p_row


func set_col(p_idx: int, p_col) -> void:
	assert(len(data) > 0 and len(data[0]) > 0)
	assert(len(data) == len(p_col))
	var idx = 0
	for a_row in data:
		assert(len(a_row) > p_idx)
		assert(p_idx >= 0)
		a_row[p_idx] = p_col[idx]
		idx += 1


func insert_row(p_idx: int, p_array: Array) -> void:
	if p_idx < 0:
		data.append(p_array)
	else:
		data.insert(p_idx, p_array)


func insert_col(p_idx: int, p_array: Array) -> void:
	var idx = 0
	for a_row in data:
		if p_idx < 0:
			a_row.append(p_array[idx])
		else:
			a_row.insert(p_idx, p_array[idx])
		idx += 1


func append_row(p_array: Array) -> void:
	insert_row(-1, p_array)


func append_col(p_array: Array) -> void:
	insert_col(-1, p_array)


func sort_row(p_idx: int) -> void:
	_sort_axis(p_idx, true)


func sort_col(p_idx: int) -> void:
	_sort_axis(p_idx, false)


func duplicate() -> RefCounted:
	return load(get_script().resource_path).new(data)


func hash() -> int:
	return hash(self)


func shuffle() -> void:
	for a_row in data:
		a_row.shuffle()


func is_empty() -> bool:
	return len(data) == 0


func size() -> int:
	if len(data) <= 0:
		return 0
	return len(data) * len(data[0])


func resize(p_height: int, p_width: int) -> void:
	data.resize(p_height)
	for i in len(data):
		data[i] = []
		data[i].resize(p_width)


func resizev(p_dimensions: Vector2) -> void:
	resize(int(p_dimensions.x), int(p_dimensions.y))


func clear() -> void:
	data = []


func fill(p_value) -> void:
	for a_row in data.size():
		for a_col in data[a_row].size():
			data[a_row][a_col] = p_value


func fill_row(p_idx: int, p_value) -> void:
	assert(p_idx >= 0)
	assert(len(data) > p_idx)
	assert(len(data[0]) > 0)
	var arr = []
	for i in len(data[0]):
		arr.push_back(p_value)
	data[p_idx] = arr


func fill_col(p_idx: int, p_value) -> void:
	assert(p_idx >= 0)
	assert(len(data) > 0)
	assert(len(data[0]) > p_idx)
	var arr = []
	for i in len(data):
		arr.push_back(p_value)
	set_col(p_idx, arr)


func remove_row(p_idx: int) -> void:
	assert(p_idx >= 0)
	assert(len(data) > p_idx)
	data.remove_at(p_idx)


func remove_col(p_idx: int) -> void:
	assert(len(data) > 0)
	assert(p_idx >= 0 and len(data[0]) > p_idx)
	for a_row in data:
		a_row.remove(p_idx)


func count(p_value) -> int:
	var _count = 0
	for a_row in data:
		for a_col in a_row:
			if p_value == data[a_row][a_col]:
				_count += 1
	return _count


func has(p_value) -> bool:
	for a_row in data:
		for a_col in a_row:
			if p_value == data[a_row][a_col]:
				return true
	return false


func invert() -> RefCounted:
	data.reverse()
	return self


func invert_row(p_idx: int) -> RefCounted:
	assert(p_idx >= 0 and len(data) > p_idx)
	data[p_idx].reverse()
	return self


func invert_col(p_idx: int) -> RefCounted:
	assert(len(data) > 0)
	assert(p_idx >= 0 and len(data[0]) > p_idx)
	var col = get_col(p_idx)
	col.invert()
	set_col(p_idx, col)
	return self


func bsearch_row(p_idx: int, p_value, p_before: bool) -> int:
	assert(p_idx >= 0 and len(data) > p_idx)
	return data[p_idx].bsearch(p_value, p_before)


func bsearch_col(p_idx: int, p_value, p_before: bool) -> int:
	assert(len(data) > 0)
	assert(p_idx >= 0 and len(data[0]) > p_idx)
	var col = get_col(p_idx)
	col.sort()
	return col[p_idx].bsearch(p_value, p_before)


func find(p_value) -> Vector2:
	for a_row in data:
		for a_col in a_row:
			if p_value == data[a_row][a_col]:
				return Vector2(a_row, a_col)
	return Vector2(-1, -1)


func rfind(p_value) -> Vector2:
	var i: int = len(data) - 1
	var j: int = len(data[0]) - 1
	while i:
		while j:
			if p_value == data[i][j]:
				return Vector2(i, j)
			j -= 1
		i -= 1
	return Vector2(-1, -1)


func transpose() -> RefCounted:
	var width : int = len(data)
	var height : int = len(data[0])
	var transposed_matrix : Array
	for i in height:
		transposed_matrix.append([])
	var h : int = 0
	while h < height:
		for w in width:
			transposed_matrix[h].append(data[w][h])
		h += 1
	return load(get_script().resource_path).new(transposed_matrix, false)


func _to_string() -> String:
	var ret: String = ""
	var width: int = len(data)
	var height: int = len(data[0])
	for h in height:
		for w in width:
			ret += "[" + str(data[w][h]) + "]"
			if w == width - 1 and h != height -1:
				ret += "\n"
			else:
				if w == width - 1:
					ret += "\n"
				else:
					ret += ", "
	return ret


func _sort_axis(p_idx: int, p_is_row: bool) -> void:
	if p_is_row:
		data[p_idx].sort()
		return
	var col = get_col(p_idx)
	col.sort()
	set_col(p_idx, col)
