@icon("res://assets/art/icons/music-r-16.png")
extends Node2D
class_name AudioHandler
## handle the audio of a player

signal change_music() # TODO

@export var music_default : AudioStream : set = set_music_default ## music played by default

func set_music_default(music : AudioStream):
	music_default = music
	$AudioMusic.stream = music

func play_music():
	# TODO fade in
	$AudioMusic.play()
func stop_music():
	# TODO fade out
	$AudioMusic.stop()
