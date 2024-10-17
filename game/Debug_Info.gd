extends CanvasLayer

var time_existed:float = 0.0
var vol_visible:bool = false
var vol_tween:Tween
var max_tween:Tween
var pressed_key:bool = false
var volume:float = 1.0:
	set(vol):
		vol = clamp(vol, 0, 1)
		vol_visible = true
		if pressed_key:
			pressed_key = false
			if vol > volume: 
				Audio.play_sound('vol/up')
			elif vol < volume:
				Audio.play_sound('vol/down')
			else:
				$Volume/BarsBG/VolBar10.modulate = Color.RED
				if max_tween: max_tween.kill()
				max_tween = create_tween()
				max_tween.tween_property($Volume/BarsBG/VolBar10, 'modulate', Color.WHITE, 0.3)
				Audio.play_sound('vol/max')
			$Volume.position.y = 0
			time_existed = 0
		AudioServer.set_bus_volume_db(0, linear_to_db(vol))
		volume = vol
		Prefs.saved_volume = vol
		Prefs.save_prefs()

func _ready():
	volume = Prefs.saved_volume

	Game.center_obj($Volume, 'x')
	$Volume.position.x -= ($Volume.size.x * $Volume.scale.x) / 2.0
	$Other.visible = OS.is_debug_build()

var debug_data:bool = false
func _process(delta):
	if vol_visible:
		if vol_tween: vol_tween.kill()

		$Volume/Percent.text = str(floor(volume * 100)) +'%'
		for i in 10:
			var bar = get_node('Volume/BarsBG/VolBar'+ str(i + 1))
			bar.scale.y = clamp(lerp(bar.scale.y, 0.0 if floor(volume * 10) <= i else 1.0, delta * 15), 0, 1)
			
		time_existed += delta
		vol_visible = time_existed < 1
		if time_existed >= 1.0:
			vol_tween = create_tween()
			vol_tween.tween_property($Volume, 'position:y', -100, 0.35)
	
	if Engine: pass
	var mem:String = String.humanize_size(OS.get_static_memory_usage())
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage())
	$FPS.text = 'FPS: '+ str(Engine.get_frames_per_second())
	if OS.is_debug_build():
		$Other.text = 'Mem: '+ mem +' / '+ mem_peak +'\nPress (Debug 2) for more info'
		if Input.is_action_just_pressed('debug_2'):
			debug_data = !debug_data
		if debug_data:
			$Other.text += '\nNodes: '+ str(get_tree().get_node_count())
			if get_tree().current_scene != null:
				$Other.text += '\nScene: '+ get_tree().current_scene.name
			$Other.text += '\nAll Objs: '+ str(Performance.get_monitor(Performance.OBJECT_COUNT))
			$Other.text += '\nFrm Delay: '+ str(Performance.get_monitor(Performance.TIME_PROCESS))
			$Other.text += '\nTotal Draw Obj/Calls: '+ str(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)) +' / '+ str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))

func _unhandled_key_input(_event):
	pressed_key = true
	if Input.is_action_just_pressed('vol_up'): volume = min(volume + 0.1, 1)
	if Input.is_action_just_pressed('vol_down'): volume = max(volume - 0.1, 0)
	
	if Input.is_key_pressed(KEY_L): Conductor.playback_rate *= 2.0
	if Input.is_key_pressed(KEY_J): Conductor.playback_rate /= 2.0
	if Input.is_key_pressed(KEY_I): Conductor.playback_rate = 1
