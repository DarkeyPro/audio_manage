extends Node
class_name action_audio
export(Array,AudioStreamSample) var audio_list =[]
enum view{two_D=0,three_D=1}
export(view) var type

func _ready():
	for i in audio_list:
		var audio
		if type == view.two_D:
			audio=AudioStreamPlayer2D.new()
			pass
		if type ==view.three_D:
			audio= AudioStreamPlayer3D.new()
		var temp =i.resource_path.rsplit("/",true,1)[i.resource_path.rsplit("/",true,1).size()-1]
		var x =""
		if ".wav" in temp :
			for i in temp:
				x +=i
				if i ==temp[temp.find(".wav")-1]:
					break
		if ".ogg" in temp :
			for i in temp:
				x +=i
				if i ==temp[temp.find(".ogg")-1]:
					break
		audio.name = x
		add_child(audio)
		audio.stream = i

func _process(delta):
	for i in get_children():
		if has_method(i.name):
			call(i.name,delta)
			pass


