extends Area3D

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
var current_direction : Vector3
var last_direction : Vector3


func _ready():
	print(position.distance_to(camera.position))

	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		pass


func _process(delta):
	pass


func _input(event):

	if event.is_action_pressed("rotate_cube"):
		
		var new_rot : Transform3D

		last_direction = current_direction

		if event.is_action_pressed("rotate_cube_up"):
			current_direction = Vector3.RIGHT
		elif event.is_action_pressed("rotate_cube_down"):
			current_direction = Vector3.LEFT
		elif event.is_action_pressed("rotate_cube_left"):
			current_direction = Vector3.FORWARD
		elif event.is_action_pressed("rotate_cube_right"):
			current_direction = Vector3.BACK
		
		if is_rotating && current_direction == last_direction:
			continue_rotating = true

		new_rot = transform.rotated(current_direction, rotate_degrees)
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
		rotate_cube(get_new_rotation(last_direction))
		return

	is_rotating = false
	emit_signal("rotate_event", false)


func get_new_rotation(direction : Vector3) -> Transform3D:
	return transform.rotated(direction, rotate_degrees)


func orient_rotation(original_direction : Vector3):
	var camera_basis : Vector3 = camera.global_transform.basis.z
	var camera_forward : Vector3 = Vector3(camera_basis.x, 0, camera_basis.z).normalized()
	var something : bool = abs(camera_forward.x) >= abs(camera_forward.z)

	return original_direction if something else Vector3(original_direction.z, 0, original_direction.x)


func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if is_ancestor_of(body):
		var last_position = body.global_position

		remove_child(body)
		body.position = last_position
		get_parent().add_child(body)
