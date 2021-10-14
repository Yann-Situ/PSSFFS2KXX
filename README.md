# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----

## Work to do
* Graphism :
   - [.] environment elements
   - [.] other tilesets
   - [.]other background
   - [ ]all movement sprites
* Moveset improvment :
   - [ ]add dunk
   - [ ]handle crouch
   - [ ]add landing anim
   - [.] add turn back anim
   - [ ]add slide
   - [ ]with and without balls anim
   - [x] improve wall jump (feet must be on wall ?)
   - [ ]add multiple shoot types
* Add interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [.] baskets
   - [.] spawners
   - [.] activable
   - [.] ziplines
* Add point system
* Improve shooter
* Balls :
   - [ ]improve animation of balls
   - [ ]squish anim for squish balls
   - [x] add several balls (bouncy ball, fire ball, linked ball, phantom ball)
   - [ ]handle interactions with environment elements
* Juice :
   - [ ]Camera shake on heavy ball, dunks and other style action
   - [.] particles on balls, dust on footsteps & slide
   - [ ]add UBER mode with new animations
   - [ ]add sound (music + effect and stylish voice)
* Add UIs
   - [ ]Complete editor by adding tilemapping in it
* Add levels

## Issues
* [FIXED] TileMap hitboxes (bounce on corners of each tile + balls pass through 2 adjacent tiles). **size up the hitboxes smartly**
* [FIXED] Physic of balls when picked up (stay phisically on the ground...). **complicated** see rigidbody functions and how `integrate_force()` works.
* [FIXED] Weird straight jump on a corner. Don't know why it happens and what to do.
* Energy loss of _constant_energy_balls_.
* The `shoot_previewer` shows a trajectory slightly above the real one.
* Zipline drop inside collision places results in stucked player
* [FIXED] Spawner rotation position is weird.
* [FIXED] Sometimes the dunkjump gives a velocity of `(-nan, dunkjump_speed)`. This is due to it's calculation with a square root
* Dunking while pushing a direction button toward another basket above results in no dunk on the current basket. -> change the criteria for the basket by taking into account a very close basket
