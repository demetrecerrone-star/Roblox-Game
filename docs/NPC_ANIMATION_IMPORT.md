# Runewake — NPC animation integration

## Confirmed inputs

- User provided **Universal Animation Library 2 [Standard]** by Quaternius, licensed **CC0 1.0**.
- This pack contains **43 named clips** in each of two GLB variants: `UAL2_Standard.glb` (without root motion) and `UAL2_Standard_RM.glb` (with baked root motion). Each is also supplied in FBX form.
- `Universal Base Characters [Standard]` and `Modular Character Outfits — Fantasy [Standard]` are also CC0 1.0. These are used for **dressed NPCs only**; the player's own Roblox avatar outfit must remain unchanged.
- The animation GLB and each prepared dressed NPC share the same **65 joint names**, but slightly different default rest-pose transforms. Copying animations by name without adjusting the rest pose risks deformation.

## Prepared character animation export

ChatGPT created `Runewake_Animated_NPCs_v0.3.zip` (a conversation file, **not** a GitHub asset). It includes three GLBs that have undergone rest-pose-aware animation retargeting. GLB JSON/channel references were checked, all 3 model meshes parsed, and each file is under the Roblox Open Cloud 20 MB model upload cap. **No live Roblox animation playback has yet been verified.**

| NPC | Animated GLB | Clips |
| --- | --- | --- |
| Mira Threadlight | `Mira_Threadlight_Dressed_Animated.glb` | `Idle_FoldArms_Loop`, `Idle_No_Loop`, `Idle_Rail_Call`, `Walk_Carry_Loop`, `Yes`, `Farm_Harvest`, `Chest_Open` |
| Orren Kilnhand | `Orren_Kilnhand_Dressed_Animated.glb` | `Idle_FoldArms_Loop`, `Walk_Carry_Loop`, `TreeChopping_Loop`, `Yes`, `Sword_Regular_A`, `Sword_Heavy_Combo`, `Chest_Open` |
| Pip Wicks | `Pip_Wicks_Dressed_Animated.glb` | `Idle_Lantern_Loop`, `Walk_Carry_Loop`, `Idle_Rail_Call`, `Yes`, `Consume`, `Farm_Harvest`, `Chest_Open` |

**Missing locomotion:** UAL2 Standard has `Walk_Carry_Loop` and `Zombie_Walk_Fwd_Loop` but not an ordinary unarmed human walk. We must author or obtain one before general NPC patrols.

## Import and live integration — still to do

1. Obtain an Open Cloud key with **Assets Read** and **Assets Write** scopes. Do **not** commit or paste a key into chat. The current `ROBLOX_API_KEY` secret for publishing places does **not** prove it has Assets permissions. Store the Assets key as a GitHub Actions secret, e.g. `ROBLOX_ASSET_API_KEY`.
2. Find the owner/creator numeric Roblox user ID for the `creationContext` of the upload, without exposing credentials.
3. Transfer the 3 prepared GLBs privately to a file source the GitHub runner can reach, or have the owner upload those 3 files to Roblox via a trusted mobile-accessible uploader. Do not silently publish vendor packs in the public GitHub repository.
4. Upload each GLB through the Open Cloud Create Asset endpoint as **Model** with `model/gltf-binary`. Record all resulting asset IDs; verify ownership/permissions and Roblox import success.
5. Import/playtest animation clips: embedded GLB tracks do **not** by themselves establish separately published Roblox `Animation` asset IDs. Use Roblox's GLTF animation import support, publish required clips, then implement an `Animator` script with idle/interact/walk behaviors.
6. After Model IDs are valid, populate `src/server/NpcAppearance.luau`. Keep existing interactive NPC placeholders as safe fallbacks and do not modify Roblox player's avatar clothing.
7. Confirm mobile performance, position/orientation, clothing attachment, no clipping, and NPC interaction prompts.

## Current state

The source repository has a `dressedNpc` fallback loader and an `NpcAppearance.luau` manifest with zero IDs. The *actual dressed/animated meshes are NOT yet present in the live Roblox experience*. The place-publishing workflow's success only confirms successful place upload, not external model upload/animation playback.
