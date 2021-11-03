# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----

## Work to do
* Graphism :
   - [.] environment elements
   - [.] other tilesets
   - [.] other background
   - [ ] all movement sprites
   - [ ] UI graphism such as tag-police
* Moveset improvment :
   - [ ]add dunk
   - [ ]handle crouch
   - [ ]add landing anim
   - [.] add turn back anim
   - [ ]add slide
   - [ ]with and without balls anim
   - [x]improve wall jump (feet must be on wall ?)
   - [ ]add multiple shoot types
   - [ ]Death and life system
* Add interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [.] baskets
   - [.] spawners
   - [.] activable
   - [.] ziplines
   - [ ] Add enemies and NPC
   - [ ] Add destroyable blocks
   - [ ] Add one way platforms and ball-doors / player-doors
   - [.] pipes (TODO : change bounding box + handle multiple sides + be careful on exit_throw)
* Add point system
   - [ ] UI for combos
   - [ ] Combo and point system
* Improve shooter
   - [ ] Auto aim on baskets
* Balls :
   - [ ]improve animation of balls
   - [ ]squish anim for squish balls
   - [x] add several balls (bouncy ball, fire ball, linked ball, phantom ball)
   - [ ]handle interactions with environment elements
   - [ ] Add new powers when selection+active (such as megaBOUM, dash, RollingDestroying...)
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
* [FIXED] Dunking while pushing a direction button toward another basket above results in no dunk on the current basket. -> change the criteria for the basket by taking into account a very close basket.
* Walljumping at the same time that dunking results in dunking called on a wrong basket (if multiple baskets around)
* Aiming shooting right after dunk results in strange animation behaviour.
* Dunkjumping while only moving with floor adherence a bit far from basket results in missing the basket.
* Problems with physics on slopes
* Air dunkjump when dunking can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* Z_as_relative doesn't work through script... https://github.com/godotengine/godot/issues/45416

## Groups

### physicbodies
Must inherit from `physicbodies.gd`.

### balls
Must inherit from `ball.gd`.

### holders
Must have a `free_ball(ball : node)` method.
They can act and hold balls (example: player or pipeball).

### activables
Must inherit from `activable.gd`.
