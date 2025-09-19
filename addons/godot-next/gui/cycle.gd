@icon("../icons/icon_cycle.svg")
class_name Cycle
extends TabContainer
# author: willnationsdev
# description: Cycles through child nodes without any visibility or container effects.

func _init():
	tabs_visible = false
	self_modulate = Color(1, 1, 1, 0)


func _ready():
	for a_child in get_children():
		if a_child is Control:
			(a_child as Control).set_as_top_level(true)


func add_child(p_value: Node, p_legible_unique_name: bool = false, InternalMode = 0):
	super.add_child(p_value, p_legible_unique_name)
	if p_value and p_value is Control:
		(p_value as Control).set_as_top_level(true)


func remove_child(p_value: Node):
	super.remove_child(p_value)
	if p_value and p_value is Control:
		(p_value as Control).set_as_top_level(false)
