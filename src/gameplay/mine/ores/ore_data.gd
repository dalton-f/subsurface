class_name OreData
extends Resource

@export var id: StringName
@export var scene: PackedScene

## The ore has a 1 in rarity chance of being selected.
@export_range(1, 2500) var rarity: int = 1
