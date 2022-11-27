extends Area2D


func _ready():
	pass


func _on_Refract_area_entered(area:Laser):
	if not area: return
	area.state = area.States.REFRACTING
