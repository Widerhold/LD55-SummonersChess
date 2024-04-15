extends Piece
class_name Element

@export var directions: Array = []
@export var state = State.CREATED
@export var max_lifespan: int = 999999
@export var lifespan: int = 999999
@export var movement_length: int = 0
@export var decays: bool = false

@export var scene: PackedScene

enum State { CREATED, PROCESSING, PROCESSED }

func _ready():
	super()
	lifespan = max_lifespan
	if decays:
		$LifespanLabel.text = str(lifespan)
	else:
		$LifespanLabel.hide()

static func process_spread(spreading_element: Element, board: Board, scaled_direction: Vector2, normal_direction, new_element_state = State.PROCESSING) -> Element:
	var grid_position = board.convert_to_grid_position(spreading_element.transform.origin)
	var next_field = Vector2(grid_position.x + scaled_direction.x, grid_position.y + scaled_direction.y)
	if next_field.x >= 0 and next_field.x < board.grid_width and next_field.y >= 0 and next_field.y < board.grid_height:
		if board.is_blocked_by_element(next_field) and board.get_piece_at(next_field).type == spreading_element.type:
			#Delete the element and create a new one so that it can spread further
			board.clear_piece_at(next_field)
			return board.spawn_element_at(spreading_element.position, next_field, spreading_element.type, [normal_direction], new_element_state)
		if board.is_blocked_by_element(next_field) and board.get_piece_at(next_field).type != Element.Type.EARTH:
			#board.clear_piece_at(next_field)
			board.mark_as_processed(next_field)
			return null
		elif board.is_blocked_by_element(next_field) and board.get_piece_at(next_field).type == Element.Type.EARTH:
			return null
		elif board.is_blocked_by_type(next_field, Piece.Type.PLAYER):
			print("Was blocked by player")
			EventBus.game_over.emit()
			var player = board.get_piece_at(next_field)
			player.destroyed()
			return null
			#return board.spawn_element_at(spreading_element.position, next_field, spreading_element.type, [normal_direction], new_element_state)
		elif board.is_blocked_by_type(next_field, Piece.Type.ENEMY):
			print("Was blocked by enemy")
			var enemy = board.get_piece_at(next_field)
			board.clear_piece_at(next_field)
			EventBus.enemy_killed.emit(enemy)
		
			return null #board.spawn_element_at(spreading_element.position, next_field, spreading_element.type, [normal_direction], new_element_state)
		else:
			return board.spawn_element_at(spreading_element.position, next_field, spreading_element.type, [normal_direction], new_element_state)
	return null
		
func process(board: Board):
	if state == State.CREATED:
		state = State.PROCESSING
		return

	elif state == State.PROCESSING:
		lifespan -= 1
		for direction in directions:
			for i in range(movement_length):
				var new_element_state = State.PROCESSING if i == movement_length -1 else State.PROCESSED
				var scaled_direction = direction * (i+1)
				var spreaded_element = process_spread(self, board, scaled_direction, direction, new_element_state)
				if spreaded_element == null:
					break
		state = State.PROCESSED
	elif state == State.PROCESSED:
		lifespan -= 1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2.ONE * float(lifespan) / float(max_lifespan), 0.5)
		if lifespan <= 0:
			board.clear_piece_at(board.convert_to_grid_position(transform.origin))
	$LifespanLabel.text = str(lifespan)

func next_moves(board: Board) -> Array[Vector2]:
	return [Vector2(0, 0)]

static func next_element(element_type: Element.Type) -> Element.Type:
	match element_type:
		Element.Type.WATER:
			return Element.Type.FIRE
		Element.Type.FIRE:
			return Element.Type.AIR
		Element.Type.AIR:
			return Element.Type.EARTH
		Element.Type.EARTH:
			return Element.Type.WATER
	return Element.Type.AIR


static func prev_element(element_type: Element.Type) -> Element.Type:
	match element_type:
		Element.Type.WATER:
			return Element.Type.EARTH
		Element.Type.FIRE:
			return Element.Type.WATER
		Element.Type.AIR:
			return Element.Type.FIRE
		Element.Type.EARTH:
			return Element.Type.AIR
	return Element.Type.AIR
