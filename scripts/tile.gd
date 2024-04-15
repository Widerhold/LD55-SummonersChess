extends Node2D
class_name BoardTile

@export var clear_color = Color(1, 1, 1, 1)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	#Left click
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
		EventBus.move_selected.emit(self)
	#Right click
	elif(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.pressed):
		EventBus.place_summon.emit(self)
	elif(event is InputEventMouseMotion):
		EventBus.mouse_over.emit(self)
		
func highlight(color: Color = Color(1, 1, 1, 1)):
	$Sprite.modulate = color

func show_overlay():
	$Overlay.visible = true

func hide_overlay():
	$Overlay.visible = false

func clear_highlight():
	$Sprite.modulate = clear_color
