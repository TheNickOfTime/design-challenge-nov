extends RigidBody2D

@export var speed : float = 20

var new_position : Vector2

@onready var teleport : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _integrate_forces(state):
#	if teleport:
#		state.transform = Transform2D(0.0, new_position)
#		print("wow")
#		teleport = false
