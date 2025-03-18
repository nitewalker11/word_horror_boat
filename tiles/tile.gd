extends Resource

class_name Tile

var letter: String
var point_value: int
var material: String
var material_dict: Dictionary = {
	"wood": 1,
	"gold": 2,
	"bone": 3,
	"coal": 4,
	"insect": 5,
}
#brands can be applied to any tile to cause an effect
var brand: String
var brand_dict: Dictionary = {
	"lucky": 1,
	"sticky": 2,
	"plustwo": 3,
	"plusfive": 4,
}

func when_played():
	#all tiles score based on their point value
	if brand == "plustwo":
		point_value += 2
	if brand == "plusfive":
		point_value += 5
	if brand == "sticky":
		#tile is not added back to bag
		#next board starts with tile in same position
		pass

func score():
	#send points to board to calculate word score
	return point_value

func end_of_round():
	if material == "gold":
		#earn money for each gold tile
		pass

func in_bag():
	if brand == "lucky":
		#tile is 10x as likely to be pulled from the bag
		pass
	if material == "gold":
		#if tile gets picked, pick a 2nd tile and randomly choose between the two of them
		pass
	if material == "insect":
		#after tiles are drawn, has a 1 in 5 chance of crawling out of the bag into a random spot on the board
		pass
