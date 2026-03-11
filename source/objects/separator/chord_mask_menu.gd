class_name ChordMaskMenu
extends Control

signal send_chord_mask(chord_mask: Array[bool])

var _chord_mask: Array[bool] = []
@onready var _s6: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer6
@onready var _s5: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5
@onready var _s4: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4
@onready var _s3: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3
@onready var _s2: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var _s1: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2


func _ready() -> void:
	leave()
	for i in 6: _chord_mask.append(false)


func enter() -> void:
	self.show()


func leave() -> void:
	self.hide()


func _on_clear_pressed() -> void:
	pass


func _send_chord_mask() -> void:
	send_chord_mask.emit(_chord_mask)


func _on_s6_toggled(toggled_on: bool) -> void:
	_chord_mask[0] = true if toggled_on else false
	_send_chord_mask()


func _on_s5_toggled(toggled_on: bool) -> void:
	_chord_mask[1] = true if toggled_on else false
	_send_chord_mask()


func _on_s4_toggled(toggled_on: bool) -> void:
	_chord_mask[2] = true if toggled_on else false
	_send_chord_mask()


func _on_s3_toggled(toggled_on: bool) -> void:
	_chord_mask[3] = true if toggled_on else false
	_send_chord_mask()


func _on_s2_toggled(toggled_on: bool) -> void:
	_chord_mask[4] = true if toggled_on else false
	_send_chord_mask()


func _on_s1_toggled(toggled_on: bool) -> void:
	_chord_mask[5] = true if toggled_on else false
	_send_chord_mask()
