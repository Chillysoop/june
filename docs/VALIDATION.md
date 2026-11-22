# First delivery validation — November 22, 2026

Tested locally on Windows with Godot 4.7.2 stable and the Compatibility renderer
on an NVIDIA RTX 3080. The source is independent of other local game checkouts.

## Automated coverage

- `tests/test_journey.gd`: **43 checks**. Plays the complete route through
  ordinary movement, all three gravity stamps with collision, the corridor,
  wrong choices, evidence, rotational alignment, and the interface boundary.
  Also checks dialogue freezing, input cooldowns, bounds, all seven checkpoint
  values, and rejection of invalid save shapes/versions/chapters.
- `tests/test_input.gd`: **25 checks**. Exercises native Godot input handlers,
  pause and letter state, evidence number keys, both dialogue controls, assist,
  sound, the pause-menu ending, new-game cancellation, continue, and focus loss.
  Writes an isolated test-owned save to verify actual atomic replacement and
  preference restoration, and verifies invalid reads do not overwrite data.

QA mode isolates captures and manual review from player saves. The native
renderer produced all scenes at 1280×800, plus 11 final captures at 960×600
including the longest introductory dialogue, the letter, and the special pause
menu. Captures were visually inspected for readability, clipping, and continuity.
Final capture output reported `NATIVE_CAPTURE_OK: 11 screens` with no errors or
resource-leak warnings after audio shutdown cleanup.

The native title window was also inspected through Windows computer use. The
user stopped that interaction with Escape before manual keyboard traversal;
no further computer-use input was sent. Automated input checks and the complete
simulation route supply behavior coverage; they are not a claim of a full human
playtest or a measured playtime.

## Limits

This is a short opening arc, not an endless game or a completed long campaign.
The first-person section uses illustrated perspective with discrete doors,
not a free-roaming 3D engine. Current visuals are original procedural vector
illustrations. Movement is keyboard-only; gamepad and touch are not implemented.
Custom canvas controls do not yet expose a screen-reader accessibility tree.

The next addition should continue June's awareness and deepen interactions
between learned mechanics. Preserve the completion checkpoint for that extension.

Build products and raw logs/captures are ignored under `build/` and `evidence/`.
The installed build receipt records the exact source commit and executable hash.
