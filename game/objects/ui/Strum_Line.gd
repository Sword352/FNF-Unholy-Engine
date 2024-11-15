class_name Strum_Line; extends Node2D;
# DO NOT ADD AS AN OBJECT TO SCENE, NEEDS TO BE INSTANTIATED

var SPLASH = preload('res://game/objects/note/note_splash.tscn')
var SPARK = preload('res://game/objects/note/holdnote_splash.tscn')

var INIT_POS = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
@export var is_cpu:bool = true:
	set(cpu): 
		is_cpu = cpu
		for i in get_strums(): i.is_player = !cpu
	
@export var spacing:float = 110.0:
	set(new_space):
		spacing = new_space
		for i in get_strums():
			i.position.x = spacing * i.dir
			
var singer:Character = null
var notes:Array[Note] = []

func _ready():
	for i in 4: # i can NOT be bothered to position these mfs manually
		var cur_strum:Strum = get_strums()[i]
		cur_strum.dir = (i % 4)
		if Prefs.scroll_type == 'down':
			cur_strum.scroll = -90
		#cur_strum.downscroll = Prefs.scroll_type == 'down'
		cur_strum.is_player = !is_cpu
		cur_strum.position.x = spacing * (i % 4)
		INIT_POS[i] = cur_strum.position
	
func get_strums() -> Array[Strum]:
	return [$Left, $Down, $Up, $Right]
	
func set_all_skins(skin:String = ''):
	for i in get_strums():
		i.load_skin(skin)
	
func note_hit(note:Note) -> void:
	strum_anim(note.dir, !is_cpu, !note.is_sustain)
	
	if singer != null:
		if !note.no_anim:
			if note.type == 'Hey':
				singer.play_anim('hey', true)
				singer.anim_timer = 0.6
			else:
				singer.sing(note.dir, note.alt, !note.is_sustain)
				#if note.is_sustain:
				#	singer.sing_timer = (note.length / Conductor.step_crochet) * 1.5
				#	print(singer.sing_timer)
			
	var can_splash = note.rating == 'sick' or note.rating == 'epic'
	if Prefs.note_splashes == 'all' or \
	  (Prefs.note_splashes == 'epics' and note.rating == 'epic') or \
	  (Prefs.note_splashes == 'both' and can_splash):
		spawn_splash(get_strums()[note.dir])

func note_miss(note:Note) -> void:
	if singer != null:
		singer.sing(note.dir, 'miss')
		if note.length > 0:
			singer.anim_timer = note.length / Conductor.step_crochet * 0.16

var total_splash:Array[AnimatedSprite2D] = []
func spawn_splash(strum:Strum) -> void:
	if total_splash.size() > 20:
		while total_splash.size() > 20:
			total_splash[0].visible = false
			total_splash[0].animation_finished.emit()
		
	var new_splash:AnimatedSprite2D = SPLASH.instantiate()
	new_splash.strum = strum
	#new_splash.speed_scale = 1.0 / (Conductor.step_crochet / 100.0)
	new_splash.on_anim_finish = func():
		#new_splash.on_anim_finish = func():
		total_splash.remove_at(total_splash.find(new_splash))
		remove_child(new_splash)
		new_splash.queue_free()
		#new_splash.animation_finished.connect(new_splash.on_anim_finish)
		#new_splash.play_backwards(new_splash.animation)
	
		
	add_child(new_splash)
	move_child(new_splash, 4)
	total_splash.append(new_splash)
	
func spawn_hold_splash(strum:Strum) -> void:
	pass
	
func add_strum() -> void:
	pass

func strum_anim(dir:int = 0, player:bool = false, force:bool = true) -> void:
	var strum:Strum = get_strums()[dir]
	
	if force or strum.anim_timer <= 0:
		strum.play_anim('confirm', true)
		strum.anim_timer = Conductor.step_crochet / 1000.0
	
	if !player:
		strum.reset_timer = min(Conductor.step_crochet * 1.25 / 1000.0, 0.15)
