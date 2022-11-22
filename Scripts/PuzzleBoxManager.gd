extends Node3D

#Signals------------------------------------------------------------------------
signal rotate_event(is_rotating : bool)
signal new_level(level_name : String)

#Export variables---------------------------------------------------------------
@export var puzzles : Array[PackedScene]

#OnReady variables--------------------------------------------------------------
@onready var rotate_degrees : float = deg_to_rad(90)
@onready var puzzle_box : Node3D = $PuzzleBox as Node3D
@onready var camera : Camera3D = $Camera/Camera3D as Camera3D
@onready var transition_cube : Node3D = $TransitionCube

#Member Variables---------------------------------------------------------------
var rotate_time : float = 0.75
var is_rotating : bool = false
var continue_rotating : bool = false
var next_rot : Transform3D
var current_direction : Vector3
var last_direction : Vector3
var current_level_index : int
var transitioning_level : bool

var level_dictionary = [
	"one",
	"two",
	"three",
	"four",
	"five"
]

func _ready():
	print(camera)
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

		new_rot = get_new_rotation(orient_rotation(current_direction))
		rotate_cube(new_rot)
	
	if event is InputEventKey:
		if event.keycode == KEY_ENTER && event.pressed:
			increment_level_index(true)
			swap_puzzle(puzzles[current_level_index])



func rotate_cube(new_rotation : Transform3D):
	if is_rotating: return
	is_rotating = true
	emit_signal("rotate_event", true)
	
	# Wait for rotation to happen
	var tween = get_tree().create_tween()
	tween.tween_property(puzzle_box, "transform", new_rotation, rotate_time)
	await tween.finished

	if continue_rotating:
		continue_rotating = false
		is_rotating = false
		rotate_cube(get_new_rotation(orient_rotation(current_direction)))
		return

	is_rotating = false
	emit_signal("rotate_event", false)


func get_new_rotation(direction : Vector3) -> Transform3D:
	return puzzle_box.transform.rotated(direction, rotate_degrees)

func get_new_rotation_d(direction : Vector3, degrees : float) -> Transform3D:
	return puzzle_box.transform.rotated(direction, degrees)


func orient_rotation(original_direction : Vector3):
	var camera_basis : Vector3 = camera.global_transform.basis.z
	var camera_forward : Vector3 = Vector3(camera_basis.x, 0, camera_basis.z).normalized()
	var invert_vector : bool = abs(camera_forward.x) >= abs(camera_forward.z)
	var snapped_camera : Vector3 = Vector3(camera_forward.x, 0, 0).normalized() if invert_vector else Vector3(0, 0, camera_forward.z).normalized()
	var flipped_direction : Vector3 = Vector3(original_direction.z, 0, original_direction.x)
	var oriented_direction : Vector3 = flipped_direction if invert_vector else original_direction

	match snapped_camera:
		Vector3.FORWARD:
			# print("forward")
			pass
		Vector3.LEFT:
			# print("left")
			oriented_direction.z *= -1
		Vector3.BACK:
			# print("back")
			oriented_direction *= -1
		Vector3.RIGHT:
			# print("right")
			oriented_direction.x *= -1

	return oriented_direction


func puzzle_complete():
	print("puzzle")


func increment_level_index (is_positive : bool):
	current_level_index += 1 if is_positive else -1
	current_level_index = wrap(current_level_index, 0, puzzles.size())
	print(current_level_index)


func swap_puzzle(new_puzzle : PackedScene):
	if transitioning_level: return

	transitioning_level = true

	var old_scene = puzzle_box
	var new_scene = new_puzzle.instantiate()

	#Grow cube
	var transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, "scale", Vector3.ONE, 0.5)
	transition_cube.scale = Vector3.ZERO
	transition_cube.visible = true
	await transition_tween.finished

	#Remove old level
	remove_child(old_scene)
	emit_signal("new_level", "???")

	#Rotate Cube
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:y', transition_cube.rotation.y + deg_to_rad(180), 0.5)
	await transition_tween.finished

	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:x', transition_cube.rotation.x + deg_to_rad(180), 0.5)
	await transition_tween.finished

	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:y', transition_cube.rotation.y + deg_to_rad(180), 0.5)
	await transition_tween.finished

	#Add new level
	add_child(new_scene)
	puzzle_box = new_scene
	emit_signal("new_level", level_dictionary[current_level_index])

	#Shrink Cube
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, "scale", Vector3.ZERO, 0.5)

	await transition_tween.finished
	transitioning_level = false


func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if is_ancestor_of(body):
		var last_position = body.global_position

		remove_child(body)
		body.position = last_position
		get_parent().add_child(body)


func _on_goal_puzzle_complete():
	puzzle_complete()


func _on_hud_change_level(is_positive : bool):
	increment_level_index(is_positive)
	swap_puzzle(puzzles[current_level_index])
