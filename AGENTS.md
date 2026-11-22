# June — project instructions

This is a separate Godot game in Chillysoop/june. Do not edit Relay Company or
borrow its assets. Work directly on main, preserve unrelated work, fetch before
publishing, and never force-push. The owner supplied this repository for the game.

The owner's brief: one coherent game that grows progressively stranger in
mechanics, perspective, genre, graphics, and features, tied to one main character
and one story. The learning curve must be very easy; complexity increases over
time. Eventually break the fourth wall and become extremely bizarre. Future
prompts extend this game rather than replacing it with unrelated minigames.

Read docs/STORY.md before adding content. June, her coat and satchel, the letter,
the impossible address, her memories, and her developing relationship with the
player are continuity anchors. Keep introductory mechanics safe and understandable.
Introduce one rule, practice it, then combine it with known rules.

Use native Godot 4. Keep progression in journey.gd independent of drawing/audio.
Preserve chapter checkpoints; never silently erase progress when adding chapters.
Fourth-wall events stay within the game: no personal-file scanning, fake system
security dialogs, unwanted external windows, destructive actions, or actual
system changes as a story gimmick. Ordinary window title changes are intentional.

Run affected headless tests and native render review. One export at a time.
Publish validated source to origin/main, export that revision, record its SHA
with the local build, and report both. Do not commit binaries, caches, or bulk
review screenshots. Keep the native Windows build easy to launch locally.
