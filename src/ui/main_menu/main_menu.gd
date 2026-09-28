extends Control

enum MenuState {
	INTRO,
	MAIN,
	OPTIONS,
	CREDITS
}

@export_category("Intro")
@export var typing_speed: float = 0.2
@export var fade_duration: float = 2.0
@export var menu_animation_duration: float = 0.5

var current_state: MenuState = MenuState.INTRO

@onready var game_title: Label = $MainMarginContainer/MainVBoxContainer/GameTitle
@onready var background_color_rect: ColorRect = $BackgroundColorRect
@onready var buttons_container: VBoxContainer = $MainMarginContainer/MainVBoxContainer/ButtonsContainer

@onready var play_button: Button = $MainMarginContainer/MainVBoxContainer/ButtonsContainer/PlayButton
@onready var settings_button: Button = $MainMarginContainer/MainVBoxContainer/ButtonsContainer/SettingsButton
@onready var credits_button: Button = $MainMarginContainer/MainVBoxContainer/ButtonsContainer/CreditsButton
@onready var quit_button: Button = $MainMarginContainer/MainVBoxContainer/ButtonsContainer/QuitButton

func _ready() -> void:
	_setup_menu()
	_connect_buttons()
	_play_intro()

func _setup_menu() -> void:
	current_state = MenuState.INTRO

	game_title.visible_ratio = 0.0

	buttons_container.modulate.a = 0.0
	buttons_container.offset_transform_position.y += 30

func _connect_buttons() -> void:	
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _play_intro() -> void:
	var duration: float = game_title.text.length() * typing_speed
	
	# Playing game title typing animation
	var typing_tween: Tween = create_tween()
	
	typing_tween.tween_property(
		game_title,
		"visible_ratio",
		1.0,
		duration
	)
	
	# Pause at the end
	await typing_tween.finished
	await get_tree().create_timer(0.8).timeout
	
	# Fade the black overlay out to reveal background texture
	var fade_tween: Tween = create_tween()
	
	fade_tween.tween_property(
		background_color_rect,
		"modulate:a",
		0.0,
		fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Pause for less time at the end
	await fade_tween.finished
	await get_tree().create_timer(0.5).timeout
	
	# Show buttons
	buttons_container.visible = true
	
	var button_tween: Tween = create_tween()
	button_tween.set_parallel(true)
	
	button_tween.tween_property(
		buttons_container,
		"modulate:a",
		1.0,
		menu_animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	button_tween.tween_property(
		buttons_container,
		"offset_transform_position:y",
		buttons_container.offset_transform_position.y - 30,
		menu_animation_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Ensure current state gets updated
	await button_tween.finished
	current_state = MenuState.MAIN

func _on_play_pressed() -> void:
	print("Play pressed")

func _on_settings_pressed() -> void:
	print("Settings pressed")

func _on_credits_pressed() -> void:
	print("Credits pressed")

func _on_quit_pressed() -> void:
	print("Quit pressed")
