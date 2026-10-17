# Runewake

A fantasy RPG and dungeon-adventure for Roblox, designed for phone-first play and maintained in GitHub.

## Approved direction

- **Name:** Runewake (rune-wake).
- **Genre:** Fantasy RPG mixed with dungeon adventures.
- **v0.1 playable target:** Threadlight Village, a linked dungeon, original NPCs and enemies, melee attacks, loot, upgrades, quest and a boss.
- This is a separate project from Adventure Odyssey and Aetherfall.
- Development repository: `demetrecerrone-star/Roblox-Game`.

## v0.1 implementation

The source now includes:

- `default.project.json`: Rojo mapping from source to a Roblox place.
- `src/server/World.luau`: creates Threadlight Village, four simple buildings, three NPCs, a rune portal and Hollow Rune Depths.
- `src/server/Enemies.luau`: creates distinctive primitive models for Shardback, Bellwisp and Rootbound Warden, along with server-controlled movement, attack telegraphs, health and respawns.
- `src/server/Game.server.luau`: quest interactions, portal transport, combat checks, gold, salvage, XP, leveling, weapon upgrades and best-effort Roblox DataStore saves.
- `src/client/Hud.client.luau`: touch-friendly attack button, health, gold, XP, shard count, quest tracking and NPC notices.
- `src/shared/CharacterCatalog.luau`: original character identities and combat parameters.

The models are original geometry placeholders assembled in-engine, **not finished mesh artwork or animations**. No professional gameplay playtest or visual screenshot has yet been completed. Build and upload success, if any, must be checked in GitHub Actions; successful upload does not guarantee error-free gameplay.

## Supplied model packs — approved NPC use

- **Universal Base Characters** is the character-body/rig source for **NPCs**, including replacements for the temporary Mira, Orren, and Pip figures. It is **not** a requirement to change the player's avatar.
- The separate **Modular Character Outfits — Fantasy** pack is compatible with the base-character skeleton, but putting armor or outfit pieces onto these NPCs is **optional, not required**. Use each NPC's base character directly unless a particular NPC look calls for an outfit later.
- Do **not** combine every base character with the armor pack by default. Universal Base Characters are for **NPCs**; Roblox players keep their own avatar appearance and clothing.
- **Approved armor behavior for players:** armor is **icon-only equipment with gameplay bonuses**. A helmet/chest/boots item can appear in inventory/equipment UI and grant its configured defense, health, resistance, or other boosts while equipped, but must **not** replace, cover, or otherwise alter a player's Roblox outfit or body.
- Treat the supplied armor/outfit pack as a reference for appropriate item icons and optional NPC appearance, **not** a requirement to put 3D armor on player characters. Icon-only armor does not block later visible weapon models and swing animations.
- The inventory/equipment slots and passive armor stat modifiers are **planned, not implemented in v0.1**. Calculate buffs on the server and persist equipped item identifiers when those systems are added.
- Imported NPCs will eventually need a Roblox-compatible rig, materials/textures and idle/talk/walk animations. Asset compatibility does **not** by itself mean a model has been uploaded or is visible in the live game.
- The supplied source packs remain external inputs and must not be committed wholesale to this public repo.

## Gameplay loop

1. Spawn in Threadlight Village and talk to Mira to accept the first quest.
2. Enter the portal marked Hollow Rune Depths.
3. Tap **ATTACK** near a monster; dodge its glowing red warning area.
4. Defeat Shardback and Bellwisp for gold, XP and salvage.
5. Defeat the Rootbound Warden and return to Mira for a quest reward.
6. Upgrade your weapon with Orren and sell collected salvage to Pip.

Combat, progression and rewards are controlled by the Roblox server, not the player's device.

## Connected Roblox target

- Existing dashboard experience: TeaOfBag's Place
- Approved game title: **Runewake**
- Universe ID: `1831369670`
- Place ID: `5233405723`
- GitHub Actions secret: `ROBLOX_API_KEY`

The repo has permission from the owner to replace the empty existing place with the first playable build. Publishing the place does **not** automatically rename TeaOfBag's Place in the Creator Dashboard.

## Automated build and release

The workflow at `.github/workflows/runewake-publish.yml` is intended to:

1. Install Rojo 7.7.1 and build `Runewake.rbxlx` from this source.
2. Validate the XML place and archive a build artifact.
3. Publish that place file to the IDs above through Roblox Open Cloud with `versionType=Published`, using the GitHub Actions secret.

The existing `roblox-setup-check.yml` only confirms GitHub can see a nonempty secret; it **does not** verify that Roblox accepts the key. Build and publish outcomes must be confirmed in the workflow run log. If Roblox rejects the key or permissions, nothing should be reported as published.

### Key safety

Store the generated Roblox API key only in GitHub **Settings → Secrets and variables → Actions**, as a repository secret named `ROBLOX_API_KEY`. Never commit the key, screenshots of the key, or a Roblox login cookie.

### Documentation

- [Roblox Open Cloud place publishing](https://create.roblox.com/docs/cloud/guides/usage-place-publishing)
- [Rojo build](https://rojo.space/docs/v7/getting-started/new-game/)
- [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
