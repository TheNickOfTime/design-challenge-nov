extends MeshInstance3D

signal finished_rotating

var rotate_time : float = 0.75
@onready var rotate_degrees : float = deg_to_rad(90)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventKey && event.is_pressed():
		var key = event as InputEventKey
		var new_rot : Transform3D
		
		if key.keycode == KEY_UP:
			new_rot = transform.rotated(Vector3.RIGHT, rotate_degrees)
		elif key.keycode == KEY_DOWN:
			new_rot = transform.rotated(Vector3.RIGHT, -rotate_degrees)
		elif key.keycode == KEY_LEFT:
			new_rot = transform.rotated(Vector3.UP, rotate_degrees)
		elif key.keycode == KEY_RIGHT:
			new_rot = transform.rotated(Vector3.UP, -rotate_degrees)
		
		rotate_cube(new_rot)

func rotate_cube(new_rotation : Transform3D):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "transform", new_rotation, rotate_time)
	
	await tween.finished
