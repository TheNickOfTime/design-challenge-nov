extends Node3D


var mouse_delta : Vector2
var pan_speed : float = 0.25
var pan_direction : int = -1
var is_panning : bool = false
var max_angle : float = 30


func _ready():
	pass


func _process(delta):
	if(is_panning):
		pan_cube(delta)
	
	mouse_delta = Vector2.ZERO


func _input(event):
	if event is InputEventMouseButton:
		var mouse_button = event as InputEventMouseButton
		is_panning = mouse_button.is_pressed()
	
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func pan_cube(delta : float):
	rotate_y(mouse_delta.x * pan_direction * pan_speed * delta)
	rotate_object_local(Vector3.RIGHT, mouse_delta.y * pan_direction * pan_speed * delta)
	rotation.x = clamp(rotation.x, deg_to_rad(-max_angle), deg_to_rad(max_angle))