"""One-shot exact-hash checkpoint publication; current-place backup must match first."""
import gzip,hashlib,io,json,os,pathlib,urllib.request,urllib.error,urllib.parse,xml.etree.ElementTree as ET
ROOT=pathlib.Path('.');OUT=ROOT/'publication-results';OUT.mkdir(exist_ok=True)
request=json.loads((ROOT/'release/request.json').read_text())
assert request['placeId']==5233405723 and request['universeId']==1831369670
assert request['approvedBackupSha256']=='3b9a5f0796d4dc78f8cb3ce8bfb5ca869980bd6d77b72d527032991423811cf7'
place=ROOT/'release/Runewake-World-Checkpoint.rbxl';content=place.read_bytes()
assert hashlib.sha256(content).hexdigest()==request['placeSha256'],'Release file changed after review'
assert 100_000<len(content)<32*1024*1024
assert request['placeFormat']=='binary' and content.startswith(b'<roblox!\x89\xff\r\n\x1a\n'),'Invalid binary header'
receipt={'published':False,'placeId':5233405723,'releaseSha256':request['placeSha256']}
def save(): (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
def unpack(data):
 if data.startswith(b'\x1f\x8b'):
  with gzip.GzipFile(fileobj=io.BytesIO(data)) as f:data=f.read(32*1024*1024+1)
 assert len(data)<=32*1024*1024
 return data
# Never retrieve the key value into source/logs/artifacts. Existing Actions secret only.
key=os.environ.get('ROBLOX_ASSET_API_KEY');assert key
req=urllib.request.Request('https://apis.roblox.com/asset-delivery-api/v1/assetId/5233405723',headers={'x-api-key':key})
try:
 with urllib.request.urlopen(req,timeout=30) as r:data=unpack(r.read(32*1024*1024+1))
except urllib.error.HTTPError as e:
 receipt['backupHttpStatus']=e.code;save();raise SystemExit('Backup access failed; no publication')
if data.lstrip().startswith(b'{'):
 obj=json.loads(data);location=obj.get('location') or (obj.get('locations') or [{}])[0].get('location');assert location
 u=urllib.parse.urlparse(location);assert u.scheme=='https' and (u.hostname.endswith('.rbxcdn.com') or u.hostname.endswith('.roblox.com'))
 with urllib.request.urlopen(location,timeout=30) as r:data=unpack(r.read(32*1024*1024+1))
assert data.startswith(b'<roblox') or b'<roblox' in data[:100]
(OUT/'before-publication-place.rbxl').write_bytes(data)
receipt['backupSha256']=hashlib.sha256(data).hexdigest();save()
assert receipt['backupSha256']==request['approvedBackupSha256'],'Live source changed since review: refusing replacement'
# This script is split by mode so backup is archived successfully BEFORE the write step.
if os.environ.get('PUBLISH_MODE')!='publish':
 print('Current backup matches reviewed version; no publication in backup mode.');raise SystemExit(0)
assert os.environ.get('BACKUP_ARTIFACT_SAVED')=='true','Backup must be uploaded before publishing'
publish_key=os.environ.get('ROBLOX_API_KEY');assert publish_key,'Existing publish key unavailable'
url='https://apis.roblox.com/universes/v1/1831369670/places/5233405723/versions?versionType=Published'
req=urllib.request.Request(url,data=content,headers={'x-api-key':publish_key,'Content-Type':'application/octet-stream'},method='POST')
# Never automatically retry POST: an uncertain response requires status review.
try:
 with urllib.request.urlopen(req,timeout=90) as r:response=json.load(r);status=r.status
except urllib.error.HTTPError as e:
 receipt['publishHttpStatus']=e.code;receipt['publicationOutcome']='rejected' if 400<=e.code<500 else 'uncertain'
 try:
  error_body=e.read(8192).decode('utf-8','replace')
  for secret in (key,publish_key): error_body=error_body.replace(secret,'[REDACTED]')
  receipt['publishErrorBody']=error_body
 except Exception: receipt['publishErrorBody']='Unavailable'
 save();raise SystemExit(f'Publication HTTP {e.code}; see sanitized receipt; not automatically retried')
except Exception as e:
 receipt['publicationOutcome']='uncertain';receipt['errorClass']=type(e).__name__;save();raise
(OUT/'publish-response.json').write_text(json.dumps(response,indent=2)+'\n')
assert status==200 and type(response.get('versionNumber')) is int and response['versionNumber']>0
receipt.update(published=True,publishHttpStatus=status,versionNumber=response['versionNumber']);save()
print('Roblox confirmed published version',response['versionNumber'],'for place5233405723')
