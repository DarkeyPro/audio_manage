tool
extends AudioStreamPlayer


export (Array,AudioStreamSample) var tracks

func _play(id):
	stream = tracks[id]
	play()
	pass

func chick_sound(st):
	if st != null or st != "":
			var i = 0
			while i<=tracks.size()-1:
				if playing and st != tracks[i].resource_path:
					if st in tracks[i].resource_path and tracks[i] != null :
						_play(i)
				i+=1
func _play_state(st):
	if !playing :
		chick_sound(st)
	else:
		$AnimationPlayer.play("next")
		yield($AnimationPlayer,"animation_finished")
		chick_sound(st)
		$AnimationPlayer.play("play")
	
func _get_configuration_warning() ->String:
	var warnings = ""
	if not tracks:
		warnings="your audio list size is 0 change it"
		return warnings
	for i in tracks:
		if not i:
			warnings="add an audio track to use this node"
	return warnings