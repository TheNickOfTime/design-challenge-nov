extends Control

signal change_level(delta : int)

const fade_in_time : float = 0.25
const fade_out_time : float = 0.5

@onready var level_text : Label = $Label_LevelText
@onready var complete_text : Label = $Label_CompleteText
@onready var button_left : Button = $Button_Left
@onready var button_right : Button = $Button_Right

@export var active_color : Color = Color.WHITE
@export var inactive_color : Color = Color.DARK_GRAY

var ui_tween : Tween

var level_dictionary = [
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight",
	"nine",
	"ten"
]


func _ready():
	complete_text.visible = false


func _process(delta):
	pass


func enable_buttons(is_enabled : bool):
	button_left.disabled = !is_enabled
	button_right.disabled = !is_enabled


func fade_buttons(is_visible : bool):
	if ui_tween != null && ui_tween.is_running():
		ui_tween.kill()
	
	var color : Color = Color.WHITE if is_visible else Color.TRANSPARENT
	var time : float = fade_in_time if is_visible else fade_out_time
	
	ui_tween = get_tree().create_tween()
	ui_tween.tween_property(self, "modulate", color, time)
	
	await ui_tween.finished
	enable_buttons(is_visible)


func _on_button_select_right_button_up():
	change_level.emit(1)


func _on_button_select_left_button_up():
	change_level.emit(-1)


func _on_puzzle_box_manager_new_level(level_index : int, level_ref : Node):
	var level_name : String
	
	if level_index == -1:
		level_name = "???"
	else:
		level_name = level_dictionary[level_index]
		for i in $Level_Indicators.get_child_count():
			var color = active_color if i == level_index else inactive_color
			$Level_Indicators.get_child(i).color = color
	
	level_text.text = "level " + level_name
	complete_text.visible = false
	
	if(level_ref != null):
		level_ref.get_node("Goal").puzzle_complete.connect(self._on_goal_puzzle_complete)
		level_ref.body_exited.connect(self._on_puzzlebox_body_exited)


func _on_camera_camera_moved():
	if !complete_text.visible:
		await fade_buttons(false)


func _on_puzzle_box_manager_pause(is_paused):
	fade_buttons(is_paused)


func _on_puzzle_box_manager_initialize_levels(count):
	var indicator : Node = $Level_Indicators/Indicator
	
	for i in count - 1:
		var new_indicator = indicator.duplicate()
		new_indicator.color = inactive_color
		$Level_Indicators.add_child(new_indicator)


func _on_goal_puzzle_complete():
	complete_text.visible = true
	complete_text.text = "level complete!"
	fade_buttons(true)
#	level_text.text = "level complete!"


func _on_puzzlebox_body_exited(body : Node3D):
	if body.is_in_group("Player"):
		fade_buttons(true)
		level_text.text = "respawning..."
		await get_tree().create_timer(1.5).timeout
		change_level.emit(0)
