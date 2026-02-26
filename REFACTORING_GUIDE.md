# AudioGame Refactoring Guide

This document walks through your entire codebase, explains the problems, proposes
a new architecture, and guides you through implementing it step by step.

Each section ends with questions for you to think about. If something is unclear,
send me the file you are working on and ask freely.

---

## Part 1: What We Will Change and Why

### 1.1 Your Current Class Tree

```
Node3D
├── RayCast                        # Audio ray engine (236 lines)
│   └── Speaker                    # Extends RayCast directly
│
└── PickableObject                 # Pick/place in 3D world
    ├── AudioReflector             # Bounces rays
    ├── AudioCatcher               # Catches rays (endpoint)
    └── AudioManipulator           # Has a CHILD RayCast node
        ├── AudioSeparator         # Filters notes by mask
        ├── AudioMixer             # Merges notes from multiple sources
        └── AudioRetranslator      # Pass-through (empty class)
```

There is a fundamental design inconsistency here. Look at it carefully:

- **AudioManipulator** HAS-A RayCast (composition — good)
- **Speaker** IS-A RayCast (inheritance — questionable)

Speaker extends RayCast, meaning Speaker *is* a raycast engine. But is it really?
A speaker is a game object that *uses* raycasting to emit sound. It sits on the
ground, gets picked up by the player, gets placed down. That sounds a lot like a
PickableObject with a RayCast child — exactly the pattern AudioManipulator uses.

But because Speaker inherits from RayCast, it cannot also inherit from
PickableObject. It misses pick/place logic. Yet your `speaker.tscn` already has
`AreaPick` and `AreaPlace` nodes sitting unused.

**The core question:** Is Speaker fundamentally a *ray engine*, or is it a
*game object that emits sound*?

### 1.2 The set_chord / activate Confusion

Right now, three different things can happen when a chord moves through the system:

| Action | What it does | Who calls it |
|---|---|---|
| `set_chord(chord)` | Store the chord AND maybe activate | RayCast hit detection |
| `activate()` | Start transmitting AND maybe transform the chord first | RayCast hit detection, also set_chord internally |
| Updating the mask UI | Calls activate() again | Signal from InteractionMenu |

The problem: `set_chord()` and `activate()` both can trigger each other. In
`raycast.gd:119-121`:

```gdscript
func _activate_current_hit(current_hit: Node3D) -> void:
    current_hit.set_chord(_chord)    # This might call activate() inside
    current_hit.activate()            # This ALWAYS calls activate() again
```

So if the target's raycast `is_active == true`, the chord gets processed twice.

Also, every subclass handles `set_chord()` differently:

```
AudioManipulator.set_chord()  → just forwards to _ray_cast (no local storage)
AudioSeparator.set_chord()    → stores locally, does NOT call super
AudioMixer.set_chord()        → merges into _chord, calls super with WRONG chord
AudioRetranslator.set_chord() → just calls super (does nothing useful)
```

**Think about this:** What should `set_chord()` mean? What should `activate()`
mean? Can you define each in one sentence without using the word "and"?

### 1.3 The Proposed New Class Tree

```
PickableObject                       # All game objects the player interacts with
│
├── AudioEmitter                     # NEW: anything that emits sound rays
│   │   has: RayCast (child node)
│   │   has: _chord (the chord to emit)
│   │   does: set_chord(), activate(), deactivate()
│   │
│   ├── Speaker                      # Source of original chord
│   │   just: loads its chord in _ready, activates itself
│   │
│   └── AudioProcessor               # RENAMED from AudioManipulator
│       │   adds: receives chord from upstream, transforms it
│       │   has: _input_chord, virtual _process_chord()
│       │
│       ├── AudioSeparator           # Masks notes based on UI
│       ├── AudioMixer               # Merges notes from multiple sources
│       └── (AudioRetranslator)      # DELETED — see below
│
├── AudioReflector                   # Bounces rays, no processing
└── AudioCatcher                     # Endpoint, visual feedback
```

Key changes:

1. **AudioEmitter** — new shared base for Speaker and Processor. Both have a
   RayCast child and a chord to transmit. This eliminates the
   "Speaker IS-A RayCast" problem.

2. **AudioProcessor** replaces AudioManipulator. The name says what it does:
   it *processes* audio (transforms a chord). "Manipulator" is vague.

3. **AudioRetranslator is deleted.** A processor that does nothing is just an
   emitter. If you need a pass-through, an AudioEmitter already does that —
   it takes a chord and re-emits it unchanged.

4. **Clear method contract:**
   - `set_chord(chord)` → store input. Never activates. Never transforms.
   - `activate()` → process chord (if processor), then start emitting.
   - `deactivate()` → stop emitting.
   - `update_output()` → reprocess + retransmit (for live UI changes).

**Question for you:** AudioRetranslator currently just calls `super` for every
method. If we have AudioEmitter as a base, do you still need a separate
Retranslator class? What would a "retranslator" do that an emitter doesn't?

### 1.4 Summary of All Changes

| What | Change | Why |
|---|---|---|
| Speaker | No longer extends RayCast, extends new AudioEmitter | Composition over inheritance |
| AudioManipulator | Renamed to AudioProcessor, extends AudioEmitter | Better name, shared base with Speaker |
| AudioRetranslator | Deleted | Empty class; AudioEmitter already does this |
| RayCast | Remove `set_chord` auto-activation | Prevents double-activate bug |
| AudioMixer.set_chord | Fix: forward merged chord, not input chord | Bug fix |
| chord_mask_menu.gd | Fix duplicate node ref, simplify toggle functions | Bug fix + readability |
| Chord + LibNote | Merge into one class | Duplicate code |
| Naming | See Section 3 for full list | GDScript style + clarity |

---

## Part 2: How the Code Will Work

### 2.1 The New Chord Flow

Here is how a chord travels from Speaker to AudioCatcher in the new design.
Read this carefully — it is the "heartbeat" of your game.

```
PHASE 1: Speaker Emits
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Speaker._ready()
  │  speaker loads chord resource
  │  chord.make_notes()  ← loads audio files
  │  set_chord(chord)    ← stores in _chord (inherited from AudioEmitter)
  │  activate()          ← tells RayCast child to start casting
  ▼
RayCast._physics_process()
  │  casts ray every frame
  │  ray hits something...


PHASE 2: Ray Hits an Object
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RayCast detects collision
  │
  ├─ Hit AudioReflector?
  │    → bounce ray, continue casting
  │
  ├─ Hit AudioProcessor (Separator, Mixer)?
  │    → processor.receive_chord(_chord)     # NEW name
  │    → processor.activate()
  │
  └─ Hit AudioCatcher?
       → catcher.activate()


PHASE 3: Processor Handles Chord
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AudioProcessor.receive_chord(chord)
  │  _input_chord = chord
  │  (just stores — no side effects)
  ▼
AudioProcessor.activate()
  │  _output_chord = _process_chord(_input_chord)   # virtual method
  │  set_chord(_output_chord)                        # AudioEmitter stores it
  │  _ray_cast.activate()                            # Start re-emitting
  ▼
  Downstream RayCast starts casting → cycle continues


PHASE 4: Live UI Update (Separator Only)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
User toggles checkbox
  │  signal: string_selection_changed(mask)
  ▼
AudioSeparator._on_selection_changed(mask)
  │  _string_enabled = mask
  │  update_output()
  ▼
AudioProcessor.update_output()
  │  if not _ray_cast.is_active: return      # Only if already active
  │  _output_chord = _process_chord(_input_chord)
  │  set_chord(_output_chord)
  │  (raycast is already running, it picks up new chord next frame)
```

### 2.2 Method Contracts (The Rules)

These are the rules every class must follow. If you find a case where a class
needs to break a rule, that is a design problem — fix the design, not the rule.

```
set_chord(chord: Chord) → void
  DOES:    Store the chord that this emitter will transmit
  DOES NOT: Call activate(). Call process. Emit signals.
  WHO CALLS: Speaker calls on itself. RayCast calls on hit targets.

activate() → void
  DOES:    Start emitting. For processors: transform chord first.
  DOES NOT: Get called from inside set_chord().
  WHO CALLS: External only. Speaker on itself. RayCast on hit targets.

deactivate(emitter: Node3D) → void
  DOES:    Stop emitting. Clean up audio players.
  WHO CALLS: RayCast when ray path changes.

receive_chord(chord: Chord) → void        [AudioProcessor only]
  DOES:    Store the INPUT chord (before transformation).
  DOES NOT: Transform. Activate. Forward.
  WHO CALLS: Upstream RayCast when it hits this processor.

update_output() → void                    [AudioProcessor only]
  DOES:    Reprocess input chord and update output. For live UI changes.
  DOES NOT: Start a new activation cycle.
  PRECONDITION: Raycast must already be active.
  WHO CALLS: UI signal handlers (e.g., mask changed).
```

**Question for you:** Why is `receive_chord()` separate from `set_chord()`?
Think about what `set_chord()` means for an AudioEmitter (the chord it *outputs*)
vs what `receive_chord()` means for an AudioProcessor (the chord it *receives as input*).

### 2.3 Node Communication Map

```
┌─────────────────────────────────────────────────────────────┐
│  HOW NODES TALK TO EACH OTHER                               │
│                                                             │
│  ──────── = method call (direct)                            │
│  - - - -  = signal (decoupled)                              │
│                                                             │
│                                                             │
│  Speaker                                                    │
│    │                                                        │
│    │ owns                                                   │
│    ▼                                                        │
│  RayCast ────────────────► AudioProcessor                   │
│    │     set_chord()          │                              │
│    │     activate()           │ owns                        │
│    │                          ▼                              │
│    │                        RayCast ──────► AudioCatcher     │
│    │                          │       activate()             │
│    │                          │                              │
│    │                          │                              │
│    ▼                          ▼                              │
│  AudioPlayer              AudioPlayer                       │
│  (plays chord              (plays chord                     │
│   near player)              near player)                    │
│                                                             │
│                                                             │
│  InteractionMenu - - - - - ► AudioSeparator                 │
│         signal:                  _on_selection_changed()     │
│         string_selection_changed                             │
│                                                             │
│                                                             │
│  Player ──────────────────► InteractionObject                │
│          _interact()            enter() / leave()            │
│                                                             │
│  Player ──────────────────► PickableObject                   │
│          _object_pick()         pick() / place()             │
└─────────────────────────────────────────────────────────────┘
```

Notice: All communication goes in ONE direction. RayCast pushes chords
downstream. Signals go from UI to game objects. Player calls methods on objects.
Nothing calls back upstream. This is good — keep this pattern.

### 2.4 What Changes Inside RayCast

The RayCast class stays mostly the same. Two key changes:

**Change 1:** `set_chord()` no longer auto-activates.

```gdscript
# BEFORE (current):
func set_chord(new_chord: Chord) -> void:
    _chord = new_chord
    if is_active: activate()      # ← This causes double activation

# AFTER (new):
func set_chord(new_chord: Chord) -> void:
    _chord = new_chord
    # That's it. Caller decides when to activate.
```

**Change 2:** `_activate_current_hit` sends chord to processors differently.

```gdscript
# BEFORE (current):
func _activate_current_hit(current_hit: Node3D) -> void:
    current_hit.set_chord(_chord)
    current_hit.activate()

# AFTER (new):
func _activate_current_hit(current_hit: Node3D) -> void:
    if current_hit is AudioProcessor:
        current_hit.receive_chord(_chord)
    elif current_hit is AudioCatcher:
        pass    # Catcher doesn't need a chord
    current_hit.activate()
```

**Question for you:** Why do we check `if current_hit is AudioProcessor` instead
of just calling `set_chord()` on everything? What would go wrong if AudioCatcher
received a `set_chord()` call?

---

## Part 3: Implementation Step by Step

### Step 0: Housekeeping — Bugs and Typos

Before we restructure anything, fix these small things. They are independent of
the architecture and will only cause confusion if left around.

#### 0.1 Fix the Duplicate Node Reference

File: `source/ui/interaction_menu/chord_mask_menu.gd`, line 12

```gdscript
# CURRENT (bug):
@onready var _s2: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var _s1: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
                                                                                 ^^^^^^^^^^^^^^
# Both point to HBoxContainer2. What should _s1 point to?
```

Open `chord_mask_menu.tscn` in the editor, check the actual node name for
string 1, and fix it.

#### 0.2 Fix the Filename Typo

File: `source/objects/tools/interaction_object/interaction_oject.gd`

The file is named `interaction_oject.gd` (missing 'b'). Rename it to
`interaction_object.gd`. Make sure to update the `.tscn` that references it.

#### 0.3 Fix the Constant Typo

File: `source/objects/tools/raycast.gd`, line 7

```gdscript
# CURRENT:
const AUDIO_PLAYER_OFFST_FROM_PLAYER: float = 1.0
# FIX:
const AUDIO_PLAYER_OFFSET_FROM_PLAYER: float = 1.0
```

This constant is currently unused, but fix it now so it doesn't confuse you later.

#### 0.4 Remove Duplicate Code: LibNote

File: `source/sounds/lib_note.gd`

Compare `LibNote.get_audio_stream()` with `Chord.get_audio_stream()`. They are
identical, line for line. The `speaker.tscn` still references LibNote as a
sub-resource, but the code doesn't use it — Chord has its own copy.

**Task:** Delete `lib_note.gd`. Remove the LibNote sub-resource from
`speaker.tscn` (re-save the speaker scene in the editor after removing).

---

### Step 1: GDScript Style and Naming

Before restructuring classes, let's align with GDScript conventions. This makes
the code easier to read, and you will learn patterns you can apply everywhere.

#### 1.1 class_name and extends Order

GDScript convention: `class_name` goes FIRST, then `extends`.

```gdscript
# Current (mixed styles across your files):
extends Resource          # chord.gd — extends first
class_name Chord

extends PickableObject    # audio_reflector.gd — extends first
class_name AudioReflector

class_name InteractionMenu  # chord_mask_menu.gd — class_name first
extends Control
```

**Rule:** Always put the class identity first, then what it inherits from.

```gdscript
class_name Chord
extends Resource
```

This reads naturally: "This IS a Chord, it EXTENDS Resource."

Go through every `.gd` file and make the order consistent.

#### 1.2 Variable Naming

Your naming is mostly good, but there are a few improvements:

| Current Name | Problem | Suggested Name |
|---|---|---|
| `_chord_mask` (separator) | "mask" is ambiguous — does true mean masked or unmasked? | `_string_enabled` |
| `_chord_mask` (menu) | Same ambiguity | `_string_selection` |
| `send_chord_mask` (signal) | Doesn't describe what happened | `string_selection_changed` |
| `speaker_chord` | Redundant — it's on a Speaker, we know it's a speaker's chord | `chord` |
| `_audio_stream` (raycast) | Singular name for something that gets overwritten in a loop | Remove (use local var) |
| `_is_picked` (object.gd) | Fine, but `is_held` matches the game action better | `_is_held` |
| `_collider` (player.gd) | Vague — collider of what? | `_held_object` |
| `LERP_SPEED` | Not a speed, it's a blend weight (0 to 1) | `FOLLOW_WEIGHT` |
| `LERP_ANGLE_SPEED` | Same | `ROTATION_WEIGHT` |

**Exercise:** For each rename, ask yourself: "If I read this name six months from
now with no context, would I know what it does?" If not, rename it.

#### 1.3 Redundant Ternary Operators

File: `chord_mask_menu.gd`, lines 33-60

```gdscript
# CURRENT:
_chord_mask[0] = true if toggled_on else false

# This is the same as:
_chord_mask[0] = toggled_on
```

`true if x else false` is always just `x` when `x` is already a bool.

#### 1.4 Accessing Private Members from Outside

File: `main.gd`, lines 44, 51

```gdscript
_player._leave()                              # line 44
_player._player_state = Player.PlayerState.FREE   # line 51
```

The underscore prefix `_` means "private — don't touch from outside." But
`main.gd` directly accesses `_leave()` and sets `_player_state`.

**Think about this:** If main.gd needs to tell the player to pause and unpause,
what public methods should Player provide? The player should control its own
state. Main should just say "pause yourself" or "unpause yourself."

A hint:

```gdscript
# In Player:
func pause() -> void:
    _player_state = PlayerState.PAUSE
    _leave()

func unpause() -> void:
    _player_state = PlayerState.FREE
```

Now `main.gd` calls `_player.pause()` and `_player.unpause()`. Clean.

#### 1.5 The Repetitive Toggle Functions

File: `chord_mask_menu.gd`, lines 33-60

You have six identical functions:

```gdscript
func _on_s6_toggled(toggled_on: bool) -> void:
    _chord_mask[0] = toggled_on
    _send_chord_mask()

func _on_s5_toggled(toggled_on: bool) -> void:
    _chord_mask[1] = toggled_on
    _send_chord_mask()

# ... four more
```

**Exercise:** Can you write ONE function that replaces all six? The function needs
to know which string index to update. Look up `Callable.bind()` in Godot docs —
it lets you attach extra arguments when connecting signals.

Sketch (fill in the blanks):

```gdscript
func _ready() -> void:
    leave()
    for i in 6:
        _string_selection.append(false)
        # How would you connect each checkbox's "toggled" signal
        # to a single _on_string_toggled function, passing `i`?

func _on_string_toggled(toggled_on: bool, string_index: int) -> void:
    _string_selection[string_index] = toggled_on
    string_selection_changed.emit(_string_selection)
```

If you connect signals in code, you can remove the six `@onready` node references
and the six callback functions. But you will need to get the checkboxes
programmatically. Think about how you would find them in the node tree.

---

### Step 2: Create AudioEmitter Base Class

This is the biggest structural change. Take your time.

#### 2.1 What AudioEmitter Does

AudioEmitter is a PickableObject that has a RayCast child and a chord to transmit.
Both Speaker and AudioProcessor will extend it.

```gdscript
# source/objects/abstract_classes/audio_emitter.gd

class_name AudioEmitter
extends PickableObject

## Base class for objects that emit sound via raycasting.
## Provides chord storage and RayCast management.

var _chord: Chord
var _ray_cast: RayCast


func _ready() -> void:
    super()
    _ray_cast = get_node("RayCast")
    deactivate(null)


func set_chord(new_chord: Chord) -> void:
    _chord = new_chord
    # NOTE: Does NOT activate. Caller decides when to activate.


func activate() -> void:
    _ray_cast.set_chord(_chord)
    _ray_cast.activate()


func deactivate(emitter: Node3D) -> void:
    _ray_cast.deactivate(emitter)
```

**Question:** Look at the current `AudioManipulator.set_chord()`:

```gdscript
func set_chord(new_chord: Chord) -> void:
    _ray_cast.set_chord(new_chord)
```

It forwards the chord to the raycast immediately. In the new design,
`set_chord()` only stores the chord. The raycast gets it during `activate()`.

Why is this better? Think about what happens if `set_chord()` is called three
times before `activate()`. In the old design, the raycast gets updated three
times. In the new design, it only gets the final value when it actually needs it.

#### 2.2 Rewrite Speaker

Speaker becomes simple:

```gdscript
# source/objects/speaker/speaker.gd

class_name Speaker
extends AudioEmitter

@export var chord: Chord


func _ready() -> void:
    super()
    chord.make_notes()
    set_chord(chord)
    activate()
```

That's it. Speaker is a PickableObject (can be picked up and placed), has a
RayCast child (inherited from AudioEmitter), loads a chord, and starts emitting.

Compare this to the current Speaker (12 lines extending RayCast, missing
pick/place). The new Speaker is cleaner AND more capable.

**But wait** — the current RayCast class has `_physics_process` which does the
raycasting. Speaker currently inherits this because it extends RayCast. In the
new design, RayCast is a child node, so `_physics_process` runs on the child.
This already works for AudioManipulator, so it will work for Speaker too.

#### 2.3 Create AudioProcessor

This replaces AudioManipulator:

```gdscript
# source/objects/abstract_classes/audio_processor.gd

class_name AudioProcessor
extends AudioEmitter

## Base class for objects that receive a chord, transform it,
## and re-emit the result.

var _input_chord: Chord


func receive_chord(new_chord: Chord) -> void:
    _input_chord = new_chord


func activate() -> void:
    var output := _process_chord(_input_chord)
    set_chord(output)         # Store the transformed chord
    super.activate()          # Tell RayCast to emit it


func update_output() -> void:
    if not _ray_cast.is_active:
        return
    var output := _process_chord(_input_chord)
    set_chord(output)
    # RayCast is already running — it will pick up the new chord.
    # We need to tell it about the new chord though:
    _ray_cast.set_chord(_chord)


## Override this in subclasses to transform the chord.
## Default: pass through unchanged.
func _process_chord(input: Chord) -> Chord:
    return input
```

**Question for you:** Look at `update_output()`. It calls
`_ray_cast.set_chord(_chord)` at the end. Why is this necessary when `set_chord()`
already stores the chord on the emitter? Remember that the RayCast is a separate
node with its own `_chord` variable. When does the RayCast's copy get updated?

Think about two scenarios:
1. First activation: `activate()` → `super.activate()` → `_ray_cast.set_chord()` + `_ray_cast.activate()`
2. Live update: `update_output()` → need to push new chord to already-running raycast

#### 2.4 Rewrite AudioSeparator

```gdscript
class_name AudioSeparator
extends AudioProcessor

var _string_enabled: Array[bool] = []


func _ready() -> void:
    super()
    var interaction_menu := get_node("InteractionObject").interaction_menu
    interaction_menu.string_selection_changed.connect(_on_selection_changed)
    for i in 6:
        _string_enabled.append(false)


func _process_chord(input: Chord) -> Chord:
    # EXERCISE: Fill this in.
    # You need to:
    #   1. Create a copy of the input chord (use duplicate())
    #   2. Copy the notes array (why? think about references vs values)
    #   3. For each string: if _string_enabled[i] is false, set note to null
    #   4. Return the new chord
    pass


func _on_selection_changed(new_selection: Array[bool]) -> void:
    _string_enabled = new_selection
    update_output()
```

**Exercise:** Implement `_process_chord()`. Think about why we duplicate the
chord instead of modifying the original. What would happen if two processors
shared the same chord object and one modified it?

#### 2.5 Rewrite AudioMixer

The current mixer has a bug — it appends notes into `_chord` but then calls
`super.set_chord(new_chord)`, forwarding the original input instead of the
merged result.

```gdscript
class_name AudioMixer
extends AudioProcessor

var _accumulated_chord: Chord


func receive_chord(new_chord: Chord) -> void:
    super.receive_chord(new_chord)
    # Mixer accumulates chords from multiple sources.
    # Each call to receive_chord adds notes to the accumulated chord.


func _process_chord(input: Chord) -> Chord:
    # EXERCISE: Think about this carefully.
    #
    # The mixer receives chords from MULTIPLE upstream raycasts.
    # Each one calls receive_chord() with different notes.
    #
    # Questions to consider:
    #   1. When should _accumulated_chord be reset?
    #      (Hint: what happens when an upstream source deactivates?)
    #   2. What if two sources provide a note for the same string?
    #      (Current code calls this a "collision" — is that right?)
    #   3. Should _process_chord merge, or should receive_chord merge?
    #
    # This is the hardest piece of the redesign. Don't rush it.
    pass


func deactivate(emitter: Node3D) -> void:
    # When an upstream source goes away, we need to remove
    # its notes from the accumulated chord.
    # EXERCISE: How would you track which notes came from which source?
    super.deactivate(emitter)
```

**Hard question:** The mixer receives chords from multiple sources. But
`_process_chord()` only takes one input. This is a hint that the mixer might need
a different internal model — maybe a dictionary mapping source → chord, and
`_process_chord` merges all of them. How would you design this?

#### 2.6 Delete AudioRetranslator

Look at the current code:

```gdscript
class_name AudioRetranslator
extends AudioManipulator

func _ready() -> void:
    super()

func activate() -> void:
    super.activate()

func deactivate(emitter: Node3D) -> void:
    super.deactivate(emitter)

func set_chord(new_chord: Chord) -> void:
    super.set_chord(new_chord)
```

Every method just calls `super`. This class does nothing. In the new design,
`AudioProcessor._process_chord()` already returns the input unchanged by default.
So any AudioProcessor with no override IS a retranslator.

If you still want a distinct "retranslator" scene (for a different mesh or
behavior), you can make it an AudioProcessor with no overrides — but you don't
need a separate script file.

**Think about it:** When is it OK to have an empty subclass? When does it become
unnecessary boilerplate?

---

### Step 3: Fix the RayCast Hit Detection

#### 3.1 The _handle_ray_hit Problem

Current code in `raycast.gd:108-116`:

```gdscript
func _handle_ray_hit(current_hit: Node3D, previous_hit: Node3D) -> RaycastStatus:
    if current_hit != previous_hit:
        _handle_path_change(current_hit, previous_hit)
    if current_hit is AudioReflector:
        return RaycastStatus.SKIP
    elif current_hit is AudioManipulator:
        if not current_hit._ray_cast.is_active:
            _activate_current_hit(current_hit)
    return RaycastStatus.BREAK
```

There are two problems:

1. **Accessing private member:** `current_hit._ray_cast.is_active` reaches into
   the internal structure of AudioManipulator. RayCast shouldn't know about
   AudioManipulator's children.

2. **Missing AudioCatcher activation on path change:** When the path changes AND
   the new hit is an AudioProcessor (not a Catcher), the processor gets activated
   by the `elif` branch. But when the hit is a Catcher, `_handle_path_change`
   calls `_activate_current_hit` — good. However, if the ray was ALREADY hitting
   a catcher and nothing changed, nothing re-activates it. This is actually fine
   because catchers don't need re-activation, but the logic is scattered.

**Exercise:** Rewrite `_handle_ray_hit` so that:
- It never accesses `._ray_cast` directly
- AudioEmitter exposes an `is_active` property (or method) instead
- The logic is clearer about what happens for each type

Hint:
```gdscript
func _handle_ray_hit(current_hit: Node3D, previous_hit: Node3D) -> RaycastStatus:
    if current_hit != previous_hit:
        _handle_path_change(current_hit, previous_hit)

    if current_hit is AudioReflector:
        return RaycastStatus.SKIP

    if current_hit is AudioProcessor:
        if not current_hit.is_active():    # Public method, not ._ray_cast.is_active
            current_hit.receive_chord(_chord)
            current_hit.activate()

    elif current_hit is AudioCatcher:
        # Already handled in _handle_path_change
        pass

    return RaycastStatus.BREAK
```

#### 3.2 The _clean_remaining_path Problem

Current code in `raycast.gd:124-131`:

```gdscript
func _clean_remaining_path(id: int, current_hit: Node3D) -> void:
    for i in range(id, max_bounces):
        var previous_hit = _previous_ray_hit_path[i]
        if previous_hit == null: continue
        elif current_hit is AudioCatcher: continue
        elif current_hit is AudioManipulator: continue
        elif previous_hit is AudioCatcher: previous_hit.deactivate()
        elif previous_hit is AudioManipulator: previous_hit.deactivate(self)
```

Read this carefully. The `current_hit` checks on lines 128-129 mean: "if we
stopped because we hit a Catcher or Manipulator, skip cleanup for all remaining
slots." But this is checked EVERY iteration, even though `current_hit` never
changes. This should be checked once before the loop.

Also, the `current_hit is AudioCatcher: continue` line means that if we hit a
catcher, we NEVER clean up any previous hits. Is that intentional?

**Exercise:** Rewrite this method. Consider:
- What does "cleaning" mean? (Deactivating objects that are no longer in the path)
- When should we skip cleaning? (When the current hit already handles it?)
- Can you simplify the conditions?

---

### Step 4: Documentation

You asked if inline documentation is necessary. Here is my rule: document the
*contract* (what a method promises to do), not the *implementation* (how it does
it). Implementation is already in the code.

#### Good documentation (contract):

```gdscript
## Receives an input chord from an upstream RayCast.
## Does not activate or transform — call activate() separately.
func receive_chord(new_chord: Chord) -> void:
    _input_chord = new_chord
```

#### Bad documentation (restating the code):

```gdscript
## Sets _input_chord to new_chord
func receive_chord(new_chord: Chord) -> void:
    _input_chord = new_chord
```

#### Where documentation IS necessary in your project:

1. **Abstract/base classes** — Document the contract for virtual methods.
   Subclass authors need to know what to override and what the rules are.

2. **The RayCast class** — It's 236 lines and is the engine of your game.
   A top-level comment explaining the raycasting loop and bounce logic would
   help anyone (including future you) understand it quickly.

3. **Chord** — Document what `make_notes()` does and when it should be called.
   It's not obvious that you must call it before the chord is usable.

4. **Signals** — Always document what data a signal carries and when it fires.

#### Where documentation is NOT necessary:

- `fps.gd` (self-explanatory)
- Simple overrides like `activate()` → `_mat.albedo_color = Color.RED`
- Getter/setter methods with obvious names

---

### Step 5: Final Checklist

After completing all steps, verify:

- [ ] Speaker extends AudioEmitter, not RayCast
- [ ] Speaker can be picked up and placed (test in-game)
- [ ] AudioProcessor has `receive_chord()`, `_process_chord()`, `update_output()`
- [ ] AudioSeparator mask toggle updates sound in real-time
- [ ] AudioMixer forwards the MERGED chord, not the input chord
- [ ] No class accesses another class's private members (`_` prefix)
- [ ] `class_name` before `extends` in every file
- [ ] No duplicate code between Chord and LibNote (LibNote deleted)
- [ ] `interaction_oject.gd` renamed to `interaction_object.gd`
- [ ] AudioRetranslator is deleted or replaced by plain AudioProcessor
- [ ] `set_chord()` never calls `activate()` anywhere
- [ ] `_handle_ray_hit` does not access `._ray_cast` directly

---

### Summary: File Changes Map

```
DELETE:
  source/sounds/lib_note.gd
  source/objects/retranslator/retranslator.gd  (optional)

RENAME:
  source/objects/tools/interaction_object/interaction_oject.gd
    → interaction_object.gd

CREATE:
  source/objects/abstract_classes/audio_emitter.gd

MODIFY:
  source/objects/abstract_classes/manipulator.gd
    → renamed to audio_processor.gd, extends AudioEmitter
  source/objects/speaker/speaker.gd
    → extends AudioEmitter instead of RayCast
  source/objects/separator/separator.gd
    → extends AudioProcessor, uses _process_chord()
  source/objects/mixer/mixer.gd
    → extends AudioProcessor, fixes forwarding bug
  source/objects/tools/raycast.gd
    → remove set_chord auto-activation, fix _handle_ray_hit
  source/ui/interaction_menu/chord_mask_menu.gd
    → fix duplicate node, simplify toggles, rename signal
  source/player/player.gd
    → add public pause/unpause methods
  main.gd
    → stop accessing private player members
  source/sounds/chord.gd
    → ensure class_name is first line
```

---

## Questions to Take Away

These are the big-picture questions this refactoring is built around. If you can
answer all of them, you understand the architecture deeply.

1. Why is "composition over inheritance" better for Speaker?
2. What is the difference between `set_chord()` and `receive_chord()`?
3. Why should `set_chord()` never call `activate()`?
4. When is an empty subclass useful vs unnecessary?
5. How would you design AudioMixer to handle multiple input sources cleanly?
6. Why do we duplicate a chord before modifying it instead of changing the original?
7. What does the `_` prefix convention give you, and what breaks when you ignore it?

When you are ready to start implementing, work through the steps in order.
Each step is independent enough that you can test after completing it.
If you get stuck, send me the file and your question.
