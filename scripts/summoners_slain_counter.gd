extends Label

var counter = 0

func _ready():
	EventBus.enemy_killed.connect(on_enemy_slain)
	EventBus.change_game_state.connect(on_game_state_changed)

func on_game_state_changed(_state):
	counter = 0	
	text = str(counter)

func on_enemy_slain(_enemy):
	counter += 1
	text = str(counter)
