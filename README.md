# Run → Grow → Smash Front-Page Loop (Rojo + Roblox Studio)

This project is now structured like a front-page retention game: players spawn in a social lobby, choose worlds through portals, climb vertical speed-based obbies, smash interferers for premium currency, and rebirth for long-term power.

## Session loop (10–20 min target)
1. **Lobby (0–60s):** instant growth via treadmills + movement pulse rewards, clear objective in HUD, visible giant players.
2. **World run (1–6 min):** stacked vertical levels, narrower high lanes, tighter jumps as speed rises.
3. **Chaos moments:** NPC interferers shove small players; big players smash NPCs for Smash Tokens.
4. **Checkpoint loop:** fail a jump → back to latest checkpoint, not full reset.
5. **Completion + unlock:** world finish grants coins and unlocks next portal progression.
6. **Rebirth spectacle:** reset size, keep mastery/upgrades/currencies, unlock deeper worlds + stronger chaos potential.

## Progression layers
- **Physical power:** Size, speed scaling, smash power, stomp.
- **World progression:** Portal unlocks, vertical world clears, checkpoints.
- **Long-term progression:** Rebirths, Smash Tokens, cosmetics/assist upgrades.

## Current architecture
- **Server-authoritative:** size, speed, currency, portals, checkpoints, smashing, collision knockback.
- **Client-authoritative only for:** UI, visual effects, feedback.
- **CollectionService tags used for:** `WorldPortal`, `Treadmill`, `Checkpoint`, `Smashable`, `InterfererNPC`, `CollisionZone`.

## Run
1. `rojo serve`
2. Connect from Roblox Studio via Rojo plugin.
3. Play (recommended multiplayer server test for collision chaos + NPC interference).
