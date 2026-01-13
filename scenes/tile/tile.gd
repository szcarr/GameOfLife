extends ColorRect

@export_category("Color")
@export var alive_color: Color = Color.WHITE
@export var dead_color: Color = Color.BLACK

# 1 is alive. 0 is dead.
var tile_value: int = 0

func set_tile_value(n_tile_value: int) -> void:
	self.tile_value = n_tile_value
	if tile_value == 1:
		self.color = alive_color
	else:
		self.color = dead_color


func get_tile_value() -> int:
	return self.tile_value
