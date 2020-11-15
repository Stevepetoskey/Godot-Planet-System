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

# For orbited bodies
