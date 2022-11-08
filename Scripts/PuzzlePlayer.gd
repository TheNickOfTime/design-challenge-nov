extends RigidBody3D


func _ready():
	pass


func _process(delta):
	pass


func _on_puzzle_box_rotate_event(is_rotating : bool):
	self.sleeping = is_rotating