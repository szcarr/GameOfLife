extends VBoxContainer

## Script that hides the text when mouse cursor gets close.

# Distance at which fading starts (growth factor)
@export_range(0.0, 1.0, 0.01) var fade_distance: float = 0.8
@export var num_points: int = 6


# Minimum opacity when mouse is very close
@export var min_opacity: float = 0.1

# Point a
var top_left_corner_of_container: Vector2 = global_position
# Point b
var bottom_left_corner_of_container: Vector2 = top_left_corner_of_container + size
# Vector ab
var container_length := Vector2(
	bottom_left_corner_of_container.x - top_left_corner_of_container.x,
	bottom_left_corner_of_container.y - top_left_corner_of_container.y,
)

var all_sample_points: Array[Vector2]


func _process(_delta: float) -> void:
	var point_offset: float = container_length.x / num_points / 2.0
	
	for i: int in num_points:
		var sample_point = Vector2(
				global_position.x + container_length.x / num_points * i + point_offset,
				global_position.y + container_length.y / 2,
		)
		all_sample_points.append(sample_point)
	
	
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	
	var distance_from_all_points: int = 0
	for vec_point: Vector2 in all_sample_points:
		distance_from_all_points += Vector2i(
			int(mouse_position.x - vec_point.x),
			int(mouse_position.y - vec_point.y),
		).length_squared()
	
	#print(distance_from_all_points)
	#print(distance_from_all_points)
	#var start_fade_distance: float = (a_to_mc.length() + b_to_mc.length()) * fade_distance
	#var end_fade_distance: float = container_length.length() * 0.5
	# Calculate target opacity based on distance
	#if start_fade_distance < end_fade_distance: 
		#print(end_fade_distance, "  ", start_fade_distance, " AB: ", container_length.length() / 2.0)
		#modulate.a = lerp(
			#min_opacity,
			#1.0,
			#clampf((start_fade_distance - container_length.length() / 2.0) / (end_fade_distance - container_length.length() / 2.0), 0.0, 1.0)
		#)
	
	#if distance < fade_distance:
		# Map distance (0 to fade_distance) to opacity (min_opacity to 1.0)
	#	target_opacity = remap(distance, 0, fade_distance, min_opacity, 1.0)
	
	
	
	#await get_tree().create_timer(0.01)
