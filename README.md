# The Growth Tower (single-world redesign)

This game is now one intentional, complete Roblox experience: **a single LEGO-style vertical tower** with six handcrafted sections and one core loop.

## Core loop (always clear)
1. Run and grow.
2. Reach the next checkpoint.
3. Learn why you failed ("Too fast" / "Jump earlier").
4. Retry from the last checkpoint.
5. Reach summit for a big payoff.

## Why each section exists
1. **Onboarding** — wide pads and tiny gaps teach movement + jumping fast.
2. **Control Challenge** — speed starts becoming dangerous on narrower curves.
3. **Jump Timing** — safe lane plus risky bonus lane teaches precision choice.
4. **Interference** — Bully Bots add shove/smash chaos with readable rules.
5. **Mastery Climb** — steep narrow climb combines all previous skills.
6. **Summit Moment** — open reward platform and celebration burst.

## Architecture
### Server
- `WorldBuilder` - builds Growth Tower section-by-section.
- `SectionConfig` - tuning per section.
- `GrowthService` - movement growth, speed scaling, reward pulse.
- `CheckpointService` - checkpoint state + fall recovery + failure feedback.
- `NPCService` - Bully Bot patrol movement.
- `SmashService` - NPC shove/smash and risk-lane bonus logic.

### Client
- `UIService` - next checkpoint + risk-lane HUD.
- `CameraService` - subtle pullback as difficulty rises.
- `FeedbackService` - sounds and toasts.

### Shared
- `Config`, `Constants`, `Util`, `Remotes`.

## Run
1. `rojo serve`
2. Connect from Roblox Studio.
3. Play and climb the tower.
