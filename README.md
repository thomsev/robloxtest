# The Growth Run

A single intentional Roblox world with a clear start → middle → end path.

## Design intent
- One clean forward route on +Z with gradual height progression.
- Visual guidance via arrows + signs in every section.
- Mechanics taught in order: movement, gaps, speed control, NPC interference, final climb.
- Checkpoints placed after tense moments so falls are readable, not punishing.

## Section flow
1. **Start Platform**: safe intro, obvious direction, first checkpoint quickly.
2. **Onboarding**: wide ramps, no gaps, teaches movement/growth.
3. **Intro Gaps**: small jumps + safe lane + risk bonus lane.
4. **Speed Control**: downhill narrower ramps, speed is the challenge.
5. **Interaction**: Bully Bots shove small players / smashable by big players.
6. **Final Climb + Finish**: narrow vertical beams into reward platform.

## Architecture
### Server
- `MapBootstrapService` clears old map and builds exactly one `workspace.GeneratedMap`.
- `WorldBuilder` executes section builders sequentially using cursor CFrames.
- `section_builders/*` each take start CFrame and return end CFrame.
- `GrowthService`, `CheckpointService`, `NPCService`, `SmashService` handle runtime gameplay.
- `DataStoreService` is Studio-safe no-op and never blocks boot.

### Client
- `UIService`, `CameraService`, `FeedbackService` for clarity and feel.

## Run
1. `rojo serve`
2. Connect in Roblox Studio.
3. Play The Growth Run.
