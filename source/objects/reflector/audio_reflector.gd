class_name AudioReflector
extends PickableObject


func _ready() -> void:
	super()


func receive_chord(chord):
	print("Receieved chord: " + str(chord))
