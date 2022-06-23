# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----

## Big Goals
* graphism
* animations
* visual effects
* music
* sound design
* AI for NPC
* level design
* level system
* saving system
* GUI for menus
* GUI for in-game
* story

## Work to do
* Graphism :
   - :pushpin: environment elements
   - :pushpin: other tilesets
   - :pushpin: other background
   - :pushpin: all movement sprites
   - [ ] UI graphism such as tag-police
* Moveset improvment :
   - [x] add dunk
   - [x] handle crouch
   - [x] add landing anim
   - [x] add turn back anim
   - :pushpin: add slide
   - [ ] with and without balls anim
   - [x] improve wall jump (feet must be on wall ?)
   - [ ] add multiple shoot types
   - [ ] Death and life system
* Add interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [x] baskets
   - [x] spawners
   - [x] activable
   - :pushpin: ziplines -> to rework
   - :pushpin: Add enemies and NPC
   - [x] Add destroyable blocks
   - [ ] Add one way platforms and ball-doors / player-doors
   - :pushpin: pipes (TODO : change bounding box + handle multiple sides + be careful on exit_throw)
* Add point system
   - [ ] UI for combos
   - [ ] Combo and point system
* Improve shooter
   - :pushpin: Auto aim on baskets
* Balls :
   - [ ] improve animation of balls
   - [ ] squish anim for squish balls
   - [x] add several balls (bouncy ball, fire ball, linked ball, phantom ball)
   - :pushpin: handle interactions with environment elements
   - :pushpin: Add new powers when selection+active (such as megaBOUM, dash, RollingDestroying...)
* Juice :
   - [x] Camera shake on heavy ball, dunks and other style action
   - [x] particles on balls, dust on footsteps & slide
   - [ ] add UBER mode with new animations
   - [ ] add sound (music + effect and stylish voice)
* Add UIs
   - [ ] Complete editor by adding tilemapping in it
* Add levels

### Code structure to implement
* `Selector` is currently a child of `Player/Actions` and is reparent by code to be a child of `Room`. Maybe it should be a child of the room or the level, and accessed in `SpecialActionHandler` via a NodePath or through signals.

## Issues
### Physical movement
* [x] Weird straight **jump** on a corner. Don't know why it happens and what to do.
* [x] Sometimes the **dunkjump** gives a velocity of `(-nan, dunkjump_speed)`. This is due to it's calculation with a square root
* [x] **Dunking** while pushing a direction button toward another basket above results in no dunk on the current basket. -> change the criteria for the basket by taking into account a very close basket.
* [x] **Walljumping** at the same time that dunking results in dunking called on a **wrong basket** (if multiple baskets around)
* [x] **Aiming shooting** right after dunk results in **strange animation behaviour**.
* [x] Get out from **low ceiling** (crouched) when returning can result in infinite returning **animation**.
* [x] Weird behaviour on leaving a **zipline** to a **rail** (there is a moment when the character is on both of them)
    - Implement character holder group with `free_character` and `pickup_character` methods.
* [x] Characters can leave **rail** if Player press **crouch** on it.
    - Implement the `riding` and `hanging` states.
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [x] **dunking** can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* [ ] **release** ball when **aiming** results in error.
* [ ] It is possible to **dunk** through walls. It can result in dunkjump particles (+ghost) emmiting (dont know why).
* [ ] Hard to reproduce (see video) : **dunkjump** on **jumper** can result in `Nan` camera position teleportation. (because to low to mathematically dunkjump => negative value ? division by 0.0 ?)
* [ ] Infinite **walking** animation on 16px block stairs.
* [ ] High jump when `jump_jp` and `jump_jr` just before landing (because the cancelled mounting only test `jump_jr`). (also on walljumps)
* [ ] **one-way platform** make player crouch due to raycast mecanik.
* [ ] **one-way platform** make player unable to do small jumps.

### Dynamic items
* [ ] **Zipline** drop inside collision places results in stucked player.
* [ ] Get out from **zipline** just after passing over a **Jumper** results in sliding (like on ice) because **can_go_timer** was changed.
* [ ] Stuck colliding on a **rail** can result in building speed.
* [ ] At the connection between a **rail** and a solid block, if the character is falling such that they will wallslide on the block if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 initial speed.
    - At the connection between a **rail** and stairs, if the character is falling such that they will go on the slope if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 speed in the direction down the stairs.
* [ ] Entering **Pipe** at perfect frame when disabling the **Pipe** can result in a disabled ball floating in the air. -> don't stop the tween to enter the pipe when disabling the pipe.


### Misc physics
* [x] TileMap hitboxes (bounce on corners of each tile + balls pass through 2 adjacent tiles). **size up the hitboxes smartly**
* [x] Physic of balls when picked up (stay phisically on the ground...). **complicated** see rigidbody functions and how `integrate_force()` works.
* [x] **ShockJumping** at frame perfect when crouching on **Jumper** (or when jumping or dunkjumping) results in a huge mega jump sa mère.
* :pushpin: Problems with physics on **slopes**.
* [ ] Problems when passing from a block just **16 pixel** over the other block (results in tiny teleportation but visible due to camera instant movement).
* [ ] Jitter when multiple **balls** are above each other. -> reimplement the friction
* [ ] **Ball** located just on a spawner position results in very high velocity when spawning a ball on it.

### Other
* [x] Spawner rotation position is weird.
* [x] **portals** : multiple portal_transition due to a late reset position, when changing rooms... see https://godotengine.org/qa/9761/area2d-triggered-more-time-when-player-node-previous-scene and https://github.com/godotengine/godot/issues/14578
* [x] Changing **room** holding a **ball** results in leaving the ball in the previous room.
* [ ] Energy loss of `constant_energy_balls`.
* [ ] Lag if too much balls : make a spawner limit and link the dispawn of a ball to the spawner to increase the spawn count.
* [ ] I need to adapt the boum delay: i.e apply_impulse instantly on colliding object and a bit after on far objects. nedd a method call_after_a_delay(apply_impulse)
* :pushpin: Need to implement Tilemap interactive objects rotation and flips.
* [ ] On **baskets**, a ball that bounces on the ring can do multiple goals.
* [ ] If multiple explosion breaks the same bloc, it can spawn copies.
* [ ] Using the power of a selected ball that died results in error. => Implement a die signal.
* [ ] The game seems to crash when calling **change_holder(null)** with holder = null (in the reparent part) in `Ball.gd`
* [ ] Multiple call in Area2D when reparenting node https://github.com/godotengine/godot/issues/14578. This results in crashing when ball enters pipe and player just release it near the pipe.

### Visual issues
* [x] Jitter animation when passing from a transition_in to transition_out using **rooms**.
* [x] **ColorRect** for shockwave effect stay in (0,0) global coordinates...
* [x] **ColorRect** for shockwave effect combine with `canvas_modulate` results in weird color rectangle.
* [x] To many trails results in crash.
* [ ] The `shoot_previewer` shows a trajectory slightly above the real one.
* [ ] `Z_as_relative` doesn't work through script... https://github.com/godotengine/godot/issues/45416
* [ ] **Bubble/Zap ball teleportation** trailhandler can act very weirdly if used quickly repeatly.
* [ ] **Effects** that are displayed outside the window are displayed after when they reenter the window.
* [ ] **shooting** just before **landing** results in `floor_shoot` just after `aim_shoot` animation
* [ ] There is some jitter animation when passing from a **dunkjump** state to a **grind** state.
* [ ] There is some jitter animation when passing from a **dunk** state to a **hang** state.
* [ ] **Trails** _on_Decay_tween_all_completed never called when **Ball** get reparented during the decay.

### Potential Glitches
* [ ] Pressing **jump** and **dunkdash** just before landing can result in small dunkdash/jump.
* [ ] **Jumping** (from ground) just before entering a **rail** can result in a boost grind.
* [ ] **Dunkdashing** just before entering a **rail** can result in a dash boost grind.
* [ ] **Dunkjump** through a **one way platform** resets the dash.
* [ ] Up-**Dunkdash** just after a **Jump** or a **ShockJump** results in high **Dunkdash**.

### Godot Issues
* in `Ball.gd` function `change_holder` : issue related to https://github.com/godotengine/godot/issues/14578 and https://github.com/godotengine/godot/issues/34207

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
