class_name StageBase extends Node2D

# things all stages will have
var default_zoom:float = 0.8
var cam_speed:float = 4.0

var SONG:
	get: return Game.scene.SONG

var cur_beat:int:
	get: return Conductor.cur_beat
var cur_step:int:
	get: return Conductor.cur_step
var cur_section:int:
	get: return Conductor.cur_section

var boyfriend:Character:
	get: return Game.scene.boyfriend
var dad:Character:
	get: return Game.scene.dad
var gf:Character:
	get: return Game.scene.gf

# initial positions the characters will take
# set these on _ready()
var bf_pos:Vector2 = Vector2(770, 100)
var dad_pos:Vector2 = Vector2(100, 100)
var gf_pos:Vector2 = Vector2(550, 100)

# added onto the character's camera position
var bf_cam_offset:Vector2 = Vector2(0, 0)
var dad_cam_offset:Vector2 = Vector2(0, 0)
var gf_cam_offset:Vector2 = Vector2(0, 0)

# song functions for signals
func countdown_start() -> void: pass
func countdown_tick(tick:int) -> void: pass
func start_song() -> void: pass
func song_end() -> void: pass

func beat_hit(beat:int) -> void: pass
func step_hit(step:int) -> void: pass
func section_hit(section:int) -> void: pass

# bf died
func game_over_start() -> void: pass
func game_over_idle() -> void: pass
func game_over_confirm(is_retry:bool) -> void: pass
