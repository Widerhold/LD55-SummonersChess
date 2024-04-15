extends Label

var power = 0
var max_power = 0

func _ready():
	EventBus.max_power_changed.connect(on_max_power_changed)
	EventBus.current_power_changed.connect(on_power_changed)
	print("Power Label Ready")

func on_power_changed(new_power: int):
	#print("power changed")
	power = new_power
	update_text()

func on_max_power_changed(new_max_power: int):
	#print("max power changed")
	max_power = new_max_power
	update_text()

func update_text():
	text = str(power) + "/" + str(max_power)
	set_text(text)
