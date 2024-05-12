class_name MainMenu
extends Control

@export var main_ui:Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var start_level = preload("res://dev/jesse/main.tscn") as PackedScene


func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)

func on_start_pressed() -> void:
	#get_tree().change_scene_to_packed(start_level)
	visible = false
	main_ui.visible = true


func on_exit_pressed() -> void:
	get_tree().quit()
