extends Node

var owned_tiles: Array

func _ready():
	#initialize the set of tiles the player has access to
	owned_tiles = new_owned_tiles()
	

func new_owned_tiles():
	var letter_points_dict: Dictionary = {
	" ": 0, "A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, 
	"G": 2, "H": 4, "I": 1, "J": 8, "K": 5, "L": 1, "M": 3, 
	"N": 1, "O": 1, "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1, 
	"U": 1, "V": 4, "W": 4, "X": 8, "Y": 4, "Z": 10,
	}
	var owned_tiles_string: String = "  EEEEEEEEEEEEAAAAAAAAAIIIIIIIIIOOOOOOOONNNNNNRRRRRRTTTTTTLLLLSSSSUUUUDDDDGGGBBCCMMPPFFHHVVWWYYKJXQZ"
	var owned_tiles_array: Array
	for c in owned_tiles_string:
		var new_tile = Tile.new()
		new_tile.letter = c
		new_tile.point_value = letter_points_dict[c]
		owned_tiles_array.append(new_tile)
	return owned_tiles_array

func add_to_owned_tiles(t: Tile):
	owned_tiles.append(t)

func remove_from_owned_tiles(t: Tile):
	owned_tiles.erase(owned_tiles.find(t))
