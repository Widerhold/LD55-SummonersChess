extends Control



func _on_play_button_pressed():
	EventBus.change_game_state.emit(Game.GameState.PLAYING)


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
