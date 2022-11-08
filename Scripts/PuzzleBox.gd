extends MeshInstance3D

#Signals------------------------------------------------------------------------
signal rotate_event(is_rotating : bool)

#Export variables---------------------------------------------------------------
@export var camera : Camera3D
@export var marker : Node3D

#OnReady variables--------------------------------------------------------------
@onready var rotate_degrees : float = deg_to_rad(90)

#Member Variables---------------------------------------------------------------
var rotate_time : float = 0.75
var is_rotating : bool = false
var continue_rotating : bool = false
var next_rot : Transform3D


func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		pass



func _process(delta):
	pass


func _input(event):

	if event.is_action_pressed("rotate_cube"):
		
		var new_rot : Transform3D

		if event.is_action_pressed("rotate_cube_up"):
			new_rot = transform.rotated(Vector3.RIGHT, rotate_degrees)
		elif event.is_action_pressed("rotate_cube_down"):
			new_rot = transform.rotated(Vector3.RIGHT, -rotate_degrees)
		elif event.is_action_pressed("rotate_cube_left"):
			new_rot = transform.rotated(Vector3.FORWARD, rotate_degrees)
		elif event.is_action_pressed("rotate_cube_right"):
			new_rot = transform.rotated(Vector3.FORWARD, -rotate_degrees)
		
		if is_rotating:
			continue_rotating = true

		rotate_cube(new_rot)



func rotate_cube(new_rotation : Transform3D):
	if is_rotating: return
	is_rotating = true
	emit_signal("rotate_event", true)
	
	# Wait for rotation to happen
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transform", new_rotation, rotate_time)
	await tween.finished

	if continue_rotating:
		continue_rotating = false
		is_rotating = false
		rotate_cube(transform.rotated(Vector3.FORWARD, -rotate_degrees))
		return

	is_rotating = false
	emit_signal("rotate_event", false)


# func rotate_direction():
# 	var new_rot : Transform3D
# 	var cube_dir : Vector3 = transform.basis.z
# 	var camera_dir : Vector3 = Vector3(camera.basis.z.x, 0, camera.basis.z.z)
