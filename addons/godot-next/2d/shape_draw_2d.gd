@tool
@icon("../icons/icon_shape_draw_2d.svg")
class_name ShapeDraw2D
extends CollisionShape2D
# author: Henrique "Pigdev" Campos
# license: MIT
## Draws a simple two-dimensional shape using CollisionShape2D's editor plugin
## handles.
##
##[b]Note:[/b] Don't use it as a direct child of CollisionBody2D classes unless
## you intend to use it as its CollisionShape2D.

## Color of the shape.
@export var color := Color.WHITE: set = set_color
## Offset position from the node's origin.
@export var offset_position := Vector2.ZERO: set = set_offset

func _draw() -> void:
	if shape is CircleShape2D:
		draw_circle(offset_position, shape.radius, color)
	elif shape is RectangleShape2D:
		var rect := Rect2(offset_position - shape.extents, shape.extents * 2.0)
		draw_rect(rect, color)
	elif shape is CapsuleShape2D:
		draw_capsule(offset_position, shape.radius, shape.height, color)

## Draws a capsule shape.
## [b]Note:[/b] This was added because there is no draw_capsule function in the
## [CanvasItem] class.
func draw_capsule(capsule_position: Vector2, capsule_radius: float,
		capsule_height: float, capsule_color: Color) -> void:

	var upper_circle_position: Vector2 = capsule_position + Vector2(0, capsule_height * 0.5)
	draw_circle(upper_circle_position, capsule_radius, capsule_color)

	var lower_circle_position: Vector2 = capsule_position - Vector2(0, capsule_height * 0.5)
	draw_circle(lower_circle_position, capsule_radius, capsule_color)

	var position: Vector2 = capsule_position - Vector2(capsule_radius, capsule_height * 0.5)
	var rect := Rect2(position, Vector2(capsule_radius * 2, capsule_height))
	draw_rect(rect, capsule_color)

func set_color(new_color: Color) -> void:
	color = new_color
	queue_redraw()

func set_offset(offset: Vector2) -> void:
	offset_position = offset
	queue_redraw()
