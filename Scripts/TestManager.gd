extends Node2D

@export var spaceship : PackedScene

var spawn_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton:
		var mouse : InputEventMouseButton = event
		
		if mouse.button_index == 1:
			if mouse.pressed:
				spawn_position = get_global_mouse_position()
				print(spawn_position)
			else:
				var end_position : Vector2
				
				end_position = get_global_mouse_position()
#				print(end_position)
				
				var new_velocity = spawn_position - end_position
				new_velocity = new_velocity.normalized()
#				print(new_velocity)
				
				var spawned_spaceship : RigidBody2D = spaceship.instantiate()
				spawned_spaceship.position = spawn_position
				spawned_spaceship.linear_velocity = new_velocity * 150
				add_child(spawned_spaceship)
				print(spawned_spaceship.position)
