# Godot Planet System

First a few things, I will try to explain this the best I can however I might leave some things out, so please let me know if you are lost a some point. Next this might not work as well as it should, and any time I find a bug I will be sure to update this repository.

## Setting it up

The great thing about this is that if you don't want to touch any of the code and just want this for a game, that could not be anymore easier. In the main scene, and in the "Node2D" script there should be 3 variables that you should care about. The first one is planets, the second one is system, and the last is currentPlanet. The planets array is where all the planet textures are loaded. The currentPlanet variable is the Id of the planet the camera is on. And the system array is the objects data.
Here is the defualt system array:
``` GDScript
var system = [["Sun",0,1,-1,0,0,[0,0]],["Ruined Earth",100,2,0,1,365,[0,0]],["Habital Moon",25,3,1,27.3,27,[-200,200]],["Unknown moon",50,4,1,50,1,[-200,200]],["Unknown planet",400,4,0,5,1460,[-200,200]]]
```
So lets look at just the "system" array. It has 5 other arrays in it, these are the planets/stars/moons data. So for intance, ```["Habital Moon",25,3,1,27.3,27,[-200,200]] ``` : has the name Habital Moon, has a orbit distance of 25 units, has a planet type of 3, it is orbiting planet ID 1, it has a day length of 27.3 minutes, it has a orbit speed of 27 minutes, and a Y range of -200 through 200. Name, orbit distance, day lenght, and orbit speed should be pretty easy to understand. The planet type is where the planet is pulling its texture from the ```planets``` array. The "Orbiting planet: ID" is just what planet in the ```system``` array the planet is orbiting. The ID is just the planets location in the array. The Y range is just where the planets Space Y positon is, fill the array with both the same numbers to keep it from moving up and down. Example a planet will slowly move up and down between 10 and 100 if the Y range is ```[10 , 100]```, and a planet will not move up and down from -10 if the Y range is ```[-10,-10]```. So in the end the planetary data should look like this:
```
[Name , orbiting distance , planet type , orbiting, day length (In minutes), orbit period (In minutes), Y range]
```
And that is all you need to know, but of course I am going all in on this one.

## Getting the planets in the sky correctly

Before you continue I suggest having some knowledge of trigonometry, as everything revolves around trigonometry in this system. But maybe I may do a good job of explaining everything enough to allow you to at least understand what the program does. Now the reason everything is so complex is because everything is in 2D. Unlike 3D, in a 2D space you can only see in one direction. So if this system where to be a background you would only be able to see a sunrise or a sunset. But to combat this I decided to make the very east of the sky and the very west of the sky in the same direction. So think of the sky as if you where on the north or south pole, it is confusing I know but it just works.

### For orbited bodies

The formula for getting a orbited body's sky position is as follows:
```
posInSky = (O1+X*cos(θ),(O2+Y2)+Y*sin(θ))
```
All this formula is is basically the formula for finding the position of a angle on the circle. Where as O1 is the X offset, O2 is the Y offset, (X,Y) is the circles radius (Making two variables for the radius allows more control), and θ is the current planets orbit angle to the orbited planet. One thing I added was Y2, which is the current planets space Y position. Transformed into GD script is:
```GDScript
posInSky = Vector2(OFFSET.x+XSCALE*cos(deg2rad(standardLinePos)),(OFFSET.y - currentPlanet.spaceY)+YSCALE*sin(deg2rad(standardLinePos)))
```
It is very important you put the angle in ```deg2rad``` first, otherwise it makes everything all off. Now get the standardLinePos. StandardLinePos is the planet's position on a perfect unedited one radius circle, called [The Unit Circle](https://www.mathsisfun.com/geometry/unit-circle.html). To get the standardLinePos for a orbited body simply subtract the current planets rotation from the current planet's orbit angle 

### For orbiting bodies

The formula for getting a orbiting body's sky position is very similar to the orbited bodies formula, however make Y2 be the orbiting planets space Y position.
```GDScript
posInSky = Vector2(960 + XSCALE*cos(deg2rad(standardLinePos)),(900+planet.spaceY)+YSCALE*sin(deg2rad(standardLinePos)))
```
**standardLinePos is found by subtracting the orbiting planet's orbit angle and the current planet's rotation angle**

### For indirect bodies

In order to do this a lot of things must be done. First get the x and y distance to the object. This is simply done by ```(X2-X1,Y2-Y1)``` where 2 is the current planets Space coordinates. Now time to get the angle between the main planet and the indirect body. This is where inverse tan is introduced. Inverse tan (aka ```atan()``` in godot) allows you to put y postion divided by the x position to get the angle. However inverse tan can be wonky sometimes and even may crash your game (if y equals 0) so godot has a helpful function called ```atan2()``` which acts just like ```atan``` however it is less wonky and does not crash your game (A possible bug I need to fix is once atan gets to 0 it starts going into negatives until it reaches -180 and switches to 180, so indirect bodies and other things using atan2 may not work properly right now). So to get the angle use the x and y distance from before and do ```angle = atan2(abs(distance.y),abs(distance.x))```. Of course the planet needs to be rotated in the sky depending on the rotation of the current planet, so also add ```angle -= rotation```. Now it is time for the main formula:
```GDScript
posInSky = Vector2((960+distance.x)+XSCALE*cos(deg2rad(angle)),((600-currentPlanet.spacePos.y+distance.y)+YSCALE*sin(deg2rad(angle))))
```
And now all of the planets, suns, and moons should be in the correct place in the sky.

## Planet shading

**Keep in mind this current version is a bit buggy and may not work as intended**

First things first, on the planet instance (which should only be a sprite with some timers under it) add a shader. This shader is very simple (To simple as of right now, It needs to be able to block out anything behind it) all it needs to do is mask out whatever part is supposed to be shaded, which can be done with this:
```GLSL
shader_type canvas_item;

uniform sampler2D mask_texture;
uniform bool fliped = false;
uniform float opac = 1.0;

void fragment() {
	vec2 uv;
	if (fliped == true) {
		uv = vec2(1.0-UV.x,UV.y)
	} else {
		uv = UV
	}
    vec4 colour = texture(TEXTURE, UV);
    colour.a *= texture(mask_texture, uv).a;
	colour.a *= opac;

    COLOR = colour;
}
```
Now it is onto the hard part, aka more math! First you are going to need to find the angle between the current planet and the other planet:
```GDScript
p1P2Angle = rad2deg(atan2(abs(currentPlanet.spacePos.y-planet.spacePos.y),abs(currentPlanet.spacePos.x-planet.spacePos.x)))
```
And then do the same to find the angle between the other planet and the sun, just replace the ```currentPlanet``` with the sun object.

