extends Node
#LOAD AUDIO
const AUDIO_TICK_LEFT = preload("res://Audio/tick_left.ogg")
const AUDIO_TICK_RIGHT = preload("res://Audio/tick_right.ogg")
const AUDIO_BEEP = preload("res://Audio/beep.wav")
const AUDIO_1 = preload("res://Audio/rh_one.wav")
const AUDIO_2 = preload("res://Audio/rh_two.wav")
const AUDIO_3 = preload("res://Audio/rh_three.wav")
const AUDIO_4 = preload("res://Audio/rh_four.wav")

#GLOBAL AND GAMEPLAY STATES
enum {GAME_IN,GAME_OUT}
enum {GLOBAL_COUNT,GLOBAL_PLAY,GLOBAL_OVER}

#AUDIO PLAYBACK SEQUENCES
var audio_step = [AUDIO_TICK_LEFT,AUDIO_BEEP,AUDIO_TICK_RIGHT,AUDIO_BEEP]
var audio_count= [AUDIO_1,AUDIO_BEEP,"",AUDIO_BEEP,AUDIO_2,AUDIO_BEEP,"",AUDIO_BEEP,AUDIO_1,AUDIO_BEEP,AUDIO_2,AUDIO_BEEP,AUDIO_3,AUDIO_BEEP,AUDIO_4,AUDIO_BEEP]

#BPM
var Bpm=75
var SpeedUp = 7.5

var beat_timer = 0.0
var beats = 0
var dt_average = 0

var tick_phase = 0
var step_left = true

var InState = GAME_OUT
var GlobalState = GLOBAL_COUNT
var Score = 0

func _ready():
	$Score.set_text("0")
	set_process_input(true)

func _process(delta):
	match GlobalState:
		GLOBAL_COUNT:
			event_count(delta)
		GLOBAL_PLAY:
			event_play(delta)

func add_score():
	Score += 1
	$Score.set_text(str(Score))

func _epicfail(index):
	#get_tree().quit()
	print("fail",beat_timer)
	GlobalState = GLOBAL_OVER
	$MrUpbeat/move.play((["trip_left","trip_right"])[index])

func play_audio(Audio):
	if typeof(Audio) != TYPE_STRING:
		if Audio == AUDIO_1 or Audio == AUDIO_2 or Audio == AUDIO_3 or Audio == AUDIO_4:
			$Announcer.set_stream(Audio)
			$Announcer.play()
		else:
			$Audio.set_stream(Audio)
			$Audio.play()
			if Audio == AUDIO_BEEP:
				$MrUpbeat/beep.play("beep")

func spb():
	return (60.0/float(Bpm*2))

func update_timer(delta):
	#set average delta time
	dt_average+=delta
	dt_average/=2
	#update beat_timer
	beat_timer += delta
	
	var a = abs(beat_timer-spb())
	var bo = beat_timer+dt_average-spb()
	var b = abs(bo)
	
	#if close to beat
	if (a<=b or b<=a) and (bo>=0):
		beat_timer -= spb()
		beats += spb()
		return true
	else:
		return false

func event_count(delta):
	if update_timer(delta):
		play_audio(audio_count[tick_phase])
		tick_phase = (tick_phase+1)%17
		if tick_phase == 16:
			beat_timer = 0
			beats = 0
			tick_phase = 0
			GlobalState = GLOBAL_PLAY
	
	$Metronome.set_rotation_degrees(150)

func event_play(delta):
	if update_timer(delta):
		play_audio(audio_step[tick_phase])
		tick_phase = (tick_phase+1)%4

	var mid = fmod(beat_timer,spb())
	#mid /= spb()
	var Rotation = sin(((beats+beat_timer)/spb()*0.5)*PI)
	#print(tick_phase)
	#print(mid)
	#print(tick_phase)
	match InState:
		GAME_OUT:
			if mid > spb()-spb()/8:
				if tick_phase == 1 and !step_left: _epicfail(1)
				if tick_phase == 3 and step_left: _epicfail(0)
				if tick_phase == 1 or tick_phase == 3: InState = GAME_IN
			pass
		GAME_IN:
			if mid > spb()/8:
				if tick_phase == 2 and step_left: _epicfail(0)
				if tick_phase == 0 and !step_left: _epicfail(1)
				if tick_phase == 2 or tick_phase == 0: InState = GAME_OUT
			pass
	if beats > 0: $Metronome.set_rotation_degrees(90+Rotation*60)
	if (beats+beat_timer)/spb() > 64:
		Bpm += floor(SpeedUp)
		SpeedUp += .5
		beat_timer = 0
		beats = 0
		tick_phase = 0
		GlobalState = GLOBAL_COUNT
		$Ding.play()
	#if ticks_so_far > 

func _input(event):
	if Input.is_action_just_pressed("ui_accept") and $Timer.is_stopped():
		if InState == GAME_IN: add_score()
		$Audio_Step.play()
		step_left = not step_left
		$MrUpbeat/move.play((["step_right","step_left"])[int(step_left)])
		$Timer.set_wait_time((60.0/float(Bpm))/5) 
		$Timer.start()