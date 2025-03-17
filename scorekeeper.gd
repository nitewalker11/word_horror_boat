extends Node

@export var board: Node3D

func _ready() -> void:
	#board.played.connect(played)
	pass

func played(board: Array, size: int):
	var played_word: Array = find_played_word()
	if is_valid_word(played_word):
		score_word(played_word)

func find_played_word():

	pass

func is_valid_word(word: Array):

	pass

func score_word(played_word):
	pass
