extends Node
var points:int = 0

func add_points(amount: int):
	points += amount
	print ("points: ", points)

func get_points()-> int:
	return points
