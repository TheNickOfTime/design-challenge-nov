extends MeshInstance3D

#Export variables---------------------------------------------------------------
@export var camera : Camera3D
@export var marker : Node3D

#OnReady variables--------------------------------------------------------------
@onready var rotate_degrees : float = deg_to_rad(90)

#Member Variables---------------------------------------------------------------
var rotate_time : float = 0.75
var is_rotating : bool = false

var mouse_delta : Vector2
var pan_speed : float = 0.25
var pan_direction : int = 1
var is_panning : bool = false


func _ready():
	pass


func _process(delta):
	if(is_panning):
		pan_cube(delta)


func _input(event):
	if event is InputEventKey && event.is_pressed():
		var key = event as InputEventKey
		var new_rot : Transform3D
		
		if key.keycode == KEY_UP:
			new_rot = transform.rotated_local(Vector3.RIGHT, rotate_degrees)
		elif key.keycode == KEY_DOWN:
			new_rot = transform.rotated_local(Vector3.RIGHT, -rotate_degrees)
		elif key.keycode == KEY_LEFT:
			new_rot = transform.rotated_local(Vector3.FORWARD, rotate_degrees)
		elif key.keycode == KEY_RIGHT:
			new_rot = transform.rotated_local(Vector3.FORWARD, -rotate_degrees)
		
		rotate_direction()
		rotate_cube(new_rot)
	
	if event is InputEventMouseButton:
		var mouse_button = event as InputEventMouseButton
		is_panning = mouse_button.is_pressed()
	
	elif event is InputEventMouseMotion:
		var mouse_motion = event as InputEventMouseMotion
		mouse_delta = event.relative

func rotate_cube(new_rotation : Transform3D):
	if is_rotating: return
	is_rotating = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transform", new_rotation, rotate_time)
	
	await tween.finished
	is_rotating = false


func rotate_direction():
	var new_rot : Transform3D
	var cube_dir : Vector3 = transform.basis.z
	var camera_dir : Vector3 = Vector3(camera.basis.z.x, 0, camera.basis.z.z)
#	var new_dir : Vector3 = (cube_dir - camera_dir).normalized()
	
#	marker.position = new_dir
	
	
	print(cube_dir.angle_to(camera_dir))


func pan_cube(delta : float):
	rotate_y(mouse_delta.x * pan_direction * pan_speed * delta)
