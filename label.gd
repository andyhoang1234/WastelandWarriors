# In your Label node's script:
extends Label

func _ready():
	update_label()

func update_label():
	self.text = "dorrah: " + str(Global.dorrah)

func add_money(amount):
	Global.add_money(amount)
	update_label()

func subtract_money(amount):
	Global.subtract_money(amount)
	update_label()
