extends Node2D

signal focus_change(is_focused) # when you click on/off the game window

var scene = null:
	get: return get_tree().current_scene
	
var screen = [
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
]

# make it so the global player runs always UNLESS you dont have focus
# fix pause screen because it sets the paused of the tree as well
func _ready():
	focus_change.connect(focus_changed)
	print(scene.name)

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		focus_change.emit(true)
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		focus_change.emit(false)

var was_paused:bool = false
func focus_changed(is_focused:bool):
	print('as')
	if is_focused:
		GlobalMusic.process_mode = Node.PROCESS_MODE_INHERIT
		if was_paused:
			get_tree().paused = false
			was_paused = false
	else:
		GlobalMusic.process_mode = Node.PROCESS_MODE_DISABLED
		if !get_tree().paused:
			get_tree().paused = true
			was_paused = true
	# focus in: if was_paused then get_tree().paused = false, was_paused = false
	# focus out: if !get_tree().paused then get_tree().paused = true, was_paused = true

func center_obj(obj = null, axis:String = 'xy'):
	if obj == null: return
	#var obj_size = obj.texture.size()
	if obj is Sprite2D:
		pass

	match axis:
		'x': obj.position.x = (screen[0] / 2) #- (obj_size.x / 2)
		'y': obj.position.y = (screen[1] / 2) #- (obj_size.y / 2)
		_: obj.position = Vector2(screen[0] / 2, screen[1] / 2)

func reset_scene(_skip_trans:bool = false):
	get_tree().reload_current_scene()

func switch_scene(new_scene, _skip_trans:bool = false):
	if new_scene is String:
		var path = 'res://game/scenes/%s.tscn'
		get_tree().change_scene_to_file(path % new_scene)
	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

func call_func(to_call:String, args:Array[Variant] = [], call_tree:bool = false): # call function on nodes or something
	if to_call.length() < 1: return
	
	if call_tree:
		for node in get_tree().get_nodes_in_group(scene.name):
			print(node)
			if node.has_method(to_call):
				node.callv(to_call, args)
	else:
		if scene.has_method(to_call):
			scene.callv(to_call, args)
	
	
	#else:
	#	callv(to_call, args)

func round_d(num, digit): # bowomp
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func rand_bool(chance:float = 50):
	return true if (randi() % 100) < chance else false
