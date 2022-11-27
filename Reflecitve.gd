extends Area2D

func _ready():
	pass

func _on_Reflecitve_area_entered(area:Laser):
	print("FUNC ENTERED")
	if not area: return
	area.state = area.States.REFLECTING
	print("STATE CHANGED")
