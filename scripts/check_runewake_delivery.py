"""Bounded read-only publication preflight. No uploads, retries, or scope changes."""
import hashlib,json,os,pathlib,urllib.request,urllib.error,urllib.parse
out=pathlib.Path('preflight-results');out.mkdir(exist_ok=True)
report={'reads':[],'published':False,'uploaded':False}
def save(): (out/'receipt.json').write_text(json.dumps(report,indent=2)+'\n')
def read_asset(asset_id,label):
    key=os.environ.get('ROBLOX_ASSET_API_KEY','')
    assert key,'Existing asset key unavailable'
    url=f'https://apis.roblox.com/asset-delivery-api/v1/assetId/{asset_id}'
    req=urllib.request.Request(url,headers={'x-api-key':key})
    try:
        with urllib.request.urlopen(req,timeout=30) as r: data=r.read(32*1024*1024+1); typ=r.headers.get('Content-Type','')
    except urllib.error.HTTPError as e:
        report['reads'].append({'assetId':asset_id,'label':label,'status':e.code,'result':'Denied or unavailable; stopped without retry or alternate route'});save();raise SystemExit(f'{label}: HTTP {e.code}; preflight stopped')
    if 'json' in typ or data.lstrip().startswith(b'{'):
        obj=json.loads(data); location=obj.get('location')
        if not location and obj.get('locations'): location=obj['locations'][0].get('location')
        if not location:
            report['reads'].append({'assetId':asset_id,'label':label,'status':200,'result':'No downloadable location'});save();raise SystemExit('No downloadable location')
        parsed=urllib.parse.urlparse(location)
        assert parsed.scheme=='https' and (parsed.hostname.endswith('.rbxcdn.com') or parsed.hostname.endswith('.roblox.com')), 'Unrecognized delivery host'
        # The service-supplied signed download has no API key header and is not logged.
        try:
            with urllib.request.urlopen(location,timeout=30) as r: data=r.read(32*1024*1024+1)
        except urllib.error.HTTPError as e:
            report['reads'].append({'assetId':asset_id,'label':label,'status':e.code,'result':'Delivery denied; stopped'});save();raise SystemExit(f'{label}: delivery HTTP {e.code}')
    assert len(data)<=32*1024*1024,'Asset exceeds bounded download size'
    assert data.startswith(b'<roblox') or b'<roblox' in data[:100], 'Unrecognized Roblox serialization'
    (out/(label+'.rbxm')).write_bytes(data)
    report['reads'].append({'assetId':asset_id,'label':label,'status':200,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'result':'Downloaded; not executed or Studio validated'});save()
read_asset(136661424163101,'eligible-village-model')
read_asset(5233405723,'current-place-backup')
print('Read-only preflight complete; inspect artifact. No publication.')
