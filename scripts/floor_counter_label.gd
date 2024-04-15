extends Label

func _ready():
	EventBus.floor_cleared.connect(on_floor_cleared)
	EventBus.change_game_state.connect(on_game_state_changed)

func on_game_state_changed(_state):
	text = str(1)
	
func on_floor_cleared(floor: int):
	text = str(floor)
