# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----

## Work to do
* Graphism :
   - [.] environment elements
   - [.] other tilesets
   - [.] other background
   - [.] all movement sprites
   - [ ] UI graphism such as tag-police
* Moveset improvment :
   - [x] add dunk
   - [x] handle crouch
   - [x] add landing anim
   - [x] add turn back anim
   - [.] add slide
   - [ ] with and without balls anim
   - [x] improve wall jump (feet must be on wall ?)
   - [ ] add multiple shoot types
   - [ ] Death and life system
* Add interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [x] baskets
   - [x] spawners
   - [x] activable
   - [.] ziplines -> to rework
   - [.] Add enemies and NPC
   - [x] Add destroyable blocks
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
   - [.] handle interactions with environment elements
   - [.] Add new powers when selection+active (such as megaBOUM, dash, RollingDestroying...)
* Juice :
   - [x] Camera shake on heavy ball, dunks and other style action
   - [x] particles on balls, dust on footsteps & slide
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
* [x] **Walljumping** at the same time that dunking results in dunking called on a **wrong basket** (if multiple baskets around)
* [x] **Aiming shooting** right after dunk results in **strange animation behaviour**.
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [ ] **dunking** can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* [x] Get out from **low ceiling** (crouched) when returning can result in infinite returning **animation**.
* [ ] **release** ball when **aiming** results in error.
* [ ] It is possible to **dunk** through walls. It can result in dunkjump particles (+ghost) emmiting (dont know why).
* [ ] **shooting** just before **landing** results in `floor_shoot` just after `aim_shoot` animation
* [ ] There is some jitter animation when passing from a **dunkjump** state to a **grind** state.
* [ ] There is some jitter animation when passing from a **dunk** state to a **hang** state.

### Dynamic items
* [ ] **Zipline** drop inside collision places results in stucked player.
* [ ] Get out from **zipline** just after passing over a **Jumper** results in sliding (like on ice) because **can_go_timer** was changed.
* [ ] Stuck colliding on a **rail** can result in building speed.
* [ ] At the connection between a **rail** and a solid block, if the character is falling such that they will wallslide on the block if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 initial speed.
    - At the connection between a **rail** and stairs, if the character is falling such that they will go on the slope if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 speed in the direction down the stairs.
* [x] Weird behaviour on leaving a **zipline** to a **rail** (there is a moment when the character is on both of them)
    - Implement character holder group with `free_character` and `pickup_character` methods.
* [x] Characters can leave **rail** if Player press **crouch** on it.
    - Implement the `riding` and `hanging` states.
* [ ] Entering **Pipe** at perfect frame when disabling the **Pipe** can result in a disabled ball floating in the air. -> don't stop the tween to enter the pipe when disabling the pipe.

### Misc physics
* [x] TileMap hitboxes (bounce on corners of each tile + balls pass through 2 adjacent tiles). **size up the hitboxes smartly**
* [x] Physic of balls when picked up (stay phisically on the ground...). **complicated** see rigidbody functions and how `integrate_force()` works.
* [.] Problems with physics on **slopes**.
* [ ] Problems when passing from a block just **16 pixel** over the other block (results in tiny teleportation but visible due to camera instant movement).
* [x] **ShockJumping** at frame perfect when crouching on **Jumper** (or when jumping or dunkjumping) results in a huge mega jump sa mère.
* [ ] Jitter when multiple **balls** are above each other. -> reimplement the friction

### Other
* [x] Spawner rotation position is weird.
* [ ] Energy loss of `constant_energy_balls`.
* [ ] The `shoot_previewer` shows a trajectory slightly above the real one.
* [ ] `Z_as_relative` doesn't work through script... https://github.com/godotengine/godot/issues/45416
* [ ] **ColorRect** for shockwave effect stay in (0,0) global coordinates...
* [ ] Lag if too much balls : make a spawner limit and link the dispawn of a ball to the spawner to increase the spawn count.
* [ ] I need to adapt the boum delay: i.e apply_impulse instantly on colliding object and a bit after on far objects. nedd a method call_after_a_delay(apply_impulse)
* [ ] **Bubble/Zap ball teleportation** trailhandler can act very weirdly if used quickly repeatly.
* [.] Need to implement Tilemap interactive objects rotation and flips.
* [ ] On **baskets**, a ball that bounces on the ring can do multiple goals.
* [ ] If multiple explosion breaks the same bloc, it can spawn copies.

### Potential Glitches
* [ ] Pressing **jump** and **dunkdash** just before landing can result in small dunkdash/jump.
* [ ] **Jumping** (from ground) just before entering a **rail** can result in a boost grind.
* [ ] **Dunkdashing** just before entering a **rail** can result in a dash boost grind.

## Groups

### physicbodies
Must inherit from `physicbodies.gd`.

### activables
Must inherit from `activable.gd`.

### breakables
Must have an `apply_explosion(momentum : Vector2)` function that handles explosion. It should returns whether the body has explode (if the collision box has been modified to null or layers to 0).
It's either an **area** or a **body** whose parent is the interesting node.
 For a base you can use `Breakable.gd`.

### electrics
Must have an `apply_shock(momentum : Vector2)` function that handles electric shockwave.
It's either an **area** or a **body** but its parent must be the interesting node, which is often in group **activables**
 For a base you can use `Electric.gd`.

### damageables
Must have a `apply_damage(damage : float, duration : float = 0.0)`.
It's either an **area** or a **body** but its parent must be the interesting node. For a base you can use `Damageable.gd`.

### balls
Must inherit from `ball.gd`.

### holders
Must have a `free_ball(ball : node)` method.
They can act and hold balls (example: player or pipeball).

### characters
Must have a `get_in(new_holder : Node)` and a `get_out(global_pos : Vector2, velo : Vector2)` function.

### characterholders
Must have a `free_character(character : node)` method.
