# Run → Grow Obby (Rojo + Roblox Studio)

MVP Roblox obby where players grow by moving, pass size-gated obstacles, get treadmill growth boosts, and can rebirth for a permanent growth multiplier.

## Features
- **Distance-based growth** (server authoritative).
- **Size gates** with server teleport-back enforcement.
- **Treadmills** tagged with `CollectionService` that boost growth.
- **More playful tracks** with split-lane boost strips, ramps, jump walls, and jump pads.
- **Lava + balance-beam challenge sections** that punish missed footing.
- **Chaser monsters** per world that pursue nearby players and deal contact damage.
- **Rebirth pad** with size requirement and multiplier progression.
- **Generated map** on server start (playable immediately).
- **Per-world visual mood shifts** (client post-processing tint/contrast transitions).
- **Leaderstats** for Size + Rebirths.
- **Data persistence** with resilient DataStore saves.

## Project structure
- `src/shared`: config/constants/util/remotes
- `src/server`: bootstrap + gameplay services
- `src/client`: HUD and toast feedback

## Setup
1. Install [Aftman](https://aftman.dev) (optional) and Rojo.
2. Install Rojo directly if needed:
   - `cargo install rojo`
3. Clone this repo and open in VS Code.
4. Start Rojo server in project root:
   - `rojo serve`
5. In Roblox Studio:
   - Install the Rojo plugin.
   - Open any place.
   - Connect plugin to `localhost:34872`.
6. Press **Play** (or Start Server test described below).

## Testing in Studio
### Single-player smoke test
1. Spawn into `GeneratedMap`.
2. Run forward on the track: **Size should increase** steadily.
3. Enter first gate while too small: **you should be teleported back** and see toast.
4. Step on treadmill areas: growth should feel faster.
5. Try jump pads and lane ramps to keep momentum and skip hazards.
6. Cross balance beams above lava pools without falling.
7. Jump over wall barriers to stay on pace.
8. Let a monster spot you and verify it chases and damages on touch.
9. Reach end and touch rebirth pad at size >= 100: rebirth triggers and size resets.

### Multiplayer test (recommended)
1. In Studio Test tab, click **Start Server** with **2 Players**.
2. Verify both players grow independently.
3. Confirm gate checks are per-player and server-enforced.
4. Confirm treadmill boost is only applied to players touching treadmill.
5. Verify data saves by stopping test and re-running (Studio API access may be required for DataStore).

## Tuning defaults
Tweak in `src/shared/Config.lua`:
- `GrowthPerMeter`
- `TreadmillBoostMultiplier`
- `MaxSize`
- `GateRequirements`
- `RebirthRequiredSize`
- `AntiExploit` limits

## LEGO/toy-brick style notes
Current map uses bright primary colors + studs surfaces + a few lightweight stud bump parts.

To swap in richer visuals later without gameplay code changes:
1. Add `SurfaceAppearance` or textures to map parts in Studio.
2. Keep part names/tags/attributes the same (`SizeGate`, `Treadmill`, `RequiredSize`, `BoostMultiplier`).
3. If replacing generated map with a handcrafted one, still include `GeneratedMap` model or disable bootstrap.

## Security notes
- Clients never set Size/Rebirth values.
- Server computes movement growth and clamps exploit-like spikes.
- Growth delta is clamped per tick.
- Size scaling is throttled and re-applied on respawn.
