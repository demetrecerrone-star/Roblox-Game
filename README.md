# Roblox-Game

Phone-managed Roblox development project.

## Publishing target

- Existing experience: TeaOfBag's Place
- Universe ID: `1831369670`
- Place ID: `5233405723`
- GitHub Actions repository secret name: `ROBLOX_API_KEY`

Keep the generated Roblox key only in GitHub Actions secrets or a password manager. Never commit the key or a Roblox login cookie.

## Current stage

Repository initialization and non-publishing setup checks. No game files have been uploaded to Roblox from this repository. The game concept has not been selected yet.

The `Roblox setup check (no publish)` workflow checks that GitHub Actions can access a non-empty secret without printing its value or contacting Roblox. It runs when its workflow file is pushed and can also be started manually from the Actions tab. It does not validate Roblox authentication, publishing permissions, or ownership of the configured IDs.

## Publishing safety

Build validation must be separate from deployment. Do not publish a test baseplate over the existing Roblox place. The first upload requires the owner's explicit approval after the game files and target are reviewed. Adding repository files or running this setup check does not trigger a Roblox upload.

## Documentation

- [Roblox place publishing](https://create.roblox.com/docs/cloud/guides/usage-place-publishing)
- [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
