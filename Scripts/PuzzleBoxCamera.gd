extends Node3D


signal camera_moved


var mouse_delta : Vector2
var pan_speed : float = 0.25
var pan_direction : int = -1
var is_panning : bool = false
var max_angle : float = 30

var idle_timer
var is_idle : bool = true


func _ready():
	pass


func _process(delta):
	if(is_panning):
		pan_cube(delta)
	
	if is_idle:
		rotate_y(0.5 * pan_speed * delta)
	
	mouse_delta = Vector2.ZERO


func _input(event):
	if event is InputEventMouse:
		var mouse_event = event as InputEventMouse
	
		if mouse_event is InputEventMouseButton and mouse_event.button_mask == 1:
			var mouse_button = event as InputEventMouseButton
			is_panning = mouse_button.is_pressed()
		
		if mouse_event is InputEventMouseMotion and mouse_event.button_mask == 1:
			mouse_delta = event.relative
			if mouse_delta.length() > 1 && is_panning:
				reset_idle_timer()
				

	if event.is_action_pressed("rotate_cube"):
		reset_idle_timer()


func pan_cube(delta : float):
	rotate_y(mouse_delta.x * pan_direction * pan_speed * delta)
	rotate_object_local(Vector3.RIGHT, mouse_delta.y * pan_direction * pan_speed * delta)
	rotation.x = clamp(rotation.x, deg_to_rad(-max_angle), deg_to_rad(max_angle))


func reset_idle_timer():
	is_idle = false
	$Timer.start()
	emit_signal("camera_moved")


func _on_timer_timeout():
	is_idle = true


func _on_puzzle_box_manager_pause(is_paused):
	if is_paused:
		is_idle = true
