@icon("../icons/icon_trail_2d.svg")
class_name Trail2D
extends Line2D
# author: willnationsdev
## Creates a variable-length trail that tracks a [member target] node.
##
## - Use [member CanvasItem.show_behind_parent] or [member CanvasItem.z_index]
## (both can be modified in the Inspector) to control its layer visibility.[br]
## - [member target] and [member target_path] will update each other as they
## are modified via their getters and setters.[br]

## Used to determine how long the trail points should be rendered.
enum PersistenceMode {
	## Do not persist. Removes all points beyond the trail_length.
	OFF,
	## Always persist. Does not remove any points.
	ALWAYS,
	## Conditionally persist. Choose an algorithm from
	## [enum PersistenceCondition] for when to add and remove points.
	CONDITIONAL,
}

## Used when [member persistence_mode] is set to
## [constant PersistenceMode.CONDITIONAL].
enum PersistenceCondition {
	## Add points during movement and remove points when not moving.
	ON_MOVEMENT,
	## Override [method _should_grow] and [method _should_shrink] to define your
	## own custom logic for when to add/remove points.
	CUSTOM,
}

var _target: Node2D = null
var _target_path: NodePath = ^".."

## The NodePath to the target. If you do not assign a [member target], it will
## default to the parent node. This means that the node will automatically
## update its target when it is moved around in the scene tree.
@export var target_path: NodePath = ^"..":
	set(p_value):
		_target_path = p_value
		_target = get_node(p_value) as Node2D if has_node(p_value) else null
	get:
		return _target_path
## If the [enum Persistence] value is set to [constant OFF], this is the number
## of points that should be allowed in the trail.[br]
## [b]Note:[/b] To completely turn off the Trail2D, set this to 0.
@export var trail_length: int = 50
## To what degree the trail should remain in existence before automatically
## removing points.
@export var persistence_mode: PersistenceMode = 0
## If [member persistence_mode] is set to
## [constant PersistenceMode.CONDITIONAL], which persistence algorithm to use.
@export var persistence_condition: PersistenceCondition = 0
## If [member persistence_mode] is set to
## [constant PersistenceMode.CONDITIONAL], how many points to remove per frame.
@export var degen_rate: int = 1
## If [code]true[/code], will automatically set [member CanvasItem.z_index] to
## be one less than the [member target].
@export var auto_z_index: bool = true
## If [code]true[/code], will automatically setup a gradient for a gradually
## transparent trail.
@export var auto_alpha_gradient: bool = true

## The target node to track.
var target: Node2D:
	set(p_value):
		_target = p_value
		if p_value:
			var path = get_path_to(p_value)
			if path != target_path:
				_target_path = path
		else:
			_target_path = ^""
	get:
		return _target


func _init():
	set_as_top_level(true)
	global_position = Vector2()
	global_rotation = 0
	if auto_alpha_gradient and not gradient:
		gradient = Gradient.new()
		var first = default_color
		first.a = 0
		gradient.set_color(0, first)
		gradient.set_color(1, default_color)


func _notification(p_what: int):
	match p_what:
		NOTIFICATION_PARENTED:
			self.target_path = target_path
			if auto_z_index:
				z_index = target.z_index - 1 if target else 0
		NOTIFICATION_UNPARENTED:
			self.target_path = ^""
			self.trail_length = 0


func _process(_delta: float) -> void:
	if target:
		match persistence_mode:
			PersistenceMode.OFF:
				add_point(target.global_position)
				while get_point_count() > trail_length:
					remove_point(0)
			PersistenceMode.ALWAYS:
				add_point(target.global_position)
			PersistenceMode.CONDITIONAL:
				match persistence_condition:
					PersistenceCondition.ON_MOVEMENT:
						_conditional_persistence_on_movement()
					PersistenceCondition.CUSTOM:
						_conditional_persistence_custom()


## Removes all points from the trail.
func erase_trail():
	for i in range(get_point_count()):
		remove_point(0)


## Override this to define what conditions should cause a point to be added to
## the list of points under the target.
func _should_grow() -> bool:
	return true


## Override this to define what conditions should cause the [member degen_rate]
## to be removed from the trail's list of points on each frame.
func _should_shrink() -> bool:
	return true


func _conditional_persistence_on_movement() -> void:
	var moved: bool = (
			get_point_position(
					get_point_count() - 1
			) != target.global_position if get_point_count() else false
	)
	if not get_point_count() or moved:
		add_point(target.global_position)
	else:
		for i in range(degen_rate):
			remove_point(0)


func _conditional_persistence_custom() -> void:
	if _should_grow():
		add_point(target.global_position)
	if _should_shrink():
		for i in range(degen_rate):
			remove_point(0)
