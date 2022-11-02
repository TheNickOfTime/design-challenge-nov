extends Area2D

@export var gravity_strength : float = 1

var spaceship : RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	if spaceship != null:
		#calculate direction between planet and spaceship
		var direction : Vector2
		direction = position - spaceship.position
		direction = direction.normalized()
		
		spaceship.linear_velocity += direction * gravity_strength


func _on_body_entered(body):
	if body is RigidBody2D:
		spaceship = body as RigidBody2D


func _on_body_exited(body):
	if body == spaceship:
		spaceship = null
