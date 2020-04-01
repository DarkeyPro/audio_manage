
extends Node

export (Array,AudioStreamSample) var tracks_list #the state source
export (Array,Array,AudioStreamSample) var sub_tracks_list #the phase source

export var auto = false # 
export (String) var path_to_audio

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

func tweening(object:Node,property:String,to,duration=0.0,completed =false,trans_type=Tween.TRANS_LINEAR,ease_type =Tween.EASE_IN_OUT,delay =0.0):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(object,property,object.get(property),to,duration,trans_type,ease_type,delay)
	tween.start()
	if completed:
		yield(tween,"tween_completed")
	tween.queue_free()

func _stop():
	# end phase
	tweening(sub_audio_player,"volume_db",-80,1.0,true)
	sub_audio_player.stop()
	#start next
	tweening(main_audio_player,"volume_db",-80,1.0,true)
	main_audio_player.stop()
	#play
	tweening(main_audio_player,"volume_db",0,1.0)

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
		tweening(main_audio_player,"volume_db",-80,1.0,true)
		chick_sound(state)
		tweening(main_audio_player,"volume_db",0,1.0)
	
func _change_phase(phase = null):
	if main_audio_player.playing:
		if sub_audio_player.playing:
			tweening(sub_audio_player,"volume_db",-80,1.0)
			var temp_sub = sub_tracks[current_state]
			sub_audio_player.stream = temp_sub[phase]
			sub_audio_player.stream.loop_begin =  main_audio_player.get_playback_position()
			print("l")
			sub_audio_player.play()
			tweening(sub_audio_player,"volume_db",0,1.0,true)
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
	return file_find(path_to_audio+"/"+"main")


func set_phase_tracks():
	return file_find(path_to_audio+"/"+"sub")

func file_find(path):
	var paths = []
	var count =1
	var dir = Directory.new()
	if dir.open(path)  == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var first = file_name
		while (file_name != "" and file_name != "." and file_name != ".."):
			paths.append(load(path+"/"+file_name))
			count += 1
			file_name = dir.get_next()
			if first == file_name:
				return 
	else:
		print("An error occurred when trying to access the path.")
	return paths
