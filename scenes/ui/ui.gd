extends CanvasLayer

@onready var generation_label := %GenerationLabel
@onready var seed_label := %SeedLabel

## Can return null if called before it is assigned.
## Else will return RichTextLabel.
func get_generation_label() -> Variant:
	return generation_label


## Can return null if called before it is assigned.
## Else will return RichTextLabel.
func get_seed_label() -> Variant:
	return seed_label


func set_generation_label_text(text: String) -> void:
	generation_label.set_text(text)


func set_seed_label_text(text: String) -> void:
	seed_label.set_text(text)
