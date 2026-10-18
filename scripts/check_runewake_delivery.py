"""Bounded read-only publication preflight. No uploads, retries, or scope changes."""
import hashlib,json,os,pathlib,urllib.request,urllib.error,urllib.parse,gzip,io
out=pathlib.Path('preflight-results');out.mkdir(exist_ok=True)
report={'reads':[],'published':False,'uploaded':False}
def save(): (out/'receipt.json').write_text(json.dumps(report,indent=2)+'\n')
def decompress(data):
    if data.startswith(b'\x1f\x8b'):
        with gzip.GzipFile(fileobj=io.BytesIO(data)) as f: data=f.read(32*1024*1024+1)
    assert len(data)<=32*1024*1024,'Decompressed asset exceeds bounded size'
    return data
def read_asset(asset_id,label):
    key=os.environ.get('ROBLOX_ASSET_API_KEY','')
    assert key,'Existing asset key unavailable'
    url=f'https://apis.roblox.com/asset-delivery-api/v1/assetId/{asset_id}'
    req=urllib.request.Request(url,headers={'x-api-key':key})
    try:
        with urllib.request.urlopen(req,timeout=30) as r: data=r.read(32*1024*1024+1); typ=r.headers.get('Content-Type','')
    except urllib.error.HTTPError as e:
        report['reads'].append({'assetId':asset_id,'label':label,'status':e.code,'result':'Denied or unavailable; stopped without retry or alternate route'});save();raise SystemExit(f'{label}: HTTP {e.code}; preflight stopped')
    data=decompress(data)
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
    data=decompress(data)
    if not (data.startswith(b'<roblox') or b'<roblox' in data[:100]):
        report['reads'].append({'assetId':asset_id,'label':label,'status':200,'result':'Unrecognized serialization','first16hex':data[:16].hex(),'bytes':len(data)});save()
    assert len(data)<=32*1024*1024,'Asset exceeds bounded download size'
    assert data.startswith(b'<roblox') or b'<roblox' in data[:100], 'Unrecognized Roblox serialization'
    (out/(label+'.rbxm')).write_bytes(data)
    report['reads'].append({'assetId':asset_id,'label':label,'status':200,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'result':'Downloaded; not executed or Studio validated'});save()
# Current place backup already preserved and hash-matched to version7.
# Fetch only selected world-art models; never any character, body texture or animation.
selected=[71344590355999, 72438271223212, 72743091317048, 72898706232503, 74254470761726, 75807681024881, 77639499631678, 77728397397907, 78967781576793, 79316336964128, 80885905011230, 81664556522639, 81950694129216, 82804120177171, 84110529849995, 84308781536727, 84530238293814, 85745467195057, 86064276450131, 86160991517211, 86243080205219, 86821603495114, 87195128556641, 87319573086093, 89534722258443, 90191242862374, 91241783763328, 92110647573661, 92563633717028, 93743463879622, 93998157880251, 94231680415279, 94399517349220, 96257885070818, 96485570579831, 96584614249794, 97068020097431, 97171839951312, 98149097240319, 98416818595086, 98832217289006, 99807407161052, 100251644513889, 100780661573727, 100954939944570, 101335660763552, 101828450465484, 102229126303170, 102884525193316, 102895336638227, 104007344159541, 104751791398442, 105424512190761, 105884781965643, 106601513506147, 107059394478166, 107490436049888, 108941673869979, 110669086683975, 113249642197539, 114853651082426, 115779312085924, 116297981663088, 116639873872254, 117067196158951, 117748476865179, 117866790423717, 120992716660327, 122336058078392, 122797564701234, 123072635621310, 123371496604961, 124554532321310, 124595593383779, 124777642073099, 125581477030659, 125693798008639, 126603733344146, 126763135876896, 128117541111183, 128361042942855, 130309946660632, 130623576429104, 131348941672514, 131444359868437, 131868070034244, 132148734123758, 132628660300141, 134720777715939, 135433311298482, 136656954447362, 136661424163101, 137558349356547, 137773091211040, 137796303555641, 137870751755922, 138647434091769, 139257176138220, 140264275267474, 140396566575105, 140532376551740]
held=[70807775230058, 72734347059369, 73620753197641, 77214655465602, 78307999559458, 83968016360124, 84986778673160, 85868662107840, 88145007544967, 88628017799158, 88662812642897, 89386593771715, 89945566117956, 90975861641954, 95142377623106, 95276496491938, 95535389841514, 100649753362603, 101143832449951, 105095486637072, 105384631033718, 106896925100170, 107635795734782, 108690683169866, 110976326848142, 111542105131231, 115231793057467, 115405284612214, 116075971666041, 116667970166491, 117165797116196, 121767561131867, 123894250769335, 130598905631386, 132872977998991, 133114630693961, 133461966781072, 135753059463560, 136359639372676, 136969524914221, 136979252836975, 137031693285759, 138616928910950, 139196260386306, 140241613957558]
assert not set(selected)&set(held)
for asset_id in selected:
    read_asset(asset_id,'world-model-'+str(asset_id))
print('Read-only preflight complete; inspect artifact. No publication.')
