#!/usr/bin/env python3
"""Manual-only, secure Runewake Model uploader. Does NOT publish Animation assets."""
import json
import os
import pathlib
import struct
import subprocess
import time
import zipfile

KEY = os.getenv("ROBLOX_ASSET_API_KEY", "")
USER_ID = os.getenv("ROBLOX_CREATOR_USER_ID", "")
ARCHIVE = pathlib.Path("assets/npc/Runewake_Animated_NPCs_v0.3.zip")
MODELS = (
    ("mira_threadlight", "Mira Threadlight", "Mira_Threadlight_Dressed_Animated.glb"),
    ("orren_kilnhand", "Orren Kilnhand", "Orren_Kilnhand_Dressed_Animated.glb"),
    ("pip_wicks", "Pip Wicks", "Pip_Wicks_Dressed_Animated.glb"),
)

def request(args, *, method_name):
    result = subprocess.run(["curl", "--silent", "--show-error", "--fail-with-body", "--max-time", "120", *args],
                            text=True, capture_output=True)
    if result.returncode:
        raise SystemExit(f"Roblox {method_name} failed: {result.stdout[:450]} {result.stderr[:200]}")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as ex:
        raise SystemExit(f"Roblox {method_name} returned invalid JSON") from ex

if not KEY:
    raise SystemExit("ROBLOX_ASSET_API_KEY is not set under GitHub Actions repository secrets.")
if not USER_ID.isdecimal() or int(USER_ID) == 0:
    raise SystemExit("Set ROBLOX_CREATOR_USER_ID to your numeric Roblox user ID in Actions variables.")
if not ARCHIVE.exists():
    raise SystemExit(f"Missing {ARCHIVE}; ChatGPT attachments are not automatically available in GitHub Actions.")

staging = pathlib.Path("npc-stage")
staging.mkdir(exist_ok=True)
with zipfile.ZipFile(ARCHIVE) as z:
    for slug, display, name in MODELS:
        if name not in z.namelist():
            raise SystemExit(f"Missing expected GLB: {name}")
        data = z.read(name)
        if not (10_000 < len(data) < 20_000_000 and data.startswith(b"glTF")):
            raise SystemExit(f"Invalid or oversized GLB: {name}")
        if struct.unpack_from("<I", data, 8)[0] != len(data):
            raise SystemExit(f"GLB header mismatch for {name}")
        json_len = struct.unpack_from("<I", data, 12)[0]
        gltf = json.loads(data[20:20 + json_len])
        if not gltf.get("animations") or len(gltf.get("skins", [])) != 1:
            raise SystemExit(f"Model is missing a single rig or animation clips: {name}")
        (staging / name).write_bytes(data)
        print(f"Validated {display}: {len(data):,} bytes and {len(gltf['animations'])} clips")

results = {}
for slug, display, name in MODELS:
    metadata = {
        "assetType": "Model",
        "displayName": "Runewake " + display,
        "description": "Dressed fantasy NPC model and Quaternius CC0 animations",
        "creationContext": {"creator": {"userId": int(USER_ID)}},
    }
    task = request(
        ["-X", "POST", "https://apis.roblox.com/assets/v1/assets",
         "-H", "x-api-key: " + KEY,
         "-F", "request=" + json.dumps(metadata, separators=(",", ":")),
         "-F", "fileContent=@npc-stage/" + name + ";type=model/gltf-binary"],
        method_name=f"Create Asset {display}")
    path = task.get("path", "")
    if not path.startswith("operations/"):
        raise SystemExit(f"Missing operation reference for {display}: {task}")
    for attempt in range(36):
        status = request(
            ["-H", "x-api-key: " + KEY, "https://apis.roblox.com/assets/v1/" + path],
            method_name=f"check {display}")
        if status.get("done"):
            if status.get("error"):
                raise SystemExit(f"Roblox asset processing failed for {display}: {status['error']}")
            asset_id = (status.get("response") or {}).get("assetId")
            if not str(asset_id).isdigit():
                raise SystemExit(f"No Model assetId for {display}: {status}")
            results[slug] = int(asset_id)
            print(f"Roblox confirmed {display} Model asset ID: {asset_id}")
            break
        time.sleep(5)
    else:
        raise SystemExit(f"Roblox import timeout for {display}")

pathlib.Path("npc-upload-results.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as f:
    f.write("# Imported Runewake NPC Model IDs\n\n")
    for slug, asset_id in results.items():
        f.write(f"- {slug}: `{asset_id}`\n")
    f.write("\nModel IDs are NOT published Animation clip IDs. Verify the imports and publish animations separately.\n")
