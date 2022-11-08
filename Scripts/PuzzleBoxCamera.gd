extends Node3D


var mouse_delta : Vector2
var pan_speed : float = 0.25
var pan_direction : int = -1
var is_panning : bool = false


func _ready():
	pass # Replace with function body.


func _process(delta):
	if(is_panning):
		pan_cube(delta)


func _input(event):
	if event is InputEventMouseButton:
		var mouse_button = event as InputEventMouseButton
		is_panning = mouse_button.is_pressed()
	
	elif event is InputEventMouseMotion:
		# var mouse_motion = event as InputEventMouseMotion
		mouse_delta = event.relative


func pan_cube(delta : float):
	rotate_y(mouse_delta.x * pan_direction * pan_speed * delta)
