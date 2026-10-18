"""One read-only check of a completed non-character operation; never retries."""
import os,json,urllib.request
key=os.environ.get('ROBLOX_ASSET_API_KEY','');assert key,'Existing asset key unavailable'
url='https://apis.roblox.com/assets/v1/operations/10a86b30-e08d-47f1-9952-8fad7f3fa19a'
with urllib.request.urlopen(urllib.request.Request(url,headers={'x-api-key':key}),timeout=30) as r:d=json.load(r)
assert d.get('done') and str(d.get('response',{}).get('assetId'))=='136661424163101','Existing non-character operation not confirmed readable'
print('ASSET_READ_CHECK passed: completed village canary operation readable. No uploads in this check.')
