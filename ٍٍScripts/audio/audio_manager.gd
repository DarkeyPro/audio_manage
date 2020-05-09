
extends Node

export (Array,AudioStreamSample) var tracks_list #the state source
export (Array,Array,AudioStreamSample) var sub_tracks_list #the phase source

export var auto = false # 
export (String) var path_to_audio="res://Assets/Audios/Tracks/"

var tracks 
var sub_tracks
var main_audio_player
var sub_audio_player

var current_state =0

func _ready():
	main_audio_player =get_node("main")
	sub_audio_player = get_node("Sub")
	if !auto:
		tracks = tracks_list 
		sub_tracks = sub_tracks_list
	else:
		tracks = set_state_tracks()
		sub_tracks = set_phase_tracks() 

func _play(id_state,id_phase = null,phase_only = false ):
	# takes the track and play it
	if !phase_only:
		_play_state(id_state)
		_change_phase(id_phase)
	elif id_phase == null and !phase_only:
		_play_state(id_state)
	else: 
		_change_phase(id_phase)



func _stop():
	# end phase
	CustomFunctions.tweening(sub_audio_player,"volume_db",-80,1.0,true)
	sub_audio_player.stop()
	#start next
	CustomFunctions.tweening(main_audio_player,"volume_db",-80,1.0,true)
	main_audio_player.stop()
	#play
	CustomFunctions.tweening(main_audio_player,"volume_db",0,1.0)

func chick_sound(state):
	# makes sure that the list is not empty,equals null and find the track
	if state != null or state != "":
			var i = 0
			while i<=tracks.size()-1:
				if state in tracks[i].resource_path and tracks[i] != null :
					main_audio_player.stream = tracks[i]
					main_audio_player.play()
					current_state = i
				i+=1

func _play_state(state): 
	if !main_audio_player.playing :
		chick_sound(state)
	else:
		CustomFunctions.tweening(main_audio_player,"volume_db",-80,1.0,true)
		chick_sound(state)
		CustomFunctions.tweening(main_audio_player,"volume_db",0,1.0)
	
func _change_phase(phase = null):
	if main_audio_player.playing:
		if sub_audio_player.playing:
			CustomFunctions.tweening(sub_audio_player,"volume_db",-80,1.0)
			var temp_sub = sub_tracks[current_state]
			sub_audio_player.stream = temp_sub[phase]
			sub_audio_player.stream.loop_begin =  main_audio_player.get_playback_position()
			print("l")
			sub_audio_player.play()
			CustomFunctions.tweening(sub_audio_player,"volume_db",0,1.0,true)
		else:
			var temp_sub = sub_tracks[current_state]
			print("s")
			sub_audio_player.stream = temp_sub[phase]
			sub_audio_player.stream.loop_begin =  main_audio_player.get_playback_position()
			sub_audio_player.play()
			pass
	else:
		return



func set_state_tracks():
	return CustomFunctions.file_find(path_to_audio+"/"+"main")


func set_phase_tracks():
	return CustomFunctions.file_find(path_to_audio+"/"+"sub")

