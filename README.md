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
   - [ ] add dunk
   - [ ] handle crouch
   - [ ] add landing anim
   - [.] add turn back anim
   - [ ] add slide
   - [ ] with and without balls anim
   - [x] improve wall jump (feet must be on wall ?)
   - [ ] add multiple shoot types
   - [ ] Death and life system
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
   - [ ] improve animation of balls
   - [ ] squish anim for squish balls
   - [x] add several balls (bouncy ball, fire ball, linked ball, phantom ball)
   - [ ] handle interactions with environment elements
   - [.] Add new powers when selection+active (such as megaBOUM, dash, RollingDestroying...)
* Juice :
   - [ ] Camera shake on heavy ball, dunks and other style action
   - [.] particles on balls, dust on footsteps & slide
   - [ ] add UBER mode with new animations
   - [ ] add sound (music + effect and stylish voice)
* Add UIs
   - [ ] Complete editor by adding tilemapping in it
* Add levels

## Issues
### Physical movement
* [x] Weird straight **jump** on a corner. Don't know why it happens and what to do.
* [x] Sometimes the **dunkjump** gives a velocity of `(-nan, dunkjump_speed)`. This is due to it's calculation with a square root
* [x] **Dunking** while pushing a direction button toward another basket above results in no dunk on the current basket. -> change the criteria for the basket by taking into account a very close basket.
* [ ] **Walljumping** at the same time that dunking results in dunking called on a **wrong basket** (if multiple baskets around)
* [ ] **Aiming shooting** right after dunk results in **strange animation behaviour**.
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [ ] **Air dunkjump** when dunking can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* [ ] Get out from **low ceiling** (crouched) when returning can result in infinite returning **animation**.
* [ ] (Not problematic) Pressing **jump** and **dunkjump** just before landing can result in small dunkjump/jump.
* [ ] **release** ball when **aiming** results in error.

### Dynamic items
* [ ] **Zipline** drop inside collision places results in stucked player
* [x] Get out from **zipline** just on flat floor results in sliding (like on ice).
* [ ] Get out from **zipline** just after passing over a **Jumper** results in sliding (like on ice) because **can_go_timer** was changed.
* [ ] Stuck colliding on a **trail** can result in building speed.
* [ ] Weird behaviour on leaving a **zipline** to a **trail** (there is a moment when the character is on both of them)
    - Implement character holder group with `free_character` and `pickup_character` methods.
* [ ] Characters can leave **trail** if Player press **crouch** on it.
    - Implement the `riding` and `hanging` states.
* [ ] Entering **Pipe** at perfect frame when disabling the **Pipe** can result in a disabled ball floating in the air. -> don't stop the tween to enter the pipe when disabling the pipe.

### Misc physics
* [x] TileMap hitboxes (bounce on corners of each tile + balls pass through 2 adjacent tiles). **size up the hitboxes smartly**
* [x] Physic of balls when picked up (stay phisically on the ground...). **complicated** see rigidbody functions and how `integrate_force()` works.
* [.] Problems with physics on **slopes**.
* [ ] Problems when passing from a block just **16 pixel** over the other block (results in tiny teleportation but visible due to camera instant movement).
* [ ] **ShockJumping** at frame perfect when crouching on **Jumper** (or when jumping or dunkjumping) results in a huge mega jump sa mère.

### Other
* [x] Spawner rotation position is weird.
* [ ] Energy loss of `constant_energy_balls`.
* [ ] The `shoot_previewer` shows a trajectory slightly above the real one.
* [ ] `Z_as_relative` doesn't work through script... https://github.com/godotengine/godot/issues/45416
* [ ] **ColorRect** for shockwave effect stay in (0,0) global coordinates...
* [ ] Lag if too much balls : make a spawner limit and link the dispawn of a ball to the spawner to increase the spawn count.

## Groups

### physicbodies
Must inherit from `physicbodies.gd`.

### activables
Must inherit from `activable.gd`.

### breakables
Must have an `apply_impulse(momentum : Vector2)` function that handles explosion.
It's either an **area** or a **body** whose parent is the interesting node.
 For a base you can use `Breakable.gd`.

### electrics
Must have an `apply_shock(momentum : Vector2)` function that handles electric shockwave.
It's either an **area** or a **body** but its parent must be the interesting node, which is often in group **activables**
 For a base you can use `Electric.gd`.

### damageables
Must have a `apply_damage(damage : float)`.
It's either an **area** or a **body** but its parent must be the interesting node. For a base you can use `Damageable.gd`.

### balls
Must inherit from `ball.gd`.

### holders
Must have a `free_ball(ball : node)` method.
They can act and hold balls (example: player or pipeball).

### playerholders
