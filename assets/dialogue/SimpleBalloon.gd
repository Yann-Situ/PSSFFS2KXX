extends Node2D

signal dialogue_finished

@export var seconds_per_character : float = 0.03

@onready var balloon: Panel = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

## The dialogue resource
var dialogue_resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			stop()
			return

		dialogue_line = next_dialogue_line

		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = tr(dialogue_line.character, "dialogue")

		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		# Show our balloon
		balloon.show()

		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		var time = dialogue_line.text.length() * seconds_per_character
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)

	get:
		return dialogue_line


func _ready() -> void:
	balloon.hide()

## Start some dialogue
func start(_dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = extra_game_states
	dialogue_resource = _dialogue_resource
	self.show()
	animation_player.play("appear")
	next(title)

func stop() -> void:
	animation_player.play("disappear")
	await animation_player.animation_finished
	self.hide()
	dialogue_finished.emit()

## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)
