# PSSFFS2KXX
Popol Super Slam Fusion Full Speed 2KXX
-----
## License ?
No open-source license provided yet (see [this link](https://choosealicense.com/no-permission/)).
This repository is for private use only. An open-source license will probably be released in the future.
Copyright (c) 2023 Yann-Situ

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
* HUD
* story

### Code structure to (re)implement
* [ ] `Selector` is currently a child of `Player/Actions` and is reparent by code to be a child of `Room`. Maybe it should be a child of the room or the level, and accessed in `SpecialActionHandler` via a NodePath or through signals.
* [x] Implement Explosion nodes.
* [ ] Rework Aiming system (better physics + time stop + 2 steps shoot).
* [ ] Rework Dunkdash target graphism.
* [ ] Rework Rails
* [ ] Rework Ziplines.
* [x] Implement Pedestrian generator (pnj shader, gradient sampler, ...).
* [ ] GUI Graphism

### Godot4 migration

List of things to do
- [ ] physics problem with grind
- :pushpin: dunk player position
- :pushpin: hang player position
- [ ] double dash make the player stuck
- [ ] state machines have memory now... (we need to restart the state machine when reentering it)
- :pushpin: S.velocity is set to Vec2(0.0) every frame when animation_tree is active (really weird bug) [currently a temporary solution]
- [x] ball rework (currently a rigidbody implementation but there are physics annoying bugs https://github.com/godotengine/godot/issues/76610) (Solved using [GodotTilemapBaker](https://github.com/popcar2/GodotTilemapBaker/tree/main))
- [x] player_friction and forces using Alterable
- [ ] catch and ball release
- :pushpin: tileset/map rework
- [ ] Improve TileMapBaker to take into account different physical layer, for example ballwall and playerwall

Pull request to master when **ball physics** and **player animations** will be correctly handled.

## Work to do
* Graphism :
   - :pushpin: environment elements
   - :pushpin: other tilesets
   - :pushpin: other background
   - :pushpin: all movement sprites
   - [ ] GUI graphism such as tag-police
   - :pushpin: other characters/npc
   - [ ] adinkra symbols
* Moveset improvment:
   - [x] add dunk
   - [x] handle crouch
   - [x] add landing anim
   - [x] add turn back anim
   - [x] improve wall jump (feet must be on wall ?)
   - [x] add slide
   - [ ] with and without balls anim
   - [ ] add multiple shoot types
   - [ ] Death and life system
* Interactive elements (baskets, pipes, jumping platform, doors and warps, wind, enemies...)
   - [x] baskets
   - [x] spawners
   - [x] activable
   - [x] destroyable blocks
   - [x] ball-doors / player-doors
   - :pushpin: ziplines -> to rework
   - :pushpin: Add enemies and NPC
   - :pushpin: Add one way platforms
   - :pushpin: pipes -> rework a bit (TODO: change bounding box + handle multiple sides + be careful on exit_throw)
   - :pushpin: moving platform (tilemap + pathfollow2D?) (Wait4Godot)
   - [x] collectibles (spray?)
* NPCs
   - [x] pedestrian generator
   - [ ] interactive npc
   - [ ] bosses
   - [ ] ennemies
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
   - [ ] add some juice and more effects
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
   - :pushpin: Add HUD
   - [ ] Add menus
   - [ ] Add WorldMap and level selection
   - [ ] Add dialogue system

## Issues
### Actions and Movement
* [x] Weird straight **jump** on a corner. Don't know why it happens and what to do.
* [x] Sometimes the **dunkjump** gives a velocity of `(-nan, dunkjump_speed)`. This is due to it's calculation with a square root
* [x] **Dunking** while pushing a direction button toward another basket above results in no dunk on the current basket. -> change the criteria for the basket by taking into account a very close basket.
* [x] **Walljumping** at the same time that dunking results in dunking called on a **wrong basket** (if multiple baskets around)
* [x] **Aiming shooting** right after dunk results in **strange animation behaviour**.
* [x] **Dunking** can result in `S.selected_basket.dunk()` called on `null` instance (basket is not selected anymore)
* [x] **Dunkjump** on **jumper** can result in `Nan` camera position teleportation. (because to low to mathematically dunkjump => negative value ? division by 0.0 ?) [hard to reproduce] (see video) [solved by reimplementing dunkjump?]
* [x] High jump when `jump_jp` and `jump_jr` just before landing (because the **mount-cancel** only test `jump_jr`).
* [x] **ShockJumping** at frame perfect when crouching on **Jumper** (or when jumping or dunkjumping) results in a huge mega jump sa mère.
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [ ] **Dunkjumping** while only moving with floor adherence a bit far from basket results in missing the basket.
* [ ] **Release** ball when **aiming** results in error.
* [ ] It is possible to **dunk** through walls. It can result in *ghost* emmiting (dont know why). [TODO TEST]
* [ ] **One-way platform** make player crouch due to raycast mechanic. This implies weird camera movement.
* [ ] **One-way platform** make player unable to do small jumps. [TODO handle one-way correctly (raycast and CollisionShapes)]
* [ ] Pressing **dunkdash** at a precise moment during **dunk** animation results in **dunkdashing** on place.
* [ ] Pressing **jump** at a precise moment during **dunk** animation results in ungrabing the basket without any jump. [TODO handle correctly the dunk-hang-ungrab loop]
* [ ] **Walljump** by pressing jump before touching wall can result in jump that can't be **mount-cancelled** (by releasing jump button).
* [ ] **Sliding** is not canceled if the button down is released. This results in interesting yet annoying *moonwalks* and weird behaviours. [TODO prioritize rolling over sliding and handle their connection]

### Environment and Items
* [x] Weird behaviour on leaving a **zipline** to a **rail** (there is a moment when the character is on both of them)
    - Implement character holder group with `free_character` and `pickup_character` methods.
* [x] Characters can leave **rail** if Player press **crouch** on it.
    - Implement the `riding` and `hanging` states.
* [ ] A ball that bounces on the ring of a **basket** can do multiple goals.
* [ ] **Zipline** drop inside collision places results in stucked player.
* [ ] Get out from **zipline** just after passing over a **Jumper** results in sliding (like on ice) because **can_go_timer** was changed. [TODO REWORK **Zipline** and **Rails**]
* [ ] Stuck colliding on a **rail** can result in building speed. [TODO TEST]
* [ ] Entering **Pipe** at perfect frame when disabling the **Pipe** can result in a disabled ball floating in the air. -> don't stop the tween to enter the pipe when disabling the pipe. [hard to reproduce, it happened once]
* [ ] Balls can perform too big jumps at the junction of multiple **Jumpers**. This is due to `apply_impulse` not changing immediately the velocity value of a RigidBody2D. This implies applying two times the *jump_impulse*, which is designed to compensate the original velocity and apply the *jump_velocity*. [TODO implement a smart `override_velocity` that cancel and change the *velocity* using impulses, but only the last call before `integrate_force` will have an effect]

### Physics
* [x] TileMap hitboxes (bounce on corners of each tile + balls pass through 2 adjacent tiles). **size up the hitboxes smartly**
* [x] Physic of balls when picked up (stay physically on the ground...). **complicated** see rigidbody functions and how `integrate_force` works.
* :pushpin: Problems with physics on **slopes** [DAMN IT].
* [x] **Player** catching ball while inside **BallWall** results in stuck player. [Maybe disable the player catch area while inside ballwall?]
* [ ] Problems when passing from a block just **16 pixel** over the other block (results in tiny teleportation but visible due to camera instant movement).
* [ ] Jitter when multiple **balls** are above each other (with rigidbodies, physicbodies and situbodies). [TODO TEST].
* [ ] **Ball** located just on a **spawner** position results in very high velocity when spawning a ball on it [hard to reproduce].
* [ ] **Wind** is not affecting Player when **grinding** and **hanging** [TODO implement a smart `move_character(character, velocity)` function for *character_holder* that take the character velocity at each physics process call and move the character according to the holder].
* :pushpin: annoying **Tilemap** physics problems. Partially resolved using [TilemapBaker](https://github.com/popcar2/GodotTilemapBaker) but still some problems at the junction between custom blocks (box, jumpers, ...):
    - tunneling ;
    - tile junction bounce problems. See this [issue](https://github.com/godotengine/godot/issues/76610).
* [ ] **Ballwall** and **PlayerWall** seems broken since Godot4.

### Visual and Animation
* [x] Jitter animation when passing from a transition_in to transition_out using **rooms**.
* [x] **ColorRect** for shockwave effect stay in (0,0) global coordinates...
* [x] **ColorRect** for shockwave effect combine with `canvas_modulate` results in weird color rectangle.
* [x] Get out from **low ceiling** (crouched) when returning can result in infinite returning **animation**.
* [x] To many **trails** results in crash.
* [x] **Trails** _on_Decay_tween_all_completed never called when **Ball** get reparented during the decay. Workaround by adding child to current_room instead of ball.
* [x] **Bubble/Zap ball teleportation** trailhandler can act very weirdly if used quickly repeatly.
* [x] The `shoot_previewer` shows a trajectory slightly above the real one.
* [ ] **Particles** that are displayed outside the window are displayed after when they re-enter the camera (I probably need to investigate the [`visibility_rect` property](https://docs.godotengine.org/it/stable/classes/class_particles2d.html#class-particles2d-property-visibility-rect)).
* [ ] **Shooting** just before **landing** results in `floor_shoot` just after `aim_shoot` animation
* [ ] There is some *jitter animation*:
    - when passing from a **dunkjump** state to a **grind** state.
    - when passing from a **dunk** state to a **hang** state.
    - when passing from a **dunk** state to a **falling** state (by pressing down during dunk). [TODO REWORK **AnimationTree**]
* [ ] **Trail** lifetime and point_lifetime not set correctly when trail for **bubble_ball**.
* [ ] **Player** doesn't stop walking when on floor walls. ([ ] Infinite **walking** animation on 16px block) stairs.

### Other
* [x] Spawner rotation position is weird.
* [x] **Portals** : multiple portal_transition due to a late reset position, when changing rooms... see this [issue](https://godotengine.org/qa/9761/area2d-triggered-more-time-when-player-node-previous-scene) and this [issue](https://github.com/godotengine/godot/issues/14578).
* [x] Changing **room** holding a **ball** results in leaving the ball in the previous room.
* [x] The game seems to crash when calling **change_holder(null)** with holder = null (in the reparent part) in `Ball.gd`. (see this [issue](https://github.com/godotengine/godot/issues/14578)). See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* [x] Multiple call in Area2D when reparenting node (see this [issue](https://github.com/godotengine/godot/issues/14578)). This results in crashing when ball enters pipe and player just release it near the pipe. See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* [x] Using the power of a selected ball that died results in error. => I reworked the selection system.
* [x] If multiple explosion breaks the same bloc, it can spawn copies.
* [x] Lag if too much balls : make a spawner limit and link the dispawn of a ball to the spawner to increase the spawn count.
* [x] I need to adapt the boum delay: i.e apply_impulse instantly on colliding object and a bit after on far objects. need a method call_after_a_delay(apply_impulse) -> see Explosion node implementation
* :pushpin: Need to implement Tilemap interactive objects rotation and flips. [TODO Wait4Godot]
* [ ] **BulletTime** (pause scene) can eat input, currently resulting in dunking after a dunkjump even if the dunk button is not pressed.
* [ ] Releasing ball and changing room can result in the player not able to catch another ball.

### Potential Glitches
* [ ] **Jumping** (from ground) just before entering a **rail** can result in a boost grind.
* [ ] Pressing **jump** and **dunkdash** just before landing can result in small dunkdash/jump.
* [ ] **Dunkdashing** just before entering a **rail** can result in a dash boost grind.
* [ ] Up-**Dunkdash** just after a **Jump** or a **ShockJump** results in high **Dunkdash**.
* [ ] **Dunkjump** through a **one way platform** resets the dash.
* [ ] **Dunkjump** with pressing jump_button while pre-dunkjumping can result in high or low dunkjump.
* [ ] At the connection between a **rail** and a solid block, if the character is falling such that they will wallslide on the block if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 initial speed.
    - At the connection between a **rail** and stairs, if the character is falling such that they will go on the slope if there wasn't a rail, and is falling fast enough, the character will normally grind but with 0 speed in the direction down the stairs.
* [ ] Player changing **Room2D** while in a **BallWall** results in player not able to pickup ball. (If glitch, we need to make sure portals are away from ballwall).
* [ ] **Mirror** weird effect when trying to mirror something out of camera (happen when the mirror takes half of the camera).

### Godot Issues
* in `Ball.gd` function `change_holder`: issue related to https://github.com/godotengine/godot/issues/14578 and https://github.com/godotengine/godot/issues/34207. See [my workaround](https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/).
* `Z_as_relative` doesn't work through script... see this [issue](https://github.com/godotengine/godot/issues/45416).
* Weird bounce and tunneling effect for rigidbodies: https://github.com/godotengine/godot/issues/76610. This is probably the most annoying one, because the workarounds are tedious and hard (recode physics or use tile_baker and hope it works).

## Memories

`class_name\s*(\w*),` -> `class_name $1 #,`
`@export\b\s*\((\w*)\)\s*var\s*(\w*)` -> `@export var $2 : $1`
`@export_range\((\w*),\s*((\d|\.)*),\s*((\d|\.)*)\)\s*var\s*(\w*)` -> `@export_range($2,$4) var $6 : $1`
`emit_signal\("(\w*)"\)` -> `$1.emit()`
`emit_signal\("(\w*),\s*(.*)"\)` -> `$1.emit($2)`
`(\w*\.)*connect\("(\w*)",Callable\(self,"(\w*)"\)\)` -> `$1$2.connect(self.$3)`
`start\(Callable\((.*?)\)\.bind\((.*?)\)` -> `start($1, $2`
`start\(Callable\((.*?)\)` -> `start($1`
`^\s*set\s\=\s*(\w*)\s*\#(.*?\#)*\s*\((\w*),(.*?)\)`
