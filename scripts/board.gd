@tool
extends Node2D
class_name Board

@export var cell_size = 32
@export var grid_height = 8
@export var grid_width = 8
@export var ground_tile: PackedScene

@export var fire_scene: PackedScene
@export var water_scene: PackedScene
@export var earth_scene: PackedScene
@export var air_scene: PackedScene
@export var player_scene: PackedScene
@export var enemy_scene: PackedScene

@export var fire_color = Color(1, 0, 0)
@export var water_color = Color(0, 0, 1)
@export var earth_color = Color(0.5, 0.5, 0.5)
@export var air_color = Color(1, 1, 1)

var grid: = []
var tiles: = []
#var enemies: = []
var mouseover_tile: BoardTile = null
#var elements: Array[Element] = []
#var new_elements: Array[Element] = []

func _ready():
	for i in range(grid_width):
		grid.append([])
		tiles.append([])
		for j in range(grid_height):
			grid[i].append(null)
			var tile = ground_tile.instantiate()
			tile.position = Vector2(i * cell_size, j * cell_size)
			tiles[i].append(tile)
			add_child(tile)

	#Register preplaced pieces
	for child in get_tree().get_nodes_in_group("Piece"):
		var grid_position = convert_to_grid_position(child.transform.origin)
		grid[grid_position.x][grid_position.y] = child

func check_win_condition() -> bool:
	#Check if no enemies are left
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			if piece is Enemy:
				return false
	return true

func reset() -> void:
	grid = []
	for i in range(grid_width):
		grid.append([])
		for j in range(grid_height):
			grid[i].append(null)
	#Get all children and remove them
	var children = get_children()
	for child in children:
		if child is BoardTile:
			continue
		child.queue_free()
			
func init(floor: int) -> void:
	#Spawn the player in the mid lower half randomly
	var player = player_scene.instantiate()	
	var player_position = Vector2(randi() % grid_width, (randi() % grid_height) / 2 + grid_height / 2)
	player.position = Vector2(player_position.x * cell_size, player_position.y * cell_size)
	grid[player_position.x][player_position.y] = player
	add_child(player)

	#Spawn the enemies in the upper half randomly
	#Increase enemy every 3 floors
	var enemy_count = max(floor / 3 + 1, 1)

	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		var enemy_position = Vector2(randi() % grid_width, randi() % (grid_height / 2))
		while grid[enemy_position.x][enemy_position.y] != null:
			enemy_position = Vector2(randi() % grid_width, randi() % (grid_height / 2))
		enemy.position = Vector2(enemy_position.x * cell_size, enemy_position.y * cell_size)
		grid[enemy_position.x][enemy_position.y] = enemy
		add_child(enemy)

	#Spawn the elements randomly
	var element_count = floor / 2 + 1
	for i in range(element_count):
		#Pick between earth and air
		var element_type = Element.Type.EARTH if randi() % 2 == 0 else Element.Type.AIR
		var element = null
		var element_position = Vector2(randi() % grid_width, randi() % grid_height)
		while grid[element_position.x][element_position.y] != null:
			element_position = Vector2(randi() % grid_width, randi() % grid_height)
		if element_type == Element.Type.EARTH:
			element = earth_scene.instantiate()
		elif element_type == Element.Type.AIR:
			element = air_scene.instantiate()
		element.position = Vector2(element_position.x * cell_size, element_position.y * cell_size)
		grid[element_position.x][element_position.y] = element
		add_child(element)

func turn() -> void:
	#Clear all the highlights
	clear_highlights()
	process_elements()
	process_enemies()
	highlight_next_moves_elements()

func process_enemies():
	var enemies = []
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			if piece is Enemy:
				enemies.append(piece)
	
	for enemy in enemies:
		enemy.process(self)

func place_summon(piece: Piece, tile: BoardTile, element_type: Element.Type) -> void:
	var grid_position = convert_to_grid_position(tile.transform.origin)
	#Check distance between player and target
	var player_position = convert_to_grid_position(piece.transform.origin)
	if abs(player_position.x - grid_position.x) > 1 or abs(player_position.y - grid_position.y) > 1:
		#print("Invalid summon position")
		return

	if grid[grid_position.x][grid_position.y] == null:
		var element = null
		if element_type == Element.Type.FIRE:
			element = fire_scene.instantiate()
			var piece_position = convert_to_grid_position(piece.transform.origin)
			var direction = Vector2(grid_position.x - piece_position.x, grid_position.y - piece_position.y)
			element.directions = [direction]
		elif element_type == Element.Type.WATER:
			element = water_scene.instantiate()
			var piece_position = convert_to_grid_position(piece.transform.origin)
			var direction = Vector2(grid_position.x - piece_position.x, grid_position.y - piece_position.y)
			element.directions = [direction]
		elif element_type == Element.Type.EARTH:
			element = earth_scene.instantiate()
		elif element_type == Element.Type.AIR:
			element = air_scene.instantiate()
		element.position = tile.position
		element.state = Element.State.CREATED
		add_child(element)
		grid[grid_position.x][grid_position.y] = element
	elif grid[grid_position.x][grid_position.y] is Element:
		# var element = grid[grid_position.x][grid_position.y] as Element
		# if element.type == Element.Type.FIRE and element_type == Element.Type.WATER:
		# 	element.destroyed()
		# 	grid[grid_position.x][grid_position.y] = null
		# elif element.type == Element.Type.WATER and element_type == Element.Type.FIRE:
		# 	element.destroyed()
		# 	grid[grid_position.x][grid_position.y] = null
		# elif element.type == element_type:
		# 	element.queue_free()
		# 	var scene = get_scene_for_type(element_type)
		# 	element = fire_scene.instantiate()
		# 	var piece_position = convert_to_grid_position(piece.transform.origin)
		# 	var direction = Vector2(grid_position.x - piece_position.x, grid_position.y - piece_position.y)
		# 	element.directions = [direction]
		# 	element.position = tile.position
		# 	element.state = Element.State.CREATED
		# 	add_child(element)
		# 	grid[grid_position.x][grid_position.y] = element
		pass
		
func get_scene_for_type(element_type: Element.Type) -> PackedScene:
	if element_type == Element.Type.FIRE:
		return fire_scene
	elif element_type == Element.Type.WATER:
		return water_scene
	elif element_type == Element.Type.EARTH:
		return earth_scene
	return air_scene

func mark_as_processed(pos: Vector2) -> void:
	var piece = get_piece_at(pos)
	if piece is Element:
		var element = piece as Element
		element.state = Element.State.PROCESSED

func place_player_summon(tile: BoardTile, element_type: Element.Type) -> void:
	var player = get_player()
	place_summon(player, tile, element_type)
	EventBus.summon_placed.emit(element_type)
	EventBus.turn_complete.emit()

func process_elements():
	#print("Processing elements")
	var elements = []
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			if piece is Element:
				var element = piece as Element
				elements.append(element)
	
	for element in elements:
		if element != null:
			element.process(self)

func get_tile_at(pos: Vector2) -> BoardTile:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return null
	return tiles[pos.x][pos.y]

func is_blocked_by_type(pos: Vector2, type: Element.Type) -> bool:
	return grid[pos.x][pos.y] != null and grid[pos.x][pos.y].type == type

func get_player() -> Player:
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			if piece is Player:
				return piece
	return null

func highlight_next_moves_elements(init=false) -> void:
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			if piece is Element:
				var element = piece as Element
				if element.state == Element.State.PROCESSED:
					continue
				var grid_position = Vector2(i, j)
				for direction in element.directions:
					#If it has no direction it does not move so skip
					if direction == Vector2(0, 0):
						continue

					var next_field = Vector2(grid_position.x + direction.x, grid_position.y + direction.y)
					if is_in_grid(next_field):
						if element.type == Element.Type.FIRE:
							tiles[next_field.x][next_field.y].highlight(fire_color)
						elif element.type == Element.Type.WATER:
							tiles[next_field.x][next_field.y].highlight(water_color)

func is_in_grid(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func convert_to_grid_position(pos: Vector2) -> Vector2:
	var x = int(pos.x / cell_size)
	var y = int(pos.y / cell_size)
	return Vector2(x, y)

func move(tile: BoardTile) -> void:
	var grid_position = convert_to_grid_position(tile.transform.origin)
	#"Tile clicked at: ", grid_position.x, grid_position.y)
	#Assign first the udpated grid position and then move the player
	var player = get_player()
	var player_grid_position = convert_to_grid_position(player.transform.origin)
	if validate_move(player_grid_position, grid_position):
		if is_blocked_by_type(grid_position, Piece.Type.AIR):
			#Check if the position is one field away
			var direction = Vector2(grid_position.x - player_grid_position.x, grid_position.y - player_grid_position.y)
			var temp_grid_position = Vector2(grid_position.x + direction.x, grid_position.y + direction.y)
			if validate_move(grid_position, temp_grid_position):
				grid_position = temp_grid_position
			else:
				EventBus.invalid_move.emit()
				return

		grid[player_grid_position.x][player_grid_position.y] = null
		grid[grid_position.x][grid_position.y] = player
		move_piece_to(player, Vector2(grid_position.x * cell_size, grid_position.y * cell_size))
		# highlight_possible_moves(player)
		EventBus.moved.emit()
	else:
		EventBus.invalid_move.emit()

func move_enemy(enemy: Enemy, target_position: Vector2) -> void:
	var enemy_position = convert_to_grid_position(enemy.transform.origin)
	if is_blocked_by_type(target_position, Piece.Type.AIR):
		#Check if the position is one field away
		var direction = Vector2(target_position.x - enemy_position.x, target_position.y - enemy_position.y)
		var temp_target_position = Vector2(target_position.x + direction.x, target_position.y + direction.y)
		if validate_move(enemy_position, temp_target_position):
			target_position = temp_target_position
		else:
			return
	grid[enemy_position.x][enemy_position.y] = null
	grid[target_position.x][target_position.y] = enemy
	move_piece_to(enemy, Vector2(target_position.x * cell_size, target_position.y * cell_size), false)

# func highlight_possible_moves(player: Piece) -> void:
# 	var grid_position = convert_to_grid_position(player.transform.origin)
# 	for i in range(grid_width):
# 		for j in range(grid_height):
# 			var piece = get_piece_at(Vector2(i, j))
# 			#Check if the piece is an element and if its air
# 			if piece != null and piece is Element and piece.type == Element.Type.AIR:
# 				#Find direction of the element relative to the player
# 				var direction = Vector2(i - grid_position.x, j - grid_position.y)
# 				if abs(direction.x) > 1 or abs(direction.y) > 1:
# 					continue
# 				var next_field = Vector2(i + direction.x, j + direction.y)
# 				#Check if the next field is within the grid
# 				if next_field.x >= 0 and next_field.x < grid_width and next_field.y >= 0 and next_field.y < grid_height:
# 					#Check if the next field is blocked by an element
# 					if not is_blocked_by_element(next_field):
# 						tiles[next_field.x][next_field.y].highlight()


# 			if abs(grid_position.x - i) <= 1 and abs(grid_position.y - j) <= 1 and not is_blocked_by_element(Vector2(i, j)):
# 				tiles[i][j].highlight()

func mouse_over(tile: BoardTile) -> void:
	if mouseover_tile != tile and mouseover_tile != null:
		mouseover_tile.hide_overlay()

	var grid_position = convert_to_grid_position(tile.transform.origin)
	var player = get_player()
	var player_position = convert_to_grid_position(player.transform.origin)
	if is_in_grid(grid_position) and player != null:
		var direction = Vector2(grid_position.x - player_position.x, grid_position.y - player_position.y)
		if abs(direction.x) > 1 or abs(direction.y) > 1:
			return

		#print("Mouse over tile: ", grid_position.x, grid_position.y)
		tile.show_overlay()
		mouseover_tile = tile


func possible_moves(player: Piece) -> Array[Vector2]:
	var grid_position = convert_to_grid_position(player.transform.origin)
	var moves = []
	for i in range(grid_width):
		for j in range(grid_height):
			var piece = get_piece_at(Vector2(i, j))
			#Check if the piece is an element and if its air
			if piece != null and piece is Element and piece.type == Element.Type.AIR:
				#Find direction of the element relative to the player
				var direction = Vector2(i - grid_position.x, j - grid_position.y)
				if abs(direction.x) > 1 or abs(direction.y) > 1:
					continue
				var next_field = Vector2(i + direction.x, j + direction.y)
				#Check if the next field is within the grid
				if next_field.x >= 0 and next_field.x < grid_width and next_field.y >= 0 and next_field.y < grid_height:
					#Check if the next field is blocked by an element
					if not is_blocked_by_element(next_field):
						moves.append(next_field)

			if abs(grid_position.x - i) <= 1 and abs(grid_position.y - j) <= 1 and not is_blocked_by_element(Vector2(i, j)):
				moves.append(Vector2(i, j))
	return moves


func clear_highlights():
	for i in range(grid_width):
		for j in range(grid_height):
			tiles[i][j].clear_highlight()

func move_piece_to(piece: Piece, target_position: Vector2, with_callback: bool = true):
	set_process(false)
	var tween = get_tree().create_tween()
	tween.tween_property(piece, "position", target_position, 0.1)
	if with_callback:
		tween.tween_callback(_on_move_completed)

func _on_move_completed():
	set_process(true)
	EventBus.turn_complete.emit()

func clear_piece_at(pos: Vector2) -> void:
	var piece = get_piece_at(pos)
	if piece != null:
		grid[pos.x][pos.y] = null
		if piece is Enemy:
			piece.destroyed()
		else:
			piece.queue_free()

func set_piece_at(pos: Vector2, piece: Piece) -> void:
	grid[pos.x][pos.y] = piece

func spawn_element_at(position, grid_position, element_type: Element.Type, directions: Array[Vector2], state: Element.State) -> Element:
		var scene = null
		if element_type == Element.Type.FIRE:
			scene = fire_scene
		elif element_type == Element.Type.WATER:
			scene = water_scene
		elif element_type == Element.Type.EARTH:
			scene = earth_scene
		elif element_type == Element.Type.AIR:
			scene = air_scene

		var new_element = scene.instantiate()
		new_element.position = position
		new_element.directions = directions
		new_element.state = state
		add_child(new_element)
		grid[grid_position.x][grid_position.y] = new_element
		move_piece_to(new_element, Vector2(grid_position.x * cell_size, grid_position.y * cell_size), false)
		#"Spawned element: ", element_type, " at: ", grid_position.x, grid_position.y)
		return new_element

func get_piece_at(pos: Vector2) -> Piece:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return null
	return grid[pos.x][pos.y]

func is_blocked_by_element(pos: Vector2) -> bool:
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return true
	return grid[pos.x][pos.y] != null and grid[pos.x][pos.y] is Element

func validate_move(piece_position, pos: Vector2, check_distance=true) -> bool:
	if check_distance and abs(piece_position.x - pos.x) > 1 or abs(piece_position.y - pos.y) > 1:
		return false

	#Check for grid boundaries
	if pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height:
		return false

	#Check if air element is between the player and the target position
	var target_piece = get_piece_at(pos)
	if target_piece != null and is_blocked_by_type(pos, Piece.Type.AIR):
		return true

	#Check if the position is blocked by another element
	if is_blocked_by_element(pos):
		return false
		
	if is_blocked_by_type(pos, Piece.Type.PLAYER):
		return false

	if is_blocked_by_type(pos, Piece.Type.ENEMY):
		return false

	return true
