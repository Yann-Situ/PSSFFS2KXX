# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----

## Specific big parts
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
   - [ ] other characters/npc
   - [ ] adinkra symbols
* Moveset improvment :
   - [x] add dunk
   - [x] handle crouch
   - [x] add landing anim
   - [x] add turn back anim
   - [x] improve wall jump (feet must be on wall ?)
   - :pushpin: add slide
   - [ ] with and without balls anim
   - [ ] add multiple shoot types
   - [ ] Death and life system
* Interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [x] baskets
   - [x] spawners
   - [x] activable
   - [x] Add destroyable blocks
   - :pushpin: ziplines -> to rework
   - :pushpin: Add enemies and NPC
   - :pushpin: Add one way platforms and ball-doors / player-doors
   - :pushpin: pipes (TODO : change bounding box + handle multiple sides + be careful on exit_throw)
   - [ ] moving platform (tilemap + pathfollow2D?)
   - [ ] collectibles (spray?)
* NPCs
   - interactive npc
   - pedestrian generator
   - bosses
   - ennemies
* Style system (optional)
   - [ ] UI for combos
   - [ ] Combo and point system
   - [ ] Reward ('succès') for special style achievements
* Improve shooter
   - :pushpin: Auto aim on baskets
   - [ ] finalize shoot system (test with time stop/slow)
* Balls :
   - [x] add several balls (bouncy ball, fire ball, linked ball, phantom ball)
   - :pushpin: handle interactions with environment elements
   - :pushpin: Add new powers when selection+active (such as megaBOUM, dash, RollingDestroying...)
   - [ ] improve animation of balls
   - [ ] squish anim for squish balls
* Juice :
   - [x] Camera shake on heavy ball, dunks and other style action
   - [x] particles on balls, dust on footsteps & slide
   - [ ] add UBER mode with new animations
* Sound design
   - [ ] add sounds
   - [ ] add musics
   - [ ] handle music variations
* Add UIs
   - [ ] Add HUD
   - [ ] Add menus
   - [ ] Add WorldMap and level selection
   - [ ] Add dialogue system

### Code structure to implement / TODO
* `Selector` is currently a child of `Player/Actions` and is reparent by code to be a child of `Room`. Maybe it should be a child of the room or the level, and accessed in `SpecialActionHandler` via a NodePath or through signals.
* Implement Explosion nodes.
* Rework Aiming system (better physics + time stop + 2 steps shoot).
* Rework Dunkdash target graphism.
* Implement Pedestrian generator (pnj shader, gradient sampler, ...).

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
* [x] **dunking** can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* [x] Hard to reproduce (see video) : **dunkjump** on **jumper** can result in `Nan` camera position teleportation. (because to low to mathematically dunkjump => negative value ? division by 0.0 ?)
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [ ] **release** ball when **aiming** results in error.
* [ ] It is possible to **dunk** through walls. It can result in dunkjump particles (+ghost) emmiting (dont know why).
* [ ] Infinite **walking** animation on 16px block stairs.
* [ ] High jump when `jump_jp` and `jump_jr` just before landing (because the cancelled mounting only test `jump_jr`). (also on walljumps)
* [ ] **one-way platform** make player crouch due to raycast mecanik.
* [ ] **one-way platform** make player unable to do small jumps.
* [ ] Pressing **dunkdash** at a precise moment during **dunk** animation results in **dunkdashing** on place.

### Dynamic items
* [ ] **Zipline** drop inside collision places results in stucked player.
* [ ] Get out from **zipline** just after passing over a **Jumper** results in sliding (like on ice) because **can_go_timer** was changed.
* [ ] (?) Stuck colliding on a **rail** can result in building speed. [need tests]
* [ ] Entering **Pipe** at perfect frame when disabling the **Pipe** can result in a disabled ball floating in the air. -> don't stop the tween to enter the pipe when disabling the pipe. [Hard to reproduce, it happened once]


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
* [x] **portals** : multiple portal_transition due to a late reset position, when changing rooms... see this [issue](https://godotengine.org/qa/9761/area2d-triggered-more-time-when-player-node-previous-scene) and this [issue](https://github.com/godotengine/godot/issues/14578).
* [x] Changing **room** holding a **ball** results in leaving the ball in the previous room.
* [x] The game seems to crash when calling **change_holder(null)** with holder = null (in the reparent part) in `Ball.gd`. (see this [issue](https://github.com/godotengine/godot/issues/14578)). See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* [x] Multiple call in Area2D when reparenting node (see this [issue](https://github.com/godotengine/godot/issues/14578)). This results in crashing when ball enters pipe and player just release it near the pipe. See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* [x] Using the power of a selected ball that died results in error. => I reworked the selection system.
* [x] If multiple explosion breaks the same bloc, it can spawn copies.
* [x] Lag if too much balls : make a spawner limit and link the dispawn of a ball to the spawner to increase the spawn count.
* [ ] Energy loss of `constant_energy_balls`.
* [ ] I need to adapt the boum delay: i.e apply_impulse instantly on colliding object and a bit after on far objects. need a method call_after_a_delay(apply_impulse)
* :pushpin: Need to implement Tilemap interactive objects rotation and flips.
* [ ] On **baskets**, a ball that bounces on the ring can do multiple goals.

### Visual issues
* [x] Jitter animation when passing from a transition_in to transition_out using **rooms**.
* [x] **ColorRect** for shockwave effect stay in (0,0) global coordinates...
* [x] **ColorRect** for shockwave effect combine with `canvas_modulate` results in weird color rectangle.
* [x] To many trails results in crash.
* [x] **Trails** _on_Decay_tween_all_completed never called when **Ball** get reparented during the decay. Workaround by adding child to current_room instead of ball.
* [x] **Bubble/Zap ball teleportation** trailhandler can act very weirdly if used quickly repeatly.
* [x] **Player** catching ball while inside **BallWall** results in stuck player. [Maybe disable the player catch area while inside ballwall?]
* [x] The `shoot_previewer` shows a trajectory slightly above the real one.
* [ ] **Effects** **Particles** that are displayed outside the window are displayed after when they reenter the window.
* [ ] **shooting** just before **landing** results in `floor_shoot` just after `aim_shoot` animation
* [ ] There is some jitter animation when passing from a **dunkjump** state to a **grind** state.
* [ ] There is some jitter animation when passing from a **dunk** state to a **hang** state.
* [ ] **Trail** lifetime and point_lifetime not set correctly when trail for **bubble_ball**.

### Potential Glitches
* [ ] Pressing **jump** and **dunkdash** just before landing can result in small dunkdash/jump.
* [ ] **Jumping** (from ground) just before entering a **rail** can result in a boost grind.
* [ ] **Dunkdashing** just before entering a **rail** can result in a dash boost grind.
* [ ] **Dunkjump** through a **one way platform** resets the dash.
* [ ] Up-**Dunkdash** just after a **Jump** or a **ShockJump** results in high **Dunkdash**.
* [ ] **Dunkjump** with pressing jump_button while pre-dunkjumping can result in high or low dunkjump.
* [ ] At the connection between a **rail** and a solid block, if the character is falling such that they will wallslide on the block if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 initial speed.
    - At the connection between a **rail** and stairs, if the character is falling such that they will go on the slope if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 speed in the direction down the stairs.
* [ ] Player changing **Room** while in a **BallWall** results in player not able to pickup ball. (If glitch, we need to make sure portals are away from ballwall).

### Godot Issues
* in `Ball.gd` function `change_holder` : issue related to https://github.com/godotengine/godot/issues/14578 and https://github.com/godotengine/godot/issues/34207. See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* `Z_as_relative` doesn't work through script... see this [issue](https://github.com/godotengine/godot/issues/45416).
