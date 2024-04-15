extends Piece
class_name Enemy

var directions = [
	Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1),
	Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)
]

var current_power = 5
var max_power = 5

func process(board: Board) -> void:
	next_action(board)

func next_action(board: Board) -> void:
	print("Enemy next action")
	var player = board.get_player()
	if player == null:
		return
	
	var player_pos = player.get_position()
	var enemy_pos = board.convert_to_grid_position(transform.origin)

	var distance = abs(player_pos.x - enemy_pos.x) + abs(player_pos.y - enemy_pos.y)

	# If the distance between player and enemy is less than 1, attempt to cast an earth summon
	if distance == 1:
		var tile = board.get_tile_at(player_pos)
		if tile != null:
			board.place_summon(self, tile, Element.Type.EARTH)
			EventBus.game_over.emit()

	#Check all surrounding tiles for an element that is targeting the enemy
	for direction in directions:
		var new_pos = enemy_pos + direction
		var tile = board.get_tile_at(new_pos)
		if tile != null and board.is_blocked_by_element(new_pos):
			var element = board.get_piece_at(new_pos)
			#Check all directions of the element to see if it is targeting the enemy
			for element_direction in element.directions:
				var element_pos = new_pos + element_direction
				if element_pos == enemy_pos:
					#Move in the opposite direction of the element
					var opposite_direction = -element_direction
					new_pos = enemy_pos + opposite_direction
					if board.validate_move(enemy_pos, new_pos):
						board.move_enemy(self, new_pos)
						return

	var direction_vector = get_direction_vector(enemy_pos, player_pos)
	print("Direction vector: ", direction_vector)
	var new_pos = enemy_pos + direction_vector  # Add direction vector to move towards the player
	var tile = board.get_tile_at(new_pos)
	if tile != null and not board.is_blocked_by_element(new_pos) and not board.is_blocked_by_type(new_pos, Element.Type.ENEMY) and not board.is_blocked_by_type(new_pos, Element.Type.PLAYER):
		#Each element has an 30% chance of being summoned
		if randi() % 100 < 30:
			board.place_summon(self, tile, Element.Type.FIRE)
			#current_power -= 3
		elif randi() % 100 < 30:
			board.place_summon(self, tile, Element.Type.WATER)
			#current_power -= 2
		elif randi() % 100 < 30:
			board.place_summon(self, tile, Element.Type.EARTH)
			#current_power -= 1
		elif randi() % 100 < 30:
			board.place_summon(self, tile, Element.Type.AIR)
			#current_power -= 1
		else:
			move_randomly(board, enemy_pos)
	elif tile != null:
		move_randomly(board, enemy_pos)

func get_direction_vector(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	var diff = to_pos - from_pos
	var norm_x = 0 if diff.x == 0 else (1 if diff.x < 0 else -1)
	var norm_y = 0 if diff.y == 0 else (1 if diff.y > 0 else -1)
	return Vector2(norm_x, norm_y)

func move_randomly(board: Board, enemy_pos: Vector2) -> void:
	var possible_directions = []
	for direction in directions:
		var new_pos = enemy_pos + direction
		if board.validate_move(enemy_pos, new_pos, false):
			possible_directions.append(direction)

	# Pick one random direction to move
	if possible_directions.size() > 0:
		current_power += 1
		var direction = possible_directions[randi() % possible_directions.size()]
		var new_pos = enemy_pos + direction
		board.move_enemy(self, new_pos)
