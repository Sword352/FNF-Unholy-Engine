extends Node2D

var scene = null:
	get: return get_tree().current_scene
var screen = [
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
]
var fps_txt:Label = Label.new()

func _ready():
	print(scene.name)
	add_child(fps_txt)
	fps_txt.position = Vector2(10, 10)

func _process(_delta):
	var mem:String = String.humanize_size(OS.get_static_memory_usage()).replace('i', '')
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage()).replace('i', '')
	fps_txt.text = 'FPS: ' + str(Engine.get_frames_per_second())+'\n' + 'Mem: ' + mem + ' | ' + mem_peak

func center_obj(obj = null, axis:String = 'xy'):
	if obj == null: return
	#var obj_size = obj.texture.size()
	if obj is Sprite2D:
		pass


	match axis:
		'x': obj.position.x = (screen[0] / 2) #- (obj_size.x / 2)
		'y': obj.position.y = (screen[1] / 2) #- (obj_size.y / 2)
		_: obj.position = Vector2(screen[0] / 2, screen[1] / 2)

func switch_scene(new_scene):
	if new_scene is String:
		get_tree().change_scene_to_file('res://game/scenes/'+ new_scene +'.tscn')
	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

func call_func(to_call:String, args:Array = [], on_scene:bool = true): # call function on nodes or something
	if to_call.length() < 1: return
	if on_scene:
		scene.callv(to_call, args)
	else:
		callv(to_call, args)
