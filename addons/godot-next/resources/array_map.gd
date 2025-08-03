@tool
class_name ArrayMap
extends Resource
# author: willnationsdev
# license: MIT
# description:
#   ArrayMap is a Resource that stores String->Variant pairs.
#   Stores an Array of values and a Dictionary of names mapped to their indices.
#
#   Because exporting Arrays results in globally shared Array references,
#   this simulates all of its data as individual properties.
#
#   The above bug is fixed in 4.0 via godotengine/godot#41983.

# internal data
var values := []
var _keys := {}

# To more easily identify resource data in git diffs of *.tres files.
@export var name := ""

# To accurately store type information.
# Initially empty, but updates during first `insert` after clear.
var _type := TYPE_NIL
var _hint := PROPERTY_HINT_NONE
var _hint_string := ""


func _init(p_name: String = "") -> void:
	name = p_name


func has(p_key: String) -> bool:
	return _keys.has(p_key)


# Does not insert duplicates. Silently replaces record if found.
func insert(p_key: String, p_value) -> void:
	if not keys:
		# export Array/Dictionary hack
		_type = typeof(p_value)
		if _type == TYPE_OBJECT and p_value is Resource:
			_hint = PROPERTY_HINT_RESOURCE_TYPE
			_hint_string = p_value.get_class() # might not work in 4.0
		elif _type == TYPE_ARRAY:
			_hint = 24 # PROPERTY_HINT_TYPE_STRING
			_hint_string = str(typeof(p_value)) + ":"

	if _keys.has(p_key):
		values[_keys[p_key]] = p_value
	else:
		_keys[p_key] = values.size()
		values.append(p_value)


func erase(p_key: String) -> void:
	assert(_keys.has(p_key))
	values.remove_at(_keys[p_key])
	# warning-ignore:return_value_discarded
	_keys.erase(p_key)


# Getter
func get_value(p_key: String):
	assert(_keys.has(p_key))
	return values[_keys[p_key]]


# Finder, slow
func find(p_value) -> String:
	for i in values.size():
		if p_value == values[i]:
			for a_key in _keys:
				if _keys[a_key] == i:
					return a_key as String
	return ""


# Copied
func keys() -> Array:
	return _keys.keys()


# Direct reference
func values_ref() -> Array:
	return values


# Copied
func dict() -> Dictionary:
	var ret := {}
	for a_key in _keys:
		ret[a_key] = values[_keys[a_key]]
	return ret


func clear() -> void:
	values.clear()
	_keys.clear()


# Export Array/Dictionary hack
func _get_property_list():
	var ret := []
	for i in values.size():
		ret.append({
			"name": "values/" + str(i),
			"type": _type,
			"hint": _hint,
			"hint_string": _hint_string,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	for a_key in _keys:
		ret.append({
			"name": "_keys/" + str(a_key),
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "_hint_string",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	return ret


# Export Array/Dictionary hack
func _get(p_name: StringName):
	if p_name.begins_with("values/"):
		var i = int(p_name.replace("values/", ""))
		if i < values.size() and i >= 0:
			return values[i]

	if p_name.begins_with("_keys/"):
		var key = p_name.replace("_keys/", "")
		if _keys.has(key):
			return _keys[key]


# Export Array/Dictionary hack
func _set(p_name: StringName, p_value):
	if p_name.begins_with("values/"):
		var i = int(p_name.replace("values/", ""))
		if i < values.size() and i >= 0:
			values[i] = p_value
			return true

	if p_name.begins_with("_keys/"):
		var key = p_name.replace("_keys/", "")
		if _keys.has(key):
			_keys[key] = p_value
			return true

	return false
