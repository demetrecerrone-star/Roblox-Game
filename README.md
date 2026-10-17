# Runewake

A fantasy RPG and dungeon-adventure game for Roblox, developed through a phone-managed workflow.

## Approved direction

- Game title: **Runewake** (pronounced "rune-wake").
- Genre: a mixture of fantasy RPG and dungeon adventure.
- Development repository: `demetrecerrone-star/Roblox-Game` (repository name unchanged).
- This is a separate project from Adventure Odyssey and Aetherfall.

The title and genre are approved. Detailed mechanics, art direction, and scope remain to be decided.

## First playable milestone — proposal, not implemented

Start with a small starter town connected to one dungeon. Establish mobile controls, basic combat, enemy encounters, treasure, and one boss before expanding the world or adding more progression systems.

Suggested gameplay loop: prepare in town, explore the dungeon, collect loot, return to improve equipment, and venture farther. This is a planning proposal rather than a claim that these features exist or have been approved individually.

## Publishing target

- Existing experience, last observed dashboard name: TeaOfBag's Place
- Approved new game title: Runewake
- Universe ID: `1831369670`
- Place ID: `5233405723`
- GitHub Actions repository secret name: `ROBLOX_API_KEY`

Updating this README does not rename the live Roblox experience or publish game files. The live dashboard title change remains a separate step.

Keep the generated Roblox key only in GitHub Actions secrets or a password manager. Never commit the key or a Roblox login cookie.

## Current stage

Repository initialization and non-publishing setup checks, with the game title and genre now selected. No game files have been uploaded to Roblox from this repository. This naming update changes documentation only.

The `Roblox setup check (no publish)` workflow checks that GitHub Actions can access a non-empty secret without printing its value or contacting Roblox. It runs when its workflow file is pushed and can also be started manually from the Actions tab. It does not validate Roblox authentication, publishing permissions, or ownership of the configured IDs.

## Publishing safety

Build validation must be separate from deployment. Do not publish a test baseplate over the existing Roblox place. The first upload requires the owner's explicit approval after the game files and target are reviewed. Adding repository files or running this setup check does not trigger a Roblox upload.

## Documentation

- [Roblox place publishing](https://create.roblox.com/docs/cloud/guides/usage-place-publishing)
- [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
