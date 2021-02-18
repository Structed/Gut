extends SceneTree


class InputSender:
	extends Node2D

	var _waited = 0
	var _pause = .25

	var keys = []
	var actions = []

	signal key_done
	signal action_done
	signal done

	func _process(delta):
		_waited += delta
		if(_waited >= _pause):
			_waited = 0
			_send_next_key()
			_send_next_action()

	func _send_next_key():
		if(keys.size() > 0):
			var k = keys.pop_front()
			var event = InputEventKey.new()
			event.set_scancode(k[0])
			event.set_pressed(k[1])

			print("sending key ", k)
			Input.parse_input_event(event)

			if(keys.size() == 0):
				emit_signal("key_done")
				if(actions.size() == 0):
					emit_signal("done")

	func _send_next_action():
		if(actions.size() > 0):
			var action = actions.pop_front()
			var event = InputEventAction.new()
			event.set_action(action[0])
			event.set_pressed(action[1])

			print("sending action", action)
			Input.parse_input_event(event)

			if(actions.size() == 0):
				emit_signal("action_done")
				if(keys.size() == 0):
					emit_signal("done")


class InputProcessor:
	extends Node2D

	func _process(delta):
		if(Input.is_action_just_pressed("foo")):
			print(self, " fooed")


class ControlInputHandler:
	extends Control

	func _gui_input(event):
		pass

	func _input(event):
		pass


class NodeInputHandler:
	extends Node2D

	func _input(event):
		print(event)



func add_actions():
	InputMap.add_action("foo")
	var key  = InputEventKey.new()
	key.set_scancode(KEY_F)
	InputMap.action_add_event("foo", key)


func make_input_event():
	var event = InputEventAction.new()
	event.set_action("foo")
	print(event.is_action("foo"))



func kick_off_actions():
	var sender = InputSender.new()
	get_root().add_child(sender)
	sender.actions = [["foo", true], ["foo", false], ["foo", true], ["foo", false], ["foo", true], ["foo", false]]

	var processor = InputProcessor.new()
	get_root().add_child(processor)

	yield(sender, "done")

func kick_off_keys():
	var sender = InputSender.new()
	get_root().add_child(sender)
	sender.keys = [[KEY_F, true], [KEY_F, false], [KEY_F, true], [KEY_F, false], [KEY_F, true], [KEY_F, false]]

	var processor = InputProcessor.new()
	get_root().add_child(processor)

	yield(sender, "done")


func _init():
	add_actions()
	print('starting')
	yield(kick_off_actions(), "completed")
	print("\n\n")
	yield(kick_off_keys(), "completed")
	quit()