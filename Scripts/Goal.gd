extends Area3D


signal puzzle_complete


func _ready():
	pass


func _process(delta):
	pass


func _on_body_shape_entered(body_rid:RID, body:Node3D, body_shape_index:int, local_shape_index:int):
	if body.is_in_group("Player"):
		emit_signal("puzzle_complete")
