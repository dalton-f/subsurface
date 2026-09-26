class_name MineManager
extends Node3D

const BLOCK_SIZE: float = 1.8

static var instance: MineManager

@export_category("Mine Settings")
@export var width: int = 11:
	set(value):
		width = value
		_generate_top_layer()
		
@export var depth: int = 11:
	set(value):
		depth = value
		_generate_top_layer()

@export var layers: Array[LayerData]

@export_category("Fallback Settings")
@export var fallback_block: OreData:
	set(value):
		fallback_block = value
		_generate_top_layer()

var blocks: Dictionary = {}
var mined_blocks: Dictionary = {}

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	for layer in layers:
			layer.update_sorted_ores()
			
	_generate_top_layer()

func _generate_top_layer() -> void:
	if fallback_block == null:
		return
	
	# Clear existing blocks inside the mine
	for child in get_children():
		child.queue_free()

	# Reset the mine data
	blocks.clear()
	mined_blocks.clear()
	
	# Generate new top layer
	for x in range(width):
		for z in range(depth):
			@warning_ignore("integer_division")
			var pos: Vector3 = Vector3(x - width / 2, 0, z - depth / 2)
			
			# Because layers only exist as placeholders while inside the editor,
			# just default to using the fallback_block so we can visualise the mine area
			# while still generating ores on the top layer in the actual game
			var block: OreData = fallback_block if Engine.is_editor_hint() else _get_random_ore(0)
			_set_block(pos, block)

func _has_block(pos: Vector3) -> bool:
	return blocks.has(pos)

func _get_block(pos: Vector3) -> OreData: 
	if not blocks.has(pos): 
		return null 
		
	return blocks[pos]["ore"]

func _set_block(pos: Vector3, block: OreData) -> void:
	if block == null:
		return
	
	if mined_blocks.has(pos): 
		return

	var block_instance := block.scene.instantiate()
	add_child(block_instance)
	
	block_instance.name = "%d_%d_%d" % [pos.x, pos.y, pos.z]
	block_instance.position = Vector3(pos) * BLOCK_SIZE
	block_instance.rotation_degrees = Vector3(
		randi_range(0, 3) * 90,
		randi_range(0, 3) * 90,
		randi_range(0, 3) * 90
	)
	
	blocks[pos] = {
		"ore": block,
		"node": block_instance
	}

func _remove_block(pos: Vector3) -> void: 
	if not _has_block(pos): 
		return 
	
	var block_data: Dictionary = blocks[pos] 
	var block_instance: Node3D = block_data["node"] 
	
	blocks.erase(pos) 
	mined_blocks[pos] = true 
	
	if block_instance != null: 
		if Engine.is_editor_hint(): 
			block_instance.free() 
		else: 
			block_instance.queue_free()
	
func _is_in_bounds(pos: Vector3) -> bool:
	@warning_ignore("integer_division")
	var min_x := -width / 2
	var max_x := min_x + width - 1
	
	@warning_ignore("integer_division")
	var min_z := -depth / 2
	var max_z := min_z + depth - 1

	return (
		pos.x >= min_x and pos.x <= max_x
		and pos.z >= min_z and pos.z <= max_z and
		pos.y <= 0
	)

func _get_random_ore(ore_depth: int) -> OreData:
	var layer: LayerData = get_layer(ore_depth)
	
	# If no layers defined, just spawn fallback block
	if layer == null:
		return fallback_block

	for ore in layer.sorted_ores:
		if ore == null or ore.rarity <= 0:
			continue

		# Whichever ore hits rarity first gets spawned
		if randi_range(1, ore.rarity) == ore.rarity:
			return ore

	return fallback_block

func get_layer(ore_depth: int) -> LayerData:
	for layer in layers:
		if abs(ore_depth) >= layer.min_depth and abs(ore_depth) < layer.max_depth:
			return layer

	return null

func mine_block(pos: Vector3) -> void:
	if not _has_block(pos):
		return

	# Remove the mined block
	_remove_block(pos)

	var adjacent_positions := [
		pos + Vector3(1, 0, 0),
		pos + Vector3(-1, 0, 0),
		pos + Vector3(0, 1, 0),
		pos + Vector3(0, -1, 0),
		pos + Vector3(0, 0, 1),
		pos + Vector3(0, 0, -1)
	]

	for adjacent_pos in adjacent_positions:
		# Don't overwrite an existing block
		if _has_block(adjacent_pos):
			continue

		if _is_in_bounds(adjacent_pos):
			var random_ore = _get_random_ore(adjacent_pos.y)
			
			_set_block(adjacent_pos, random_ore)
