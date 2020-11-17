extends Sprite

var spacePos = Vector2(0,0)
var orbitPos = 0
var spaceY = 0
var id = 0
var orbiting = 0
var orbitingDist = 0
var orbitSpeed = 0
var rot = 0
var rotationSpeed = 0
var yRange = [0,0]
var yRaise = 0.1
var time = 0

var phases = [preload("res://texture/Light/tile010.png"),preload("res://texture/Light/tile009.png"),preload("res://texture/Light/tile008.png"),preload("res://texture/Light/tile007.png"),preload("res://texture/Light/tile006.png"),preload("res://texture/Light/tile005.png"),preload("res://texture/Light/tile004.png"),preload("res://texture/Light/tile003.png"),
preload("res://texture/Light/tile002.png"),preload("res://texture/Light/tile001.png"),preload("res://texture/Light/tile000.png")]

func _ready():
	if id != 0:
		randomize()
		rot = randi() % 360
		orbitPos = randi() % 360
		if yRange != [0,0]:
			spaceY = randi() % yRange[0] + yRange[1]
		if rotationSpeed > 0:
			get_node("RotationTmer").start(float(abs(rotationSpeed)*60)/3600.0)
			print(get_node("RotationTmer").wait_time)
		if orbitSpeed > 0:
			get_node("OrbitTimer").start(float(abs(orbitSpeed)*60)/3600.0)
	if get_node("../..").currentPlanet == id:
		visible = false


func _process(delta):
	if id != 0:
		time = get_node("../..").sunAngle
		var orbitPlanetPos = get_node("..").get_child(orbiting).spacePos
		spacePos = Vector2(cos(deg2rad(orbitPos))*(orbitingDist)+orbitPlanetPos.x,sin(deg2rad(orbitPos))*(orbitingDist)+orbitPlanetPos.y)
		var opac = 0.0
		if time <= 0 and time >= -40:
			opac = stepify(abs(abs(time)-40)/40.0,0.01)
		elif time <= -140:
			opac = stepify((abs(time)-140)/40.0,0.01)
		elif time < -40 and time > -140:
			opac = 0.1
		else:
			opac = 1.0
		material.set_shader_param("opac",opac)

func update_light(lightLevel):
	if lightLevel < 11:
		material.set_shader_param("fliped",true)
		material.set_shader_param("mask_texture",phases[lightLevel])
	if lightLevel >= 11:
		material.set_shader_param("fliped",false)
		material.set_shader_param("mask_texture",phases[20-lightLevel])

func _on_RotationTmer_timeout():
	if rotationSpeed > 0:
		if rot < 359:
			rot += 0.1
		else:
			rot = 0
	else:
		if rot > 0:
			rot -= 0.1
		else:
			rot = 359


func _on_OrbitTimer_timeout():
	if orbitSpeed > 0:
		if orbitPos < 359:
			orbitPos += 0.1
		else:
			orbitPos = 0
	else:
		if orbitPos > 0:
			orbitPos -= 0.1
		else:
			orbitPos = 359
	if yRange != [0,0]:
		if spaceY > yRange[0] and spaceY < yRange[1]:
			spaceY += yRaise
		else:
			yRaise *= -1
