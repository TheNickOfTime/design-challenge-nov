extends Control

signal change_level(is_positive : bool)

const fade_in_time : float = 0.5
const fade_out_time : float = 1.0

@onready var level_text : Label = $Label_LevelText
@onready var complete_text : Label = $Label_CompleteText
@onready var button_left : Button = $Button_Left
@onready var button_right : Button = $Button_Right


func _ready():
	complete_text.visible = false


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


func enable_buttons(is_enabled : bool):
	button_left.disabled = !is_enabled
	button_right.disabled = !is_enabled

func fade_buttons(is_visible : bool):
	var color : Color = Color.WHITE if is_visible else Color.TRANSPARENT
	var time : float = fade_in_time if is_visible else fade_out_time
	
	var level_text_tween : Tween = get_tree().create_tween()
	level_text_tween.tween_property(level_text, "modulate", color, time)
	
	var complete_text_tween : Tween = get_tree().create_tween()
	complete_text_tween.tween_property(complete_text, "modulate", color, time)
	
	var button_left_tween : Tween = get_tree().create_tween()
	button_left_tween.tween_property(button_left, "modulate", color, time)
	
	var button_right_tween: Tween = get_tree().create_tween()
	button_right_tween.tween_property(button_right, "modulate", color, time)
	
	await level_text_tween.finished
	enable_buttons(is_visible)


func _on_button_select_right_button_up():
	emit_signal("change_level", true)
	pass


func _on_button_select_left_button_up():
	emit_signal("change_level", false)
	pass


func _on_puzzle_box_manager_new_level(level_name : String):
	level_text.text = "level " + level_name


func _on_camera_camera_moved():
	var level_text_tween : Tween = get_tree().create_tween()
	level_text_tween.tween_property(level_text, "modulate", Color.TRANSPARENT, 1)
	
	var complete_text_tween : Tween = get_tree().create_tween()
	complete_text_tween.tween_property(complete_text, "modulate", Color.TRANSPARENT, 1)
	
	var button_left_tween : Tween = get_tree().create_tween()
	button_left_tween.tween_property(button_left, "modulate", Color.TRANSPARENT, 1)
	
	var button_right_tween: Tween = get_tree().create_tween()
	button_right_tween.tween_property(button_right, "modulate", Color.TRANSPARENT, 1)
	
	await level_text_tween.finished
	enable_buttons(false)


func _on_puzzle_box_manager_pause(is_paused):
	fade_buttons(true)
