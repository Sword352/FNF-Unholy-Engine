extends Node2D


var col = Color()
var colors:Array[Color] = [Color(0.2, 1, 1, 1), Color(0.21, 0.21, 0.8, 0.64)]

var finished_intro:bool = false
var added_text:Array = []

var flash = ColorRect.new()
var show_cow:bool = Game.rand_bool(5)
var blurb:Array = []
func _ready():
	Discord.change_presence('Title Screen', 'Welcome to the Funkin')
	
	add_child(flash)
	move_child(flash, 4)
	flash.color = Color.BLACK
	flash.position = Vector2(-15, -15)
	flash.size = Vector2(1300, 755)

	if !show_cow:
		blurb = get_funny().pick_random()
		if blurb.is_empty(): 
			blurb = ['there\'s nothing', 'to say']
			
	print(blurb)
	
	Game.center_obj($GodotLogo)
	$GodotLogo.position.y += 75
	Audio.volume = 0
	Conductor.bpm = 102
	Conductor.beat_hit.connect(beat_hit)
	Conductor.song_started = true
	#Conductor.inst = Audio.Player

var danced:bool = false
func beat_hit(beat) -> void:
	#Audio.play_sound('tick')
	danced = !danced
	$TitleGF.play('dance'+ ('Left' if danced else 'Right'))
	$Funkin.scale = Vector2(1.1, 1.1)
	
	if !finished_intro:
		match beat:
			1:
				Audio.play_music('freakyMenu') # restart song so it sync
				create_tween().tween_property(Audio, 'volume', 0.7, 4)
			2: make_funny(['Stupid ass engine by'], 40)
			4: add_funny('unholywanderer', 40)
			5: remove_funny()
			6: make_funny(['Made this hunk of shit'], -40)
			8: 
				add_funny('With Godot', -40)
				$GodotLogo.visible = true
			9: 
				remove_funny()
				$GodotLogo.visible = false
			10: 
				if show_cow:
					$cow.visible = true
					$cow.play('cow')
					$cow.frame = 0
					Audio.volume = 0
					Conductor.song_started = false
					await $cow.animation_finished
					Conductor.song_started = true
				else:
					make_funny([blurb[0]])
			12: 
				if !show_cow:
					add_funny(blurb[1] if blurb.size() == 2 else '')
			13: remove_funny()
			14: add_funny('friday')
			15: add_funny('night')
			16: add_funny('funkin')
			17: finish_intro()

var accepted:bool = false
var funk_sin:float = 0.0
var time_lerped:float = 0.0
func _process(delta):
	funk_sin += delta
	$Funkin.rotation = sin(funk_sin * 2) / 8
	$Funkin.scale.x = lerpf($Funkin.scale.x, 1, delta * 7)
	$Funkin.scale.y = $Funkin.scale.x
	
	if Conductor.song_started:
		Conductor.song_pos += (1000 * delta)
	#Conductor.song_pos = Audio.pos #im lazy dont judge me
	
	if !accepted:
		time_lerped += delta
		if time_lerped >= 1.5: 
			time_lerped = 0
			colors.reverse()
		$PressEnter.modulate = colors[0].lerp(colors[1], time_lerped / 1.5)
		
		if Input.is_action_just_pressed("accept"):
			accepted = true

			if !finished_intro:
				accepted = false
				finish_intro()
			else:
				Audio.play_sound('confirmMenu')
				$PressEnter.modulate = Color.WHITE
				$PressEnter.play('ENTER PRESSED')
			
				if flash.modulate.a >= 0:
					flash.modulate.a = 1
					create_tween().tween_property(flash, 'modulate:a', 0, 1)
		
				await get_tree().create_timer(1).timeout
				Game.switch_scene('menus/main_menu')
				Conductor.reset()

func finish_intro() -> void:
	finished_intro = true
	remove_funny()
	
	if show_cow: 
		$cow.visible = false
	
	if Audio.Player.stream == null: #or Audio.volume < 0.7:
		Audio.play_music('freakyMenu', true, 0.7)
	elif Audio.volume < 0.7:
		Audio.volume = 0.7
	#Audio.Player.seek(10) # skip it to the good part,,,
		
	flash.color = Color.WHITE
	create_tween().tween_property(flash, 'modulate:a', 0, 4)
	
func make_funny(text:Array, offset:int = 0) -> void:
	for i in text.size():
		var new_text = Alphabet.new(text[i])
		new_text.position.x = (Game.screen[0] / 2) - (new_text.width / 2)
		new_text.position.y += (i * 60) + 200 + offset
		add_child(new_text)
		added_text.append(new_text)
	
func add_funny(text:String, offset:int = 0) -> void:
	var new_text = Alphabet.new(text)
	new_text.position.x = (Game.screen[0] / 2) - (new_text.width / 2)
	new_text.position.y += (added_text.size() * 60) + 200 + offset
	add_child(new_text)
	added_text.append(new_text)
	
func remove_funny() -> void:
	Game.remove_all([added_text], self)
		
func get_funny() -> Array[Array]:
	var intro_txt:String = FileAccess.open('res://assets/data/introText.txt', FileAccess.READ).get_as_text()
	#print(intro_txt)

	var split_intro:Array[Array] = []
	if intro_txt != null and intro_txt.length() > 0:
		for txt in intro_txt.split('\n'):
			split_intro.append(Array(txt.strip_edges().split('--')))
	
	return split_intro

func on_music_finish():
	Conductor.reset_beats()
