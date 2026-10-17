# Runewake

A fantasy RPG and dungeon-adventure game for Roblox, developed through a phone-managed workflow.

## Approved direction

- Game title: **Runewake** (pronounced "rune-wake").
- Genre: fantasy RPG mixed with dungeon adventure.
- First playable scope: a small starter town linked to one dungeon, with mobile-friendly combat, loot, upgrades, and a boss.
- NPCs and monsters should be unique.
- Development repository: `demetrecerrone-star/Roblox-Game` (repository name unchanged).
- This is separate from Adventure Odyssey and Aetherfall.

## Actual implementation status

There is no playable game build yet. Before the character-definition commit, the repository contained only this README and the non-publishing setup-check workflow.

`src/shared/CharacterCatalog.luau` now contains the first data definitions for three NPCs, two regular enemies, and one boss. Each has a distinct silhouette, role or combat-pattern specification, and motion brief. Enemy tuning and rewards are provisional. These individual names and designs are implementation proposals, not separately approved final artwork.

The catalog is data only. It does not create 3D models, animate characters, run AI, award loot, or wire up quests. It has not been playtested. The starter town, dungeon, character models, behavior handlers, player combat, loot, upgrade services, and game-build workflow still need implementation.

### Initial character proposals

- Mira Threadlight: rune-compass cartographer and first dungeon quest contact.
- Orren Kilnhand: smith with a glass-forged forearm and equipment upgrade role.
- Pip Wicks: lantern-pack courier and salvage trader.
- Shardback: six-legged crystal burrower with a telegraphed straight charge.
- Bellwisp: cracked floating bell that orbits and warns before a close-range pulse.
- Rootbound Warden: root-held stone gate guardian with distinct slam and sweep attacks.

## Publishing target

- Existing experience, last observed dashboard name: TeaOfBag's Place
- Approved new game title: Runewake
- Universe ID: `1831369670`
- Place ID: `5233405723`
- GitHub Actions repository secret name: `ROBLOX_API_KEY`

Repository changes do not rename the live Roblox experience or publish game files. The live dashboard title change is a separate step. No Roblox upload was made during this update.

Keep the generated Roblox key only in GitHub Actions secrets or a password manager. Never commit the key or a Roblox login cookie.

## Setup check

The `Roblox setup check (no publish)` workflow checks that GitHub Actions can access a non-empty secret without printing its value or contacting Roblox. It runs when its workflow file is pushed and can also be started manually from the Actions tab. It does not validate Roblox authentication, publishing permissions, or ownership of the configured IDs. A passing setup check is not a successful game build or playtest.

## Publishing safety

Build validation must be separate from deployment. Do not publish a test baseplate over the existing Roblox place. The first upload requires the owner's explicit approval after the game files and target are reviewed. Adding these repository files does not trigger a Roblox upload.

## Documentation

- [Roblox place publishing](https://create.roblox.com/docs/cloud/guides/usage-place-publishing)
- [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
