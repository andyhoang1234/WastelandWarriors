# In your Label node's script:
extends Label

func _ready():
	update_label()

func update_label():
	self.text = "dorrah: " + str(Global.dorrah)

func add_dorrah(amount: int):
	Global.add_dorrah(amount)
	update_label()

func subtract_money(amount: int):
	Global.subtract_money(amount)
	update_label()
