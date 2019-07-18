tool
extends AudioStreamPlayer

export (Array,AudioStreamSample) var tracks_list #the state source
export (Array,Array,AudioStreamSample) var sub_tracks_list #the phase source

export var auto = false # 
export (String) var path_to_audio

var tracks 
var sub_tracks
var sub_audio_player

var current_state =0

func _ready():
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
	$AnimationPlayer.play("end_phase")
	yield($AnimationPlayer,"animation_finished")
	sub_audio_player.stop()
	$AnimationPlayer.play("next")
	yield($AnimationPlayer,"animation_finished")
	stop()
	$AnimationPlayer.play("play")

func chick_sound(state):
	# makes sure that the list is not empty,equals null and find the track
	if state != null or state != "":
			var i = 0
			while i<=tracks.size()-1:
				if state in tracks[i].resource_path and tracks[i] != null :
					stream = tracks[i]
					play()
					current_state = i
				i+=1



func _play_state(state): 
	if !playing :
		chick_sound(state)
	else:
		$AnimationPlayer.play("next")
		yield($AnimationPlayer,"animation_finished")
		chick_sound(state)
		$AnimationPlayer.play("play")
	
func _change_phase(phase = null):
	if playing:
		if sub_audio_player.playing:
			$AnimationPlayer.play("end_phase")
			var temp_sub = sub_tracks[current_state]
			sub_audio_player.stream = temp_sub[phase]
			sub_audio_player.stream.loop_begin =  get_playback_position()
			sub_audio_player.play()
			yield($AnimationPlayer,"animation_finished")
			$AnimationPlayer.play("start_phase")
		else:
			var temp_sub = sub_tracks[current_state]
			sub_audio_player.stream = temp_sub[phase]
			sub_audio_player.stream.loop_begin =  get_playback_position()
			sub_audio_player.play()
			pass
	else:
		return

#to make sure that this node has all the info you need
func _get_configuration_warning() ->String:
	var warnings = ""
	if not tracks:
		warnings="your audio list size is 0 change it"
		return warnings
	for i in tracks:
		if not i:
			warnings="add an audio track to use this node"
	return warnings

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
		while (file_name != ""):
			paths.append(load(path+"/"+file_name))
			count += 1
			file_name = dir.get_next()
			if first == file_name:
				return 
	else:
		print("An error occurred when trying to access the path.")
	paths.erase(paths[paths.size()-1])
	paths.erase(paths[paths.size()-1])
	return paths