extends Node3D

#Signals------------------------------------------------------------------------
signal rotate_event(is_rotating : bool)
signal new_level(level_index : int, level_ref : Node)
signal pause(is_paused : bool)
signal initialize_levels(count : int)
#signal freeze_input(is_frozen : bool)

#Export variables---------------------------------------------------------------
@export var puzzles : Array[PackedScene]
@export var transition_sounds : Array[AudioStream]
@export var rotate_sounds : Array[AudioStream]
@export var cube_sounds : Array[AudioStream]

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
var is_paused : bool
var allow_input : bool


func _ready():
#	print(camera)
#	var players = get_tree().get_nodes_in_group("Player")
#	for player in players:
#		pass
	
	emit_signal("initialize_levels", puzzles.size())
	pause_game(true)
	swap_puzzle(puzzles[current_level_index])


func _process(delta):
#	print(is_paused)
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

		if allow_input:
			new_rot = get_new_rotation(orient_rotation(current_direction))
			rotate_cube(new_rot)
	
	if event.is_action_pressed("pause"):
		pause_game(!is_paused)


func pause_game(pause_state : bool):
	is_paused = pause_state
	emit_signal("pause", is_paused)


func rotate_cube(new_rotation : Transform3D):
	if is_rotating: return
	is_rotating = true
	allow_input = false
	emit_signal("rotate_event", true)
	
	# Wait for rotation to happen
	var tween = get_tree().create_tween()
	tween.tween_property(puzzle_box, "transform", new_rotation, rotate_time)
#	var index = randi_range(0, 1)
	play_new_sound(rotate_sounds[1])
	await tween.finished

	if continue_rotating:
		continue_rotating = false
		is_rotating = false
		rotate_cube(get_new_rotation(orient_rotation(current_direction)))
	else:
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
			pass
		Vector3.LEFT:
			oriented_direction.z *= -1
		Vector3.BACK:
			oriented_direction *= -1
		Vector3.RIGHT:
			oriented_direction.x *= -1

	return oriented_direction


func puzzle_complete():
	allow_input = false


func increment_level_index (delta : int):
	current_level_index += delta
	current_level_index = wrap(current_level_index, 0, puzzles.size())
#	print(current_level_index)


func swap_puzzle(new_puzzle : PackedScene):
	if transitioning_level: return

	transitioning_level = true
	allow_input = false

	var old_scene = puzzle_box
	var new_scene = new_puzzle.instantiate()

	#Grow cube
	play_new_sound(cube_sounds[0])
	var transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, "scale", Vector3.ONE, 0.5)
	transition_cube.scale = Vector3.ZERO
	transition_cube.visible = true
	await transition_tween.finished

	#Remove old level
	if old_scene != null:
		remove_child(old_scene)
		emit_signal("new_level", -1, null)

	#Rotate Cube
	play_new_sound(transition_sounds[0])
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:y', transition_cube.rotation.y + deg_to_rad(180), 0.7)
	await transition_tween.finished
	
	play_new_sound(transition_sounds[1])
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:x', transition_cube.rotation.x + deg_to_rad(180), 0.7)
	await transition_tween.finished
	
	play_new_sound(transition_sounds[2])
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, 'rotation:y', transition_cube.rotation.y + deg_to_rad(180), 0.7)
	await transition_tween.finished

	#Add new level
	add_child(new_scene)
	puzzle_box = new_scene
	emit_signal("new_level", current_level_index, puzzle_box)
	
	#Connect signals
	rotate_event.connect(puzzle_box.get_node("Player")._on_puzzle_box_rotate_event)
	puzzle_box.body_exited.connect(self._on_puzzlebox_body_exited)
	puzzle_box.get_node("Goal").puzzle_complete.connect(self._on_goal_puzzle_complete)
	puzzle_box.get_node("Player").player_sleeping.connect(self._on_player_player_sleeping)

	#Shrink Cube
	play_new_sound(cube_sounds[0])
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_cube, "scale", Vector3.ZERO, 0.5)

	await transition_tween.finished
	transitioning_level = false
#	allow_input = true


func play_new_sound(audio_stream : AudioStream):
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = audio_stream
	add_child(player)
	
	player.play()
	await player.finished
	player.queue_free()


func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if is_ancestor_of(body):
		var last_position = body.global_position

		remove_child(body)
		body.position = last_position
		get_parent().add_child(body)


func _on_goal_puzzle_complete():
	puzzle_complete()


func _on_player_player_sleeping():
	allow_input = true


func _on_hud_change_level(delta : int):
	if !transitioning_level:
		increment_level_index(delta)
		swap_puzzle(puzzles[current_level_index])


func _on_camera_camera_moved():
	pass
#	pause_game(false)

func _on_puzzlebox_body_exited(body : Node3D):
	if body.is_in_group("Player"):
		puzzle_box.monitoring = false
