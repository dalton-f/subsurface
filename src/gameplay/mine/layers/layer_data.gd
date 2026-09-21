class_name LayerData
extends Resource

@export var layer_name: StringName
@export var min_depth: int
@export var max_depth: int
@export var ores: Array[OreData]

var sorted_ores: Array[OreData]

func update_sorted_ores() -> void:
	sorted_ores = ores.duplicate()
	sorted_ores.sort_custom(_sort_by_rarity)

func _sort_by_rarity(a: OreData, b: OreData) -> bool:
	return a.rarity > b.rarity
