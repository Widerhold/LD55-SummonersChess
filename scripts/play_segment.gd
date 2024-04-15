extends AudioStreamPlayer

var start_time = 5.0
var end_time = 10.0
var is_playing_segment = false

@export var segments: Array[Vector2] = []

func _process(delta):
	if is_playing_segment:
		if get_playback_position() >= end_time:
			stop()
			is_playing_segment = false

func play_segment(i):
	var time = segments[i]
	start_time = time.x
	end_time = time.y
	seek(time.x)
	play()
	is_playing_segment = true
