extends Node3D

@onready var fade_transition_animation_player: AnimationPlayer = $CanvasLayer/FadeTransition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_transition_animation_player.play("fade_out")
