extends Node

@export var board: Node3D

func score_word(played_word):
	var word_score = 0
	for i in played_word:
		word_score += i.get_score()
	print("word score: " + str(word_score))
