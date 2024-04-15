extends Piece
class_name Player

@export var angle_offset: float = -30

func _process(delta):
	# Get the mouse position relative to the viewport
	var mouse_pos = get_viewport().get_mouse_position()
	# Get the global position of the Staff node
	var staff_pos = $Sprite/Staff.global_position
	# Calculate the angle from the staff to the mouse
	var angle = (mouse_pos - staff_pos).angle()
	# Set the staff's rotation to this angle
	$Sprite/Staff.rotation = angle + angle_offset
