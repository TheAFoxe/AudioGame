class_name ChordMaskMenu
extends Control

signal send_chord_mask(chord_mask: Array[bool])

var _chord_mask: Array[bool] = []
@onready var _s6: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer6
@onready var _s5: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5
@onready var _s4: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4
@onready var _s3: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3
@onready var _s2: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var _s1: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer1


func _ready() -> void:
	leave()
	for i in 6:
		_chord_mask.append(false)
	
	for i in 6:
		var button = get("_s%d" % (6 - i)).get_node("Button") as Button
		button.set_meta("id", i)
		button.toggled.connect(_on_button_toggled.bind(i))


func enter() -> void:
	self.show()


func leave() -> void:
	self.hide()


func _send_chord_mask() -> void:
	send_chord_mask.emit(_chord_mask)


func _on_button_toggled(toggled_on: bool, id: int) -> void:
	_chord_mask[id] = toggled_on
	var button = get("_s%d" % (6 - id)).get_node("Button") as Button
	if toggled_on:
		button.text = "Activated"
	else:
		button.text = "Activate"
	_send_chord_mask()


#func _on_s6_toggled(toggled_on: bool) -> void:
	#_chord_mask[0] = true if toggled_on else false
	#_send_chord_mask()
#
#
#func _on_s5_toggled(toggled_on: bool) -> void:
	#_chord_mask[1] = true if toggled_on else false
	#_send_chord_mask()
#
#
#func _on_s4_toggled(toggled_on: bool) -> void:
	#_chord_mask[2] = true if toggled_on else false
	#_send_chord_mask()
#
#
#func _on_s3_toggled(toggled_on: bool) -> void:
	#_chord_mask[3] = true if toggled_on else false
	#_send_chord_mask()
#
#
#func _on_s2_toggled(toggled_on: bool) -> void:
	#_chord_mask[4] = true if toggled_on else false
	#_send_chord_mask()
#
#
#func _on_s1_toggled(toggled_on: bool) -> void:
	#_chord_mask[5] = true if toggled_on else false
	#_send_chord_mask()
