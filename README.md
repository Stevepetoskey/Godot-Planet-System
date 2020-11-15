# Godot Planet System

First a few things, I will try to explain this the best I can however I might leave some things out, so please let me know if you are lost a some point. Next this might not work as well as it should, and any time I find a bug I will be sure to update this repository.

## Setting it up

The great thing about this is that if you don't want to touch any of the code and just want this for a game, that could not be anymore easier. In the main scene, and in the "Node2D" script there should be 3 variables that you should care about. The first one is planets, the second one is system, and the last is currentPlanet. The planets array is where all the planet textures are loaded. The currentPlanet variable is the Id of the planet the camera is on. And the system array is the objects data.
Here is the defualt system array:
''' GDScript
