extends Node2D
class_name Game

@export var power:int = 5
@export var max_power:int = 5
@export var current_game_state: GameState = GameState.MENU

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
enum TurnState { PLAYER, AI }

var turn_state = TurnState.PLAYER

var selected_element_type = Element.Type.FIRE
var enemies_killed = 0
var floor = 1

func _ready():
	EventBus.move_selected.connect(on_move_selected)
	EventBus.invalid_move.connect(on_invalid_move)
	EventBus.turn_complete.connect(on_turn_complete)
	EventBus.place_summon.connect(on_place_summon)
	EventBus.summon_placed.connect(on_summon_placed)
	EventBus.moved.connect(on_moved)
	EventBus.mouse_over.connect($Board.mouse_over)
	EventBus.change_game_state.connect(change_game_state)
	EventBus.game_over.connect(game_over)
	EventBus.enemy_killed.connect(on_enemy_killed)

	$Board.clear_highlights()
	$Board.highlight_next_moves_elements(true)

	EventBus.max_power_changed.emit(max_power)
	EventBus.current_power_changed.emit(power)
	EventBus.selected_element_type_changed.emit(selected_element_type)

	change_game_state(current_game_state)

func on_enemy_killed(enemy: Enemy):
	$EnemySlainAudio.play()

	print("Enemy killed")
	if current_game_state != GameState.PLAYING:
		return
	enemies_killed += 1
	print("Checking win condition")
	var won = $Board.check_win_condition()

	if won:
		print("Won")
		var tween = get_tree().create_tween()
		var floor_solved_label = $UI/Play/FloorClearedLabel
		floor_solved_label.show()
		floor_solved_label.scale = Vector2(0, 0)
		floor_solved_label.text = "FLOOR " + str(floor) + " CLEARED!"
		tween.tween_property(floor_solved_label, "scale", Vector2(1, 1), 1)
		tween.tween_property(floor_solved_label, "scale", Vector2(0, 0), 1)
		tween.tween_callback(next_floor)

	else:
		print("Not yet")

func next_floor():
	floor += 1
	$Board.reset()
	$Board.init(floor)
	EventBus.floor_cleared.emit(floor)

func on_move_selected(tile: BoardTile):
	if current_game_state != GameState.PLAYING:
		return

	turn_state = TurnState.AI
	$Board.move(tile)

func on_place_summon(tile: BoardTile):
	if current_game_state != GameState.PLAYING:
		return
	$Board.place_player_summon(tile, selected_element_type)

func element_cost (element: Element.Type) -> int:
	match element:
		Element.Type.AIR:
			return 1
		Element.Type.EARTH:
			return 1
		Element.Type.WATER:
			return 2
		Element.Type.FIRE:
			return 3
	return 0

func on_summon_placed(element: Element.Type):
	print("Summon placed: ", element)
	power -= element_cost(element)
	EventBus.current_power_changed.emit(power)
	$Board.highlight_next_moves_elements()
	
func on_moved():
	power = min(power + 1, max_power)
	EventBus.current_power_changed.emit(power)

func on_invalid_move():
	turn_state = TurnState.PLAYER

func on_turn_complete():
	if current_game_state != GameState.PLAYING:
		return

	turn_state = TurnState.AI
	$Board.turn()

var input_timer = Timer.new()
var debounce_duration = 0.5

func _input(_event):
	if current_game_state != GameState.PLAYING:
		return

	if Input.is_action_just_pressed("select_air"):
		selected_element_type = Element.Type.AIR
		EventBus.selected_element_type_changed.emit(selected_element_type)
	if Input.is_action_just_pressed("select_earth"):
		selected_element_type = Element.Type.EARTH
		EventBus.selected_element_type_changed.emit(selected_element_type)
	if Input.is_action_just_pressed("select_water"):
		selected_element_type = Element.Type.WATER
		EventBus.selected_element_type_changed.emit(selected_element_type)
	if Input.is_action_just_pressed("select_fire"):
		selected_element_type = Element.Type.FIRE
		EventBus.selected_element_type_changed.emit(selected_element_type)
	if Input.is_action_just_released("select_previous_element") and input_timer.is_stopped():
		selected_element_type = Element.prev_element(selected_element_type)
		EventBus.selected_element_type_changed.emit(selected_element_type)
		input_timer.start()
	if Input.is_action_just_released("select_next_element") and input_timer.is_stopped():
		selected_element_type = Element.next_element(selected_element_type)
		EventBus.selected_element_type_changed.emit(selected_element_type)
		input_timer.start()

func start_game():
	$Board.reset()
	floor = 1
	$Board.init(floor)

func game_over():
	print("Game Over")
	change_game_state(GameState.GAME_OVER)
	#TODO Play death audio scream
	#TODO Show game over screen

func change_game_state(state: GameState):
	
	# #Check for allowed transitions
	# if state == GameState.GAME_OVER and current_game_state != GameState.PLAYING:
	# 	return 

	# if state == GameState.PLAYING:
	# 	if current_game_state == GameState.GAME_OVER:
	# 		return

	# 	return

	# if state == GameState.PAUSED and current_game_state != GameState.PLAYING:
	# 	return
	# if state == GameState.MENU and current_game_state != GameState.GAME_OVER:
	# 	return

	current_game_state = state
	match state:
		GameState.MENU:
			$UI/Menu.show()
			$UI/Play.hide()
			$Board.hide()
			$UI/GameOver.hide()
		GameState.PLAYING:
			start_game()
			$UI/Menu.hide()
			$UI/Play.show()
			$Board.show()
			$UI/GameOver.hide()
		GameState.PAUSED:
			$UI/Menu.show()
			$UI/Play.hide()
			$Board.hide()
			$UI/GameOver.hide()
		GameState.GAME_OVER:
			$UI/Menu.hide()
			$UI/Play.hide()
			$Board.hide()
			$UI/GameOver.show()
