# Runewake NPC import staging

This folder is reserved for one reviewed archive: `Runewake_Animated_NPCs_v0.3.zip`, available as a download from the ChatGPT conversation.

**Important:** This is a public GitHub repository. Files uploaded here are publicly accessible. The three compiled models and the Quaternius animation/base/outfit packs are CC0, but do not place credentials or private/purchased asset packs here.

Once the owner chooses to stage that archive, it must be uploaded with the **exact filename** `assets/npc/Runewake_Animated_NPCs_v0.3.zip`. Do not extract it inside this repository.

The manual-only GitHub Action `Upload Runewake NPC Models` validates all three GLBs and imports them to Roblox Open Cloud as Model assets. It requires:
- Repository secret: `ROBLOX_ASSET_API_KEY` (Roblox API key with Assets Read and Write).
- Repository variable: `ROBLOX_CREATOR_USER_ID` (the numeric owner Roblox user ID).

The action is deliberately not triggered by push. It only starts when the owner manually runs it from GitHub Actions. It reports generated Model asset IDs after Roblox processes them, and does not claim Animation assets have been created.

After Roblox confirms these Model assets, add the IDs to `src/server/NpcAppearance.luau` and verify in-game. Use the Roblox Animation Clip Editor to check and publish animation assets separately; GLB animation data is not automatically a valid `AnimationId`.
