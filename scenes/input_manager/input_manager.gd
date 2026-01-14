extends Node

## This file handles inputs.

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		set_alive_tile()
		await get_tree().create_timer(0.01).timeout


## On left click sets the tile to alive regardless of game rules.
func set_alive_tile() -> void:
	var world_position: Vector2i = get_viewport().get_mouse_position()
	if world_position.x > 0 and world_position.y > 0:
		var world_tile_size: Vector2 = Map.get_tile_size()
		var tile_position = Vector2i(
				floori(world_position.x / world_tile_size.x),
				floori(world_position.y / world_tile_size.y),
		)
		var value_map_queue: Dictionary = Map.get_value_map_queue()
		value_map_queue[tile_position] = 1
		Map.set_value_map_queue(value_map_queue)
