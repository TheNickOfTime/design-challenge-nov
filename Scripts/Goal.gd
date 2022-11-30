extends Area3D


signal puzzle_complete

var player : RigidBody3D
var is_complete : bool


func _ready():
	pass


func _process(delta):
	if player != null && player.sleeping && !is_complete:
		emit_signal("puzzle_complete")
		is_complete = true


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body


func _on_body_exited(body):
	if body.is_in_group("Player"):
		player = null


func _on_puzzle_complete():
	player.get_child(0).mesh.material = get_child(0).mesh.material
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
	$AudioStreamPlayer.play()
