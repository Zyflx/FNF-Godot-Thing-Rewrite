class_name KeybindButton extends Button

@export var action_name:String
var is_rebinding:bool = false

func _ready() -> void:
	pressed.connect(func(): is_rebinding = true; text = '')
	# print(InputMap.action_get_events(action_name)[0].physical_keycode)
	text = OptionsData.get_bind(action_name)
	
func _unhandled_input(event:InputEvent) -> void:
	if (not is_rebinding): return
	if (event.is_pressed()):
		is_rebinding = false
		for bind in InputMap.action_get_events(action_name): InputMap.action_erase_event(action_name, bind)
		
		var new_bind:String = OS.get_keycode_string(event.keycode)
		text = new_bind
		
		OptionsData.set_bind(action_name, new_bind)
		InputMap.action_add_event(action_name, event)
