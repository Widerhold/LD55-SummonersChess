extends Control

func _ready():
	EventBus.floor_cleared.connect(on_floor_cleared)

func on_floor_cleared(floor: int):
	$FloorsLabel.text = "FLOORS CLEARED: " + str(floor-1)

func _on_back_to_menu_pressed():
	EventBus.change_game_state.emit(Game.GameState.MENU)


func _on_retry_button_pressed():
	EventBus.change_game_state.emit(Game.GameState.PLAYING)
