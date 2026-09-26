extends GridMap

@export var rules: Array[GridMapReplacementRule] = []

var spawn_index: float = 0

func _ready() -> void:
	replace_items()

func replace_items() -> void:
	if mesh_library == null:
		return

	# Build lookup dictionary
	var lookup := {}

	for rule in rules:
		lookup[rule.target_name] = rule.replacement_scene

	# Look at every cell in the gridmap
	for cell in get_used_cells():
		# Get the id
		var item_id := get_cell_item(cell)

		if item_id == INVALID_CELL_ITEM:
			continue

		# Check for what item is at this cell
		var item_name := mesh_library.get_item_name(item_id)

		# If we don't have a matching item in the lookup dictionary, skip it
		if not lookup.has(item_name):
			continue

		# Otherwise instantiate the replacement scene
		var scene: PackedScene = lookup[item_name]
		var instance = scene.instantiate()

		# Copy the position
		var world_pos := to_global(map_to_local(cell))

		# Copy the rotation
		var orientation := get_cell_item_orientation(cell)
		var cell_basis := get_basis_with_orthogonal_index(orientation)

		# Apply transform and rename
		instance.global_transform = Transform3D(cell_basis, world_pos)
		instance.name = "%s_%d" % [item_name, spawn_index]
		
		# Track replacement count
		spawn_index += 1

		# Add the child and clear the gridmap cell
		get_parent().add_child.call_deferred(instance)

		set_cell_item(cell, INVALID_CELL_ITEM)
