extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_onclick)
	pass # Replace with function body.

func _onclick():
	var line = get_node("../LineEdit")
	var t = line.text
	
	var person = get_node("../OptionButton").text
	person = int(person)
	HttpManager.ask_question(t, person, get_parent())
	
	
