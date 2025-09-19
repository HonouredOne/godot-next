extends Node2D

var velocity = Vector2()
@onready var center = position
var hello = FileSearch.search_string("hello")
var array2d: Array2D = Array2D.new(0, 0, &"float")

func _ready():
	randomize()
	if hello:
		print(hello)
	else:
		print("goodbye")
	array2d.resize(3, 3)
	array2d.set_cell(2, 2, "hello")
	print(array2d.get_cell(2, 2))


func _physics_process(_delta):
	velocity += Vector2(randf() - 0.5, randf() - 0.5)
	if velocity.length_squared() > 10:
		velocity *= 0.99
	position += velocity
	position = position.lerp(center, 0.03).round()
