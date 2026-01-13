extends Node2D


@export_category("Generation")
@export var map_size_horizontal: int = 300
@export var game_seed: int = -1
@export_range(0.0, 1.0, 0.01) var alive_bias = 0.1

@export_category("Settings")
@export var fps_limit: int = 20

var map_size := Vector2i(int(map_size_horizontal), int(map_size_horizontal * 0.5625))
var map: Dictionary
var rng := RandomNumberGenerator.new()
var tile: PackedScene = preload("res://scenes/tile/Tile.tscn")

var neighbors: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

func _ready() -> void:
	initialize_settings()
	initialize_world()
	display_map()
	

# Old map vs new map.
func _process(_delta: float) -> void:
	call_deferred("generate_map")
	pass

func initialize_settings() -> void:
	Engine.set_max_fps(fps_limit)


func initialize_world() -> void:
	rng.set_seed(game_seed)
	var resolution := Vector2(
			int(ProjectSettings.get_setting("display/window/size/viewport_width")),
			int(ProjectSettings.get_setting("display/window/size/viewport_height")),
	)
	var tile_size := Vector2(resolution.x / map_size.x, resolution.y / map_size.y)
	for y: int in map_size.y:
		for x: int in map_size.x:
			var new_tile = tile.instantiate()
			var tile_value = 1 if rng.randf_range(0.0, 1.0) < alive_bias else 0
			new_tile.set_tile_value(tile_value)
			new_tile.set_size(tile_size)
			new_tile.set_position(Vector2(x * tile_size.x, y * tile_size.y))
			map[Vector2i(x, y)] = new_tile


# Handles data in the map.
## Creates the map that will show in the next frame.
func generate_map() -> void:
	for current_position: Vector2i in map.keys():
		var alive_neighbors := 0
		var current_tile_value: int = map.get(current_position).get_tile_value()
		for vector_offset: Vector2i in neighbors:
			var neighbor_position = current_position + vector_offset
			var neighbor_tile = map.get(neighbor_position)
			if neighbor_tile != null:
				if neighbor_tile.get_tile_value() == 1: # Neighbor is alive
					alive_neighbors += 1
		if alive_neighbors < 2: # Die of loneliness
			map.get(current_position).set_tile_value(0)
		elif current_tile_value == 0 and alive_neighbors == 3: # Rebirth
			map.get(current_position).set_tile_value(1)
		elif current_tile_value == 1 and alive_neighbors == 2 or alive_neighbors == 3: # Survive
			map.get(current_position).set_tile_value(1)
		elif current_tile_value == 1 and alive_neighbors > 3: # Overpopulation
			map.get(current_position).set_tile_value(0)


## Only needs to be called once.
func display_map() -> void:
	for current_position: Vector2i in map.keys():
		self.add_child(map.get(current_position))
