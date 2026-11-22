# June — continuity bible

**Owner direction, November 21–22, 2026:** use Godot; keep one protagonist and
one coherent story while increasing strangeness across mechanics, genres,
perspectives, graphics, and features. Start extremely easy, grow complexity,
and ultimately break the fourth wall. The owner intends to keep adding things.

## The invariant

June is an observant, practical courier. Orange coat, dark cap with a mint band,
cream satchel. She is funny because she tries to do her job, not because she
delivers disconnected jokes. Her objective is a delivery to Number Zero,
Elsewhere Lane. The letter is in her handwriting, but she has not written it.

Every change of genre is a place or layer of the same impossible delivery.
Mechanical objects become narrative evidence: the platforming stamps prove
travel to the courtroom clerk; the corridor's symbols become memories in the sky.
The letter was transporting June herself. At the address she sees the interface,
asks the player to pause, and crosses a boundary she cannot cross on her own.

## Current playable arc

| Section | New rule | Connection |
| --- | --- | --- |
| Ordinary Tuesday | Walk, then interact | Pick up the letter; a new door appears. Optional talking cat. |
| The stairs have resigned | Flip gravity | Collect tomorrow/nowhere/home stamps; combine direction with gravity. |
| A matter of perspective | First-person choices | Follow moon, eye, door, as written on the same letter. |
| Department of Depth | Present contradictory evidence | A fish clerk hears three claims. Items and identity matter. |
| You are not the center | Rotate the universe and hold alignment | Decode three memories, including a viewer beyond a rectangle of light. |
| Outside the story | Act through the game's own interface | June recognizes the instructions address someone else; genuine pause becomes a door. |
| Someone is listening | Establish the next relationship | June knows the player exists. A presence acknowledges delivery. |

## The Margins (version 0.2, November 22, 2026)

The owner requested the next chapter after June recognizes the player, building
on learned mechanics and becoming much stranger. This chapter is now playable:

| Section | New rule | Reused knowledge and consequence |
| --- | --- | --- |
| Please hold this thought | The player makes HERE solid on floor or ceiling | Walking and gravity combine with editing the page; collect I and AM. |
| A minute with teeth | Pause leaves a remembered June holding a moon plate | June walks past a gate and flips to an eye plate while her past self stays. Earn WITH. |
| A door in the pupil | C changes between inside and outside the same world | Rotate the world like the earlier sky, pin it with F, leave an echo, and cross the ceiling bridge to YOU. |
| The other side has a street | June writes a sentence with the player | I AM WITH YOU is addressed to the player. The sender's name has been erased. June chooses to find the missing person. |

The Margin is an editorial presence trying to keep readers and characters on
their designated sides. June objects: the player is her collaborator, not cargo.
The new letter is not a replacement for the old one: its previously blank reverse
side becomes the space they explore and the sentence they assemble together.

Typography, violet clockwork, and nested wireframe rooms deliberately depart
from the first delivery's illustrated town. June retains her cap, coat, and bag.
The echo is June's memory, not a second protagonist. The outlined empty place
beside June at the ending represents the player; it never uses personal data.

Only these two deliveries are implemented. Finding the erased sender is the
next expansion point, not a currently playable third chapter.

## Future escalation

Extend from June's new awareness. Reuse and mutate learned rules before adding
new ones. The player and June should increasingly collaborate, disagree, and
negotiate over who controls the interface. Surreal events need consequences:
an earlier choice, a changed object, remembered dialogue, or a new ability.

The present arc is deliberately forgiving. Later complexity should ask players
to combine knowledge and make interesting decisions, not punish them for failing
to guess invisible rules. Do not make a protagonist swap or genre montage that
forgets the delivery. New rendering styles can change dramatically while keeping
June's silhouette and personal objects recognizable.

Do not access real personal data for fourth-wall jokes. No actual crashes or
destructive fake-outs. Pause, sound, exit, and accessibility controls must remain
usable even when they become story objects. Widen the fictional world, not the
game's access to the player's machine.

## Save evolution

Schema 2 stores a room boundary plus sound and assist preferences. Schema 1
chapters 0–5 stay where they are; its completed chapter 6 migrates to chapter 7,
the first Margins room. Reading a legacy save changes no bytes. The first write
backs up the original file once, then atomically replaces it. Schema 2 chapter 6
is the first-delivery interlude with an E continuation, and chapter 10 is the new
completed ending. Room-level progress reconstructs earned words from the current
chapter; within a room, recovery preserves words and puzzle state, while Continue
restarts that room. It is deliberately not a mid-movement save.

When adding the third delivery, preserve the chapter-10 completion and extend it
explicitly. Never silently wipe saves or make a returning player replay the game.
