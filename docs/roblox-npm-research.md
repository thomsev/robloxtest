# Roblox npm package research notes

## What I checked from this environment

I attempted to query npm directly:

```bash
npm search roblox --json | head -n 80
npm view roblox-ts name version description homepage repository.url
curl -I https://registry.npmjs.org/roblox-ts | head
curl -I https://github.com | head
```

All of these requests returned `403 Forbidden` from the network/proxy in this execution environment, so live package lookup was blocked.

## Practical answer (based on established Roblox ecosystem usage)

There **are** npm packages used in Roblox workflows, but they are mostly for **code architecture, UI systems, and tooling** (especially if you use roblox-ts), not one-click "world themes" like in web CSS frameworks.

Common package groups developers use:

- **roblox-ts toolchain**
  - `roblox-ts` (TypeScript -> Luau compiler)
  - `@rbxts/types` and many scoped `@rbxts/*` ports
- **UI frameworks / UI helpers**
  - Roact/React-style libraries and bindings in the `@rbxts/*` ecosystem
  - animation/state helpers often paired with UI
- **Game architecture / utilities**
  - networking wrappers, component systems, signal/event helpers, state management

For making worlds "look better," Roblox developers usually rely more on:

1. **Studio assets** (meshes, materials, textures, terrain tools, lighting)
2. **Post-processing** (`BloomEffect`, `ColorCorrectionEffect`, `Atmosphere`, `SunRaysEffect`, `DepthOfFieldEffect`)
3. **Environment art packs/plugins** from the Roblox Creator Marketplace
4. Optional npm packages only for pipeline/tooling (not for drop-in visual themes)

## Recommendation

If your goal is visual quality, use npm for code/tooling only and focus your time on Studio lighting + material workflow.

If you want, I can next give you a concrete "good visuals baseline" checklist (Lighting settings + Atmosphere + ColorCorrection values + material/texture strategy) you can paste into your Roblox project setup.
