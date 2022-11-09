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
