extends Node

class_name Stamp

var stamp_type_dict: Dictionary = {
	"DL":2, "DW":2,
	"TL":3, "TW":3, 
	"QL":4, "QW":4, 
	"BU":1, "BO":1,
	"EV":1, "CC": 1,
	"TO":1
	}

var stamp_sprite_dict: Dictionary = {
	"DL":"uid://64hg3bk0op0m"
	}

var stamp_type: String

func set_stamp_type(type: String):
	if !stamp_type_dict.has(type):
		return
	stamp_type = type

func board_setup():
	if stamp_type == "EV":
		eternal_vowel()
	if stamp_type == "CC":
		constant_consonant()

func pre_score():
	if stamp_type.contains("L"):
		letter_multiplier()

func post_score():
	if stamp_type.contains("W"):
		word_multiplier()
	if stamp_type == "BU":
		burn()
	if stamp_type == "BO":
		bounce()
	if stamp_type == "TO":
		touch()

func letter_multiplier():
	pass
func word_multiplier():
	pass
func burn():
	# a tile played in this spot gets burned after you score the word
	pass
func bounce():
	#a tile played in this spot gets discarded after you score the word
	pass
func eternal_vowel():
	#acts as a vowel, rolled randomly each round, can be covered or used
	pass
func constant_consonant():
	#acts as a consonant, rolled randomly each round, can be covered or used
	pass
func touch():
	#if the scored word is touching this tile, but not covering it, get a bonus
	pass
