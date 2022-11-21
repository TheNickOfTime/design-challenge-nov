extends Control


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


