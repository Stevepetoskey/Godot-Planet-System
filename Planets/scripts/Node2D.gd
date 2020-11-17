extends Node2D

const XSCALE = 700
const YSCALE = 700

var planets = [preload("res://texture/Planets/sun.png"),preload("res://texture/Planets/RuinEarth.png"),preload("res://texture/Planets/HabMoon.png"),preload("res://texture/Planets/RockMoon.png")]
#Planetary_object: [name,orbiting distance,planet type,orbiting, day length (In minutes), orbit period (In minutes),Yrange]
var system = [["Sun",0,1,-1,0,0,[0,0]],["Ruined Earth",100,2,0,1,365,[0,0]],["Habital Moon",25,3,1,27.3,27,[-200,200]],["Unknown moon",50,4,1,50,1,[-200,200]],["Unknown planet",400,4,0,5,1460,[-200,200]]]

var currentPlanet = 1
var start = false
var isDay = false
var sunAngle = 0

func update_pos(planet):
	var mainPlanet = get_node("PlanetHold").get_child(currentPlanet)
	var rot = mainPlanet.rot
	$stars.rotation_degrees = 360 - rot
	if planet.id != currentPlanet:
		if planet.id != 0:
			 #Shading
			var sun = get_node("PlanetHold").get_child(0)
			var p2SunAngle
			var p1P2Angle
			p1P2Angle = rad2deg(atan2(abs(mainPlanet.spacePos.y-planet.spacePos.y),abs(mainPlanet.spacePos.x-planet.spacePos.x)))
			p2SunAngle = rad2deg(atan2(abs(sun.spacePos.y-planet.spacePos.y),abs(sun.spacePos.x-planet.spacePos.x)))
			var firstAngle = p2SunAngle + p1P2Angle
			var angle = firstAngle - 160
			if angle >= 360:
				angle -= 360
			elif angle < 0:
				angle += 360
			planet.update_light(round(angle/20))
		var posInSky
		if planet.orbiting == currentPlanet: #orbiting planets
			var y = planet.spaceY
			var standardLinePos = planet.orbitPos - rot
			if standardLinePos >= 360:
				 standardLinePos -= 360
			elif standardLinePos < 0:
				standardLinePos += 360
			posInSky = Vector2(960 + XSCALE*cos(deg2rad(standardLinePos)),(900+planet.spaceY)+YSCALE*sin(deg2rad(standardLinePos)))
		elif planet.id == system[currentPlanet][3]: #orbited planets
			var orbitPos = mainPlanet.orbitPos
			var standardLinePos = orbitPos - rot
			if standardLinePos >= 360:
				 standardLinePos -= 360
			elif standardLinePos < 0:
				standardLinePos += 360
			posInSky = Vector2(960+XSCALE*cos(deg2rad(standardLinePos)),(900 - mainPlanet.spaceY)+YSCALE*sin(deg2rad(standardLinePos)))
		else: #Indirect bodies
			var distance = Vector2(planet.spacePos.x-mainPlanet.spacePos.x,planet.spacePos.y-mainPlanet.spacePos.y)
			var angle
			angle = rad2deg(atan2(abs(distance.y),abs(distance.x)))
			angle -= rot
			if angle >= 360:
				angle -= 360
			elif angle < 0:
				angle += 360
			posInSky = Vector2((960+distance.x)+XSCALE*cos(deg2rad(angle)),((600-mainPlanet.spacePos.y+distance.y)+YSCALE*sin(deg2rad(angle))))
		if planet.id == 0:
			var dayTime
			var sunsAngle = Vector2(posInSky.x-960,posInSky.y-900)
			dayTime = rad2deg(atan2(sunsAngle.y,sunsAngle.x))
#			print(dayTime)
			$sky.visible = false
			$stars.visible = true
			if dayTime <= -20 and dayTime >= -160:
				$sky.visible = true
				$stars.visible = false
				isDay = true
			else:
				isDay = false
			if dayTime <= 0 and dayTime >= -40:
				$SunsetSunrise.visible = true
				if dayTime >= -20:
					$SunsetSunrise.material.set_shader_param("opac",stepify(abs(dayTime)/20.0,0.001))
				else:
					$SunsetSunrise.material.set_shader_param("opac",stepify(abs(((abs(dayTime)-20)-21))/20.0,0.001))
			elif dayTime <= -140:
				$SunsetSunrise.visible = true
				if dayTime >= -160:
					print(dayTime,",",stepify((abs(dayTime)-140)/20.0,0.001))
					$SunsetSunrise.material.set_shader_param("opac",stepify((abs(dayTime)-140)/20.0,0.001))
				else:
					print(stepify(abs(((abs(dayTime)-20)-161))/16.0,0.001))
					$SunsetSunrise.material.set_shader_param("opac",stepify(abs(((abs(dayTime)-20)-161))/16.0,0.001))
			else:
				$SunsetSunrise.visible = false
			sunAngle = dayTime

		planet.position = posInSky
		var dist = sqrt(pow(planet.spacePos.x-mainPlanet.spacePos.x,2)+pow(planet.spacePos.y-mainPlanet.spacePos.y,2))
		if dist < 500:
			planet.visible = true
			planet.scale = Vector2(1-dist/500,1-dist/500)
		else:
			planet.visible = false

func init_sky():
	for i in range(system.size()):
		var planet = load("res://assets/Planet.tscn").instance()
		planet.orbitingDist = system[i][1]
		planet.texture = planets[system[i][2]-1]
		planet.orbiting = system[i][3]
		planet.rotationSpeed = system[i][4]
		planet.orbitSpeed = system[i][5]
		planet.id = i
		planet.yRange = system[i][6]
		planet.set_material(load("res://shaders/Planet.tres").duplicate())
		get_node("PlanetHold").add_child(planet)
	start = true
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	init_sky()
	for child in get_node("PlanetHold").get_children():
		update_pos(child)
	for i in range(350):
		var star = load("res://assets/Star.tscn").instance()
		star.position = Vector2(randi()%4000-2000,randi()%3000-1500)
		star.animation = str(randi()%4+1)
		get_node("stars").add_child(star)
	get_node("PlanetHold").get_child(2).position = Vector2(960,300)

func _process(delta):
	for child in get_node("PlanetHold").get_children():
		update_pos(child)
