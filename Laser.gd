extends RayCast2D

class_name Laser

#onready var raycast = get_node("RayCast2D") #referencia ao node RayCast2D
const speed = 50/15 # velocidade com que o usuario pode controlar a posição da fonte de luz
var rindex = 1.3 # indice de refraçao
var collision_control:bool = false # true sempre que uma 'colisao' ocorrer,
#daí, collision_control é utilizada p/ evitar que surja mais de 1 instancia do novo raio
var state
enum States {
	NOT_COLLIDING,
	REFLECTING,
	REFRACTING
}
func _ready():
	state = States.NOT_COLLIDING
	set_collide_with_areas(true)

func _process(delta):
	#print(get_collider())
	match state:
		States.NOT_COLLIDING:
			collision_response()
		States.REFLECTING:
			collision_response_reflect()
		States.REFRACTING:
			collision_response_refract()
	#print("PROCESS")
	direction_control()
	position_control()

func direction_control():
	var mousePos:Vector2 = get_global_mouse_position()
	var direction:Vector2 = mousePos - global_position
	set_cast_to(direction)

#position_control é apenas para o usuario poder controlar a posiçao de onde sai o raio inicial
func position_control():
	# controle por WASD
	if Input.is_action_pressed("ui_right"):
		global_position.x += speed
	elif Input.is_action_pressed("ui_left"):
		global_position.x -= speed
	elif Input.is_action_pressed("ui_down"):
		global_position.y += speed
	elif Input.is_action_pressed("ui_up"):
		global_position.y -= speed

func collision_response():
	#print("COLLISION_RESPONSE")
	var area:Area2D = get_collider()
	if not is_colliding(): return
	if area == null:
		pass
	elif area.get_groups()[0] == "Refract":
		state = States.REFRACTING
		print("DEBUG")
	elif area.get_groups()[0] == "Reflect":
		state = States.REFLECTING
	

func collision_response_reflect():
	var area = get_collider()
	#print(area)
	var childRay:RayCast2D
	if is_colliding() and !collision_control:
		collision_control = true
		var newLaser = RayCast2D.new()
		get_parent().add_child(newLaser)
		newLaser.add_to_group("ChildRay")
	if is_colliding() and collision_control:
		var n:Vector2 = get_collision_normal()
		var p:Vector2 = get_collision_point()
		var t1:float
		t1 = abs(get_cast_to().angle_to(n))
		if get_cast_to().angle_to(n) > 0:
			t1 = abs(get_cast_to().angle_to(n) - PI)
		elif get_cast_to().angle_to(n) < 0:
			t1 = abs(PI + get_cast_to().angle_to(n))
		childRay = get_tree().get_nodes_in_group("ChildRay")[0]
		childRay.global_position = p
		if get_cast_to().angle_to(n) > 0:
			childRay.set_cast_to(get_cast_to().rotated(PI- 2*t1))
		elif get_cast_to().angle_to(n) < 0:
			childRay.set_cast_to(get_cast_to().rotated(-(PI-2*t1)))
		childRay.force_raycast_update()
		
	if not is_colliding():
		for j in get_tree().get_nodes_in_group("ChildRay"):
			j.queue_free()
		collision_control = false
		state = States.NOT_COLLIDING
	if area != get_collider():
		print(area)
		print(get_collider())
		print("A")
		state = States.NOT_COLLIDING
	
#essa funçao deve ser chamada sempre que o RayCast colidir com um objeto refratario
func collision_response_refract():
	var area:Area2D = get_collider() 
	var childRay:RayCast2D #vai armazenar o novo raio
	if is_colliding() and !collision_control:
		#instancia o novo raio em newLaser e adiciona ao grupo ChildRay
		collision_control = true
		var newLaser = RayCast2D.new()
		get_parent().add_child(newLaser)
		newLaser.add_to_group("ChildRay")
	if is_colliding() and collision_control:
		var n:Vector2 = get_collision_normal()
		var p:Vector2 = get_collision_point()
		var t1:float
		if get_cast_to().angle_to(n) > 0:
			t1 = abs(get_cast_to().angle_to(n) - PI)
		elif get_cast_to().angle_to(n) < 0:
			t1 = abs(PI + get_cast_to().angle_to(n))
		var t2:float = asin(sin(t1)/rindex)
		var delta:float = abs(t1-t2)
		childRay = get_tree().get_nodes_in_group("ChildRay")[0]
		childRay.global_position = p
		if get_cast_to().angle_to(n) > 0:
			childRay.set_cast_to(get_cast_to().rotated(-delta))
		elif get_cast_to().angle_to(n) < 0:
			childRay.set_cast_to(get_cast_to().rotated(delta))
		childRay.force_raycast_update()
	if not is_colliding():
		for j in get_tree().get_nodes_in_group("ChildRay"):
			j.queue_free()
		collision_control = false
		state = States.NOT_COLLIDING
	
	if area != get_collider():
		state = States.NOT_COLLIDING
	
	
