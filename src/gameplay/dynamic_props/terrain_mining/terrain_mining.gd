extends Node3D

@onready var drill_module: MeshInstance3D = $DrillStructure/DrillModule
@onready var timer: Timer = $Timer
@onready var dust_particles: GPUParticles3D = $DustParticles
@onready var rock_particles: GPUParticles3D = $RockParticles

var drill_strength := 0.0

var drilling := false

func _ready():
	var delay: float = randf_range(0.5, 5.0)
	
	# Cause a random delay for each drill so they don't start at the same time
	await get_tree().create_timer(delay).timeout
	
	timer.start()
	# Random time between each drill movement
	timer.wait_time = randf_range(4.4, 7.4)
	
	_drill()

func _process(_delta):
	if not drilling:
		return
		
	drill_module.position = (Vector3.RIGHT *0.03 * sin(Time.get_ticks_msec() / 50.0)).rotated(Vector3.UP, randf() * TAU) * drill_strength
	drill_module.position.y = abs(sin(Time.get_ticks_msec() / 50.0) *0.3) * drill_strength
	
func _on_drill_timer_timeout():
	_drill()

func _drill():
	drilling = true
		
	var tween = create_tween()
	
	tween.tween_property(drill_module, "position:y", 0.0, 0.8).from(1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(_particles_on)

	
	tween.tween_property(self, "drill_strength", 0.5, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(drill_module, "position:y", 1.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_delay(1.8)
	
	tween.set_parallel(true).tween_property(self, "drill_strength", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_delay(1.4)
	tween.set_parallel(true).tween_callback(_particles_off).set_delay(1.4)
	
	await tween.finished
	
	drilling = false

func _particles_on():
	dust_particles.emitting = true
	rock_particles.emitting = true

func _particles_off():
	dust_particles.emitting = false
	rock_particles.emitting = false
