@tool
extends Node2D
class_name Piece

enum Type { PLAYER, FIRE, WATER, EARTH, AIR, GOAL, ENEMY }
@export var type: Type = Type.PLAYER

func _ready():		
	var tween = get_tree().create_tween().set_parallel(true)
	$Sprite.scale = Vector2.ZERO
	tween.tween_property($Sprite, "scale", Vector2.ONE, 0.5)
	tween.tween_property($SummoningCircle, "scale", Vector2.ONE, 0.2)
	$SummoningCircle.scale = Vector2.ZERO
	tween.chain().tween_property($SummoningCircle, "scale", Vector2.ZERO, 0.2)

func destroyed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 1)
	tween.tween_callback(queue_free)
