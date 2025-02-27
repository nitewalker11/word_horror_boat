extends Node

@export_file var word_list
var word_dict: Dictionary = {}

func _ready():
	create_dictionary()

func create_dictionary():
	#convert txt file into string
	var file = FileAccess.open(word_list, FileAccess.READ)
	var list_str: String = file.get_as_text()
	#split string into individual lines
	var line_array: PackedStringArray = list_str.split("\n")
	#shorten each line to just the word and add it to a dictionary
	for i in line_array.size():
		word_dict.get_or_add(str(line_array[i].left(line_array[i].find(" "))), i)

func check_dictionary(w: String):
	return word_dict.has(w)
