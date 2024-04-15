# extends TileMap
# class_name Board

# @export var cell_size: Vector2 = Vector2(32, 32)

# enum CELL_TYPE { EMPTY = -1, PLAYER, FIRE, WATER, EARTH, WIND, GOAL, ENEMY }

# func _ready():
# 	#Registering all the custom pieces
# 	for child in get_children():
# 		set_cell(1, local_to_map(child.position), child.type)

# func validate_move(piece, direction):
# 	var cell_start = local_to_map(piece.position)
# 	var cell_target = cell_start + Vector2i(round(direction.x), round(direction.y)) 
	
# 	var cell_target_type = get_cell_tile_data(1, cell_target)
# 	match cell_target_type:
# 		CELL_TYPE.EMPTY:
			
# 	return update_piece_position(piece, cell_start, cell_target)

# func update_piece_position(piece: Piece, cell_start: Vector2i, cell_target: Vector2i):
# 	set_cell(1, cell_target, piece.type)
# 	set_cell(1, cell_start, CELL_TYPE.EMPTY)
# 	#Setting pivot to center of cell
# 	return map_to_local(cell_target) + cell_size / 2


# func get_cell_piece(position: Vector2, type: CELL_TYPE):
# 	for node in get_children():
# 		if node.position == position and node.type == type:
# 			return node

