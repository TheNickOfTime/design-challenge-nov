extends Control

signal change_level(is_positive : bool)

@export var test_text : Label


func _ready():
	# pass
	pulsate_text(test_text)


func _process(delta):
	pass


func pulsate_text(element : Control):
	var pulsate_tween_out = get_tree().create_tween()
	pulsate_tween_out.tween_property(element, "scale", Vector2.ONE * 1.25, 0.5)

	await pulsate_tween_out.finished
	print("wow")

	var pulsate_tween_in = get_tree().create_tween()
	pulsate_tween_in.tween_property(element, "scale", Vector2.ONE, 0.5)

	await pulsate_tween_in.finished

	pulsate_text(element)


func _on_button_select_right_button_up():
	emit_signal("change_level", true)
	pass

func _on_button_select_left_button_up():
	emit_signal("change_level", false)
	pass


func _on_puzzle_box_manager_new_level(level_name : String):
	$Label_Level.text = "level " + level_name