extends TextureButton

@export var key_text: String
@export var cost_text: String
@export var icon : Texture
@export var base_color : Color
@export var select_color : Color
@export var skill_type: Element.Type

func _ready():
	EventBus.selected_element_type_changed.connect(on_selected_element_type_changed)
	$Icon.texture = icon
	$Key.text = key_text
	$Cost.text = cost_text

func on_selected_element_type_changed(selected_element_type: Element.Type):
	if selected_element_type == skill_type:
		modulate = select_color
	else:
		modulate = base_color
