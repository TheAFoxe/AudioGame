extends PickableObject
class_name AudioReflector


func _ready() -> void:
	super()


func receive_chord(chord):
	print("Receieved chord: " + str(chord))
