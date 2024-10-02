extends Node2D

var descriptions
var catagories = ['Gameplay', 'Visuals', 'Controls']

# options that will be in each catagory
# pref name, type, if type is int/float [min_num, max_num], if type is array ['list', 'of', 'choices']
var gameplay = [ 
	['auto_play',        'bool'],
	['ghost_tapping',    'bool'],
	['downscroll',       'bool'], 
	['middlescroll',     'bool'], 
	['hitsound_volume',   'int', [0, 100]],
	['offset',            'int', [0, 300]], 
	['epic_window',     'float', [15, 22.5]], 
	['sick_window',     'float', [15, 45]], 
	['good_window',     'float', [15, 90]], 
	['bad_window' ,     'float', [15, 135]]
]
var visuals = [
	['fps',             'int', [0, 240]],
	['vsync',         'array', ['disabled', 'enabled', 'adaptive', 'mailbox']],
	['allow_rpc',      'bool'],
	['basic_play',     'bool'],
	['note_splashes', 'array', ['epics', 'both', 'all', 'none']],
	['splash_sprite', 'array', ['base', 'haxe', 'forever']],
	['behind_strums',  'bool'],
	['rating_cam',    'array', ['game', 'hud', 'none']],
	['auto_pause',     'bool'],
	['chart_grid',     'bool'],
	['daniel',         'bool']
]
#var controls = []

var cur_option:int = 0
var sub_option:int = 0
var in_sub:bool = false

var main_text:Array[Alphabet]
var pref_list:Array[Alphabet]
func _ready():
	Discord.change_presence('Maining some Menus', 'Checkin some options')
	
	var b = JSON.new()
	b.parse(FileAccess.open('res://assets/data/prefInfo.json', FileAccess.READ).get_as_text())
	descriptions = b.data
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new(item)
		text.position = Vector2(275 - (text.width / 2), 100 + (100 * i))
		add_child(text)
		main_text.append(text)
	update_scroll()

func _process(delta):
	if Input.is_action_just_pressed('menu_up'): update_scroll(-1)
	if Input.is_action_just_pressed('menu_down'): update_scroll(1)
	
	if in_sub:
		var da_pref = pref_list[sub_option]
		if ['array', 'int', 'float'].has(da_pref.type):
			var update = 1
			if da_pref.type == 'float' and Input.is_key_pressed(KEY_CTRL): update = 0.1
			if Input.is_action_just_pressed('menu_left'): da_pref.update_option(-update)
			if Input.is_action_just_pressed('menu_right'): da_pref.update_option(update)
		if da_pref.type == 'bool' and Input.is_action_just_pressed("accept"): 
			da_pref.update_option()
		if Input.is_action_just_pressed('back'): show_main()
	else:
		if Input.is_action_just_pressed('back'):
			Audio.play_sound('cancelMenu')
			Game.switch_scene('menus/main_menu')
		
		if Input.is_action_just_pressed("accept"):
			show_catagory(catagories[cur_option].to_lower())

func show_main() -> void:
	Audio.play_sound('cancelMenu')
	in_sub = false
	#cur_option = 0
	while pref_list.size() > 0:
		remove_child(pref_list[0])
		pref_list[0].queue_free()
		pref_list.remove_at(0)
	
	$TextBG/Info.text = 'Choose a Catagory'
	for i in main_text.size():
		main_text[i].modulate.a = (1.0 if i == cur_option else 0.6)
	
func show_catagory(catagory:String) -> void:
	Audio.play_sound('confirmMenu')
	in_sub = true
	sub_option = 0
	for i in main_text.size():
		main_text[i].modulate.a = 0.8 if i == cur_option else 0.1

	#main_text[cur_option].position = Vector2(100, 100)
	if catagory.to_lower() == 'controls':
		Game.switch_scene('menus/options/change_keybinds')
	else:
		var loops:int = 0
		for pref in get(catagory):
			var desc = descriptions[pref[0]] if descriptions.has(pref[0]) else 'Missing Description'
			var new_pref = Option.new(pref, desc)
			new_pref.is_menu = true
			new_pref.target_y = loops
			var twen = create_tween()\
			.tween_property(new_pref, 'lock:x', 550, 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			
			add_child(new_pref)
			pref_list.append(new_pref)
			loops += 1
		update_scroll()

func update_scroll(diff:int = 0) -> void:
	var array:Array = pref_list if in_sub else main_text
	var op:String = 'cur_option' if array == main_text else 'sub_option'

	if diff != 0: Audio.play_sound('scrollMenu')
	set(op, wrapi(get(op) + diff, 0, array.size()))

	for i in array.size():
		array[i].modulate.a = (1.0 if i == get(op) else 0.6)
		if in_sub: array[i].target_y = i - get(op)
	if in_sub: $TextBG/Info.text = pref_list[get(op)].description

class Option extends Alphabet:
	var option:String = ''
	var description:String = 'nothing'
	var type:String = 'bool' # the option's type: int, bool, array n shit
	var check:Checkbox
	
	var cur_op:int = 0
	var choices:Array = [] # if the option is an array, will hold all possible options
	
	var min_val:float = 0;  var max_val:float = 0
	var cur_val:float = 0
	
	func _init(option_array, info:String = 'nothin'):
		option = option_array[0]
		description = info
		type = option_array[1]
		text = option.capitalize() +' '+ (str(Prefs.get(option)) if type != 'bool' else '')
		lock.x = 1300
		
		if type == 'array':
			choices = option_array[2]
			cur_op = choices.find(str(Prefs.get(option)))
		elif type == 'int' or type == 'float':
			min_val = option_array[2][0]
			max_val = option_array[2][1]
			cur_val = Prefs.get(option)
		else:
			check = Checkbox.new()
			add_child(check)
			check.follow_spr = self
			check.checked = Prefs.get(option)
		
	# update the preference and the option text
	func update_option(diff:float = 0) -> void: # diff for arrays/nums
		match type:
			'array':
				cur_op = wrapi(cur_op + round(diff), 0, choices.size())
				Prefs.set(option, choices[cur_op].to_lower())
			'int', 'float':
				if Input.is_key_pressed(KEY_SHIFT): diff *= 10
				cur_val = clamp(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'bool': 
				var a_bool = Prefs.get(option)
				Prefs.set(option, !a_bool)
				check.checked = !a_bool
		if type != 'bool':
			text = option.capitalize() +' '+ str(Prefs.get(option))
		Prefs.save_prefs()
