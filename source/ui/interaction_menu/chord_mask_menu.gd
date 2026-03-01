class_name InteractionMenu
extends Control

signal receive_mask(note_filter: Array[bool])

var _note_filter: Array[bool] = []

@onready var _s6: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer6
@onready var _s5: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5
@onready var _s4: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4
@onready var _s3: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3
@onready var _s2: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var _s1: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer1


func _ready() -> void:
	leave()
	for i in 6: 
		_note_filter.append(false)


func enter() -> void:
	self.show()


func leave() -> void:
	self.hide()


func _send_note_filter() -> void:
	receive_mask.emit(_note_filter)


func _on_s6_toggled(toggled_on: bool) -> void:
	_note_filter[0] = toggled_on
	_send_note_filter()


func _on_s5_toggled(toggled_on: bool) -> void:
	_note_filter[1] = toggled_on
	_send_note_filter()


func _on_s4_toggled(toggled_on: bool) -> void:
	_note_filter[2] = toggled_on
	_send_note_filter()


func _on_s3_toggled(toggled_on: bool) -> void:
	_note_filter[3] = toggled_on
	_send_note_filter()


func _on_s2_toggled(toggled_on: bool) -> void:
	_note_filter[4] = toggled_on
	_send_note_filter()


func _on_s1_toggled(toggled_on: bool) -> void:
	_note_filter[5] = toggled_on
	_send_note_filter()
