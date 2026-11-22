# The Margins — validation, November 22, 2026

Version 0.2 extends the existing Godot game. The first-delivery behavior remains
covered; its old ending is now a playable continuation rather than a dead end.

## Behavioral checks

- Original journey suite: 43 checks, including the whole original route.
- Input/save suite: 40 checks, including F/C, pause guards, click action routing,
  memory recording and resume, actual atomic save replacement, exact legacy
  backup bytes, both preferences, and the new ending's resume behavior.
- Margins suite: 78 checks. Completes all three new rooms with normal movement,
  gravity, bridge placement, memory holding, outside rotation, pinning, and
  perspective changes. Exercises closed-gate collision, missing bridge recovery,
  removing support under June, preserved words/pin/echo after falling, and all
  version-one and version-two checkpoint values plus invalid payloads.

The save tests use isolated test-owned files and never alter player progress.
Native QA uses `--qa` implicitly and never writes saves.
The final combined run passed **161 checks in 2.55 seconds wall time** on this
machine, including the three Godot process launches. This measures automated
validation, not player pacing.

## Native review

The dedicated native capture path covers 15 states: unplaced/floor/ceiling words,
closed/remembered/solved minute, outside/pinned/inside/bridged recursive world,
new ending, memory pause menu, letter, dialogue, and the original ending's new
continuation. Review includes 1280×800 and 960×600 windows using the Compatibility
renderer. A transient blank feedback strip found during review was corrected by
clearing its timer with its text at room transitions.

No computer-use input is needed: the engine renders its own QA captures, and
input handlers are exercised by the headless suite. This is not a human playtime
measurement or a claim of full accessibility/gamepad coverage.

## Delivery boundary

The release is exported from the published commit. `BUILD.json` beside the
installed Windows executable records that SHA and the executable's SHA-256.
Only the managed June installation is refreshed; other games and existing saves
are untouched. Generated images, logs, builds and compiler state stay out of Git.
