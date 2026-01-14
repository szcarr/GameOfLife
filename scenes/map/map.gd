extends Node2D


@export_category("Generation")
@export var map_size_horizontal: int = 12
@export var game_seed: int = -1
@export_range(0.0, 1.0, 0.01) var alive_bias = 0.1

@export_category("Settings")
@export var fps_limit: int = 20

@onready var generation_label: RichTextLabel = $GenerationLabel

var map_size := Vector2i(int(map_size_horizontal), int(map_size_horizontal * 0.5625))
var rng := RandomNumberGenerator.new()
var tile: PackedScene = preload("res://scenes/tile/Tile.tscn")
var tile_size := Vector2(0, 0)
var mutex := Mutex.new()

var value_map: Dictionary = {}
var tile_map: Dictionary = {}
var value_map_queue: Dictionary = {} # Used by InputManager

var generation_counter: int = 0

var neighbors: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

func _ready() -> void:
	_initialize_settings()
	_initialize_world()
	_display_map(value_map)


func _process(_delta: float) -> void:
	value_map = _generate_map(value_map)
	_update_map(value_map)
	generation_counter += 1


## Tile size is determined at runtime dynamically based on horizontal size set in the inspector.
## See 'initialize_world' func.
func get_tile_size() -> Vector2:
	return tile_size


func get_value_map(enable_process: bool = true) -> Dictionary:
	set_process(enable_process)
	return value_map


func get_value_map_queue() -> Dictionary:
	mutex.lock()
	var queue_map = value_map_queue.duplicate()
	mutex.unlock()
	return queue_map


func set_value_map(map: Dictionary, enable_process: bool = true) -> void:
	value_map = map
	set_process(enable_process)


func set_value_map_queue(map: Dictionary) -> void:
	mutex.lock()
	value_map_queue = map
	mutex.unlock()


## Needs to be called once.
func _display_map(current_map: Dictionary) -> void:
	for current_position: Vector2i in current_map.keys():
		self.add_child(tile_map.get(current_position))


## Handles data in the map.
## Creates the map that will show in the next frame.
func _generate_map(current_map: Dictionary) -> Dictionary:
	var next_map: Dictionary = {}
	for current_position: Vector2i in current_map.keys():
		# Values from the user takes priority.
		# If no values from user, iterate over gamerules.
		mutex.lock()
		if value_map_queue.get(current_position) != null:
			print(value_map_queue, current_map.get(current_position))
			next_map[current_position] = value_map_queue.get(current_position)
			value_map_queue.erase(current_position)
			mutex.unlock()
			continue
		mutex.unlock()
		var alive_neighbors := 0
		var current_tile_value: int = current_map.get(current_position)
		for vector_offset: Vector2i in neighbors:
			var neighbor_position = current_position + vector_offset
			if current_map.get(neighbor_position) == 1: # Neighbor is alive
				alive_neighbors += 1
		# Determining tile value
		if alive_neighbors < 2: # Die of loneliness
			next_map[current_position] = 0
		elif current_tile_value == 0 and alive_neighbors == 3: # Rebirth
			next_map[current_position] = 1
		elif current_tile_value == 1 and 1 < alive_neighbors and alive_neighbors < 4: # Survive
			next_map[current_position] = 1
		elif current_tile_value == 1 and alive_neighbors > 3: # Overpopulation
			next_map[current_position] = 0
		else:
			next_map[current_position] = current_map.get(current_position)
	return next_map


func _initialize_settings() -> void:
	Engine.set_max_fps(fps_limit) # Determines the max amount of generations each second.


## Creating and assigning tiles to its position.
## Also assigns values to map dict for the first generation/frame.
func _initialize_world() -> void:
	rng.set_seed(game_seed)
	var resolution := Vector2(
			int(ProjectSettings.get_setting("display/window/size/viewport_width")),
			int(ProjectSettings.get_setting("display/window/size/viewport_height")),
	)
	tile_size = Vector2(resolution.x / map_size.x, resolution.y / map_size.y)
	for y: int in map_size.y:
		for x: int in map_size.x:
			var new_tile = tile.instantiate()
			var tile_value = 1 if rng.randf_range(0.0, 1.0) < alive_bias else 0
			value_map[Vector2i(x, y)] = tile_value
			new_tile.set_tile_value(tile_value)
			new_tile.set_size(tile_size)
			new_tile.set_position(Vector2(x * tile_size.x, y * tile_size.y))
			tile_map[Vector2i(x, y)] = new_tile


## Needs to be called every frame
func _update_map(current_map: Dictionary) -> void:
	generation_label.call_deferred("set_text", "Generation: %s" % [generation_counter])
	for tile_position: Vector2i in tile_map.keys():
		var tile_value = current_map.get(tile_position)
		tile_map.get(tile_position).set_tile_value(tile_value)
		
	
