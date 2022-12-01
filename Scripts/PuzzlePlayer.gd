extends RigidBody3D

signal player_sleeping


func _ready():
	start_sequence()
	pass


func _process(delta):
	pass


func start_sequence():
	var start_timer = get_tree().create_timer(1)
	await start_timer.timeout
	freeze = false


func _on_puzzle_box_rotate_event(is_rotating : bool):
	freeze = is_rotating
#	print("freeze: ", is_rotating)


func _on_sleeping_state_changed():
	if sleeping && !freeze:
		position = position.snapped(Vector3.ONE * 0.1)
		player_sleeping.emit()
		$AudioStreamPlayer.play()
		print_debug("snapped position")
