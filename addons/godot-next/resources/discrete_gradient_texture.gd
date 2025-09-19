@tool
class_name DiscreteGradientTexture
extends ImageTexture
# author: Athrunen
# license: MIT
# description: Has the same functionality as the GradientTexture but does not interpolate colors.
# todos:
#	- Write a more elegant way of updating the texture than changing the resolution.
#	- Persuade Godot to repeat the texture vertically in the inspector.

@export var resolution: int = 256: set = _update_resolution
@export var gradient: Gradient = Gradient.new(): set = _update_gradient

func _ready() -> void:
	_update_texture()


func _update_texture() -> void:
	var image := Image.new()
	image.create(resolution, 1, false, Image.FORMAT_RGBA8)

	if not gradient:
		return

	false # image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

	var last_offset := 0
	var last_pixel := 0
	var index := 0
	for offset in gradient.offsets:
		var amount := int(round((offset - last_offset) * resolution))
		amount -= 1 if amount > 0 else 0
		var color := gradient.colors[index]
		for x in range(amount):
			image.set_pixel(x + last_pixel, 0, color)

		last_offset = offset
		last_pixel = last_pixel + amount
		index += 1

	if last_pixel < resolution:
		var color := gradient.colors[-1]
		for x in resolution - last_pixel:
			image.set_pixel(x + last_pixel, 0, color)

	false # image.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	self.create_from_image(image) #,0


func _update_gradient(g: Gradient) -> void:
	gradient = g
	_update_texture()


func _update_resolution(r: int) -> void:
	resolution = r
	_update_texture()
