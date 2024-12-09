extends Node2D

var character:Character
var char_json = {}
var anim_list:Array[Label] = []
var offsets:Dictionary = {}

var icon_list:Array = []

var char_list:Array = []
var cur_char:String = ''
var cur_anim:String = ''
var selected_id:int = 0:
	set(new_id):
		if new_id < anim_list.size():
			anim_list[selected_id].modulate = Color.WHITE  # if this is greater than the new char's anim list, crash
			anim_list[new_id].modulate = Color.YELLOW
			cur_anim = anim_list[new_id].text.split('[')[0].strip_edges()
		selected_id = new_id
		
		character.play(cur_anim)
		var got = offsets[cur_anim] if offsets.has(cur_anim) else [0, 0]
		character.offset = Vector2(got[0], got[1])

func _ready():
	Game.set_mouse_visibility()
	Audio.play_music('artisticExpression')

	#DebugInfo.get_node('FPS').visible = false
	#if OS.is_debug_build():
	#	DebugInfo.get_node('Other').visible = false
		
	character = Character.new(get_viewport_rect().size / 2.0, 'bf', true)
	character.debug = true
	change_char('bf')
	#character.position -= Vector2(character.width, character.height)
	#character.load_char('bf')
	add_child(character)
	move_child(character, 2)
	
	$UILayer/CharacterSelect.get_popup().connect("id_pressed", on_char_change)
	$UILayer/IconSelect.get_popup().connect("id_pressed", on_icon_change)
	
	$UILayer/IconSelect/Icon.default_scale = 0.7
	$UILayer/IconSelect/Icon.scale = Vector2(0.7, 0.7)

	char_json = JsonHandler.get_character('bf')
	$Cam.position = get_viewport_rect().size / 2.0
	
	var grab = FileAccess.open('res://assets/data/order.txt', FileAccess.READ).get_as_text().split(',')
	grab.append_array(DirAccess.get_files_at('res://assets/data/characters'))
	for i in grab:
		i = i.replace('.json', '')
		if !char_list.has(i):
			char_list.append(i)
			$UILayer/CharacterSelect.get_popup().add_item(i)
	
	for i in DirAccess.get_files_at('res://assets/images/icons'):
		if !i.ends_with('.png'): continue
		i = i.replace('.png', '')
		if !icon_list.has(i):
			icon_list.append(i)
			$UILayer/IconSelect.get_popup().add_item(i)

func _process(delta):
	$Backdrop.scale = Vector2.ONE / $Cam.zoom
	$Backdrop.position = $Cam.position

	character.speed_scale = $UILayer/AnimSpeed.value
	var sc = $UILayer/ScaleBox.value
	character.scale = Vector2(sc, sc)

	$UILayer/CurData/Anim.text = cur_anim
	$UILayer/CurData/Offset.text = str(offsets[cur_anim])
	$UILayer/CurData/Frame.text = 'Frame:\n'+ str(character.frame) +' / '+ str(character.sprite_frames.get_frame_count(character.animation) - 1)
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('back'): Game.switch_scene('menus/Main_Menu')
	
	var ctrl = Input.is_key_pressed(KEY_CTRL)
	var shift = Input.is_key_pressed(KEY_SHIFT)
	## CAMERA ZOOM
	if Input.is_key_pressed(KEY_U): $Cam.zoom -= Vector2(0.01, 0.01)
	if Input.is_key_pressed(KEY_O): $Cam.zoom += Vector2(0.01, 0.01)
	## CAMERA MOVE
	if Input.is_key_pressed(KEY_J): $Cam.position.x -= 5
	if Input.is_key_pressed(KEY_L): $Cam.position.x += 5
	if Input.is_key_pressed(KEY_I): $Cam.position.y -= 5
	if Input.is_key_pressed(KEY_K): $Cam.position.y += 5
	## CHARACTER OFFSETTING
	var replay_anim = false
	if Input.is_key_pressed(KEY_LEFT) : offsets[cur_anim][0] -= 1; replay_anim = true
	if Input.is_key_pressed(KEY_RIGHT): offsets[cur_anim][0] += 1; replay_anim = true
	if Input.is_key_pressed(KEY_UP)   : offsets[cur_anim][1] -= 1; replay_anim = true
	if Input.is_key_pressed(KEY_DOWN) : offsets[cur_anim][1] += 1; replay_anim = true
	if Input.is_key_pressed(KEY_SPACE): replay_anim = true
		
	if replay_anim:
		character.frame = 0
		character.offset = Vector2(offsets[cur_anim][0], offsets[cur_anim][1])
		character.play()
		
	if Input.is_key_pressed(KEY_W): selected_id = wrapi(selected_id - 1, 0, anim_list.size())
	if Input.is_key_pressed(KEY_S): selected_id = wrapi(selected_id + 1, 0, anim_list.size())
	if Input.is_key_pressed(KEY_Q):
		character.pause() 
		character.frame -= 1
	if Input.is_key_pressed(KEY_E):
		character.pause()
		character.frame += 1
	
func change_icon(new_icon:String = 'bf'):
	var ic:Icon = $UILayer/IconSelect/Icon
	var hi:ColorRect = $UILayer/IconSelect/Highlight
	char_json.healthicon = new_icon
	ic.position = Vector2(100, 100)
	ic.change_icon(new_icon.strip_edges())
	ic.hframes = 1
	
	hi.custom_minimum_size = Vector2(ic.texture.get_width() * 0.7, ic.texture.get_height() * 0.7)
	hi.position = ic.position
	hi.position.x -= (ic.texture.get_width() * 0.7) / 2.0
	hi.position.y /= 2.0
	if ic.has_lose:
		hi.custom_minimum_size.x /= 2.0
		hi.size /= 2.0
	
func change_char(new_char:String = 'bf'):
	char_json = JsonHandler.get_character(new_char)
	if char_json == null: return
	cur_char = new_char
	if char_json.has('type') and char_json.type == 'psych':
		for i in char_json.animations:
			i.offsets = [-i.offsets[0], -i.offsets[1]] # lol
			if i.offsets[0] == -0: i.offsets[0] = 0
			if i.offsets[1] == -0: i.offsets[1] = 0
			
	$UILayer/CharacterSelect/CurCharLabel.text = cur_char
	reload_list(char_json.animations)
	character.position = get_viewport_rect().size / 2.0 - Vector2(300, 450)
	character.is_player = char_json.flip_x
	$UILayer/Player.button_pressed = char_json.flip_x
	$UILayer/ScaleBox.value = char_json.scale
	character.load_char(new_char)
	#character.position -= Vector2(character.width, character.height)
	$Point.position = character.get_cam_pos()
	
	change_icon(char_json.healthicon)
	character.play(cur_anim) # play first loaded anim to fix offsets
	character.offset = Vector2(offsets[cur_anim][0], offsets[cur_anim][1])
	
func reload_list(anims:Array) -> void:
	selected_id = 0
	Game.remove_all([anim_list], $UILayer/Animations)
	offsets.clear()
	
	for i in anims.size():
		var anim = anims[i]
		offsets[anim.anim] = anim.offsets
		
		var lab = make_label()
		lab.position.x -= 20
		lab.position.y = 50 + (20 * i)
		lab.text = anim.anim +' '+ str(anim.offsets)
		
		$UILayer/Animations.add_child(lab)
		anim_list.append(lab)
	
	if anim_list.size() == 0:
		var lab = make_label()
		lab.text = 'NO ANIMATIONS'
		lab.modulate = Color.RED
		lab.position.x -= 20
		lab.position.y = 50
		$UILayer/Animations.add_child(lab)
		anim_list.append(lab)
	else:
		selected_id = 0
		anim_list[0].modulate = Color.YELLOW

func on_char_change(id:int) -> void:
	var got_char = char_list[id]
	if cur_char != got_char:
		change_char(got_char)

func on_icon_change(id:int) -> void:
	var new_icon = icon_list[id]
	change_icon(new_icon)

func make_label() -> Label:
	var lab = Label.new()
	lab.add_theme_font_override('font', load('res://assets/fonts/vcr.ttf'))
	lab.add_theme_font_size_override('font_size', 20)
	lab.add_theme_constant_override('outline_size', 4)
	return lab

var anim_format = {
	'name': '',
	'prefix': '',
	'offsets': [0, 0],
	'framerate': 24,
	'frames': [], #idk
	'loop': false
}
var save_format = {
	'animations': [],
	'path': '',
	'icon': 'bf',
	'flip_x': false,
	'antialiasing': true,
	'cam_offset': [0, 0],
	'pos_offset': [0, 0],
	'scale': 1
}

func save_pressed() -> void:
	var new_json:Dictionary = save_format.duplicate()
	for i in offsets.keys():
		var new_anim = anim_format.duplicate()
		new_anim.name = i
		new_anim.prefix = ''
		new_anim.offsets = offsets[i]
		new_json.animations.append(new_anim)
		
	new_json.icon = char_json.healthicon
	#new_json.pos_offset =
	#if FileAccess.file_exists('res://assets/data/characters/TESTJSON.json'):
	#	DirAccess.remove_absolute('res://assets/data/characters/TESTJSON.json')
	#odd
	var file:FileAccess = FileAccess.open("res://assets/data/characters/TESTJSON.json", FileAccess.WRITE_READ)
	file.resize(0) # clear the file, if it has stuff in it
	file.store_string(JSON.stringify(new_json, '\t', false))
	file.close()
