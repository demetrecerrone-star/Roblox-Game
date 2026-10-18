#!/usr/bin/env python3
"""Asset-only, zero-fee uploader. Never publishes a place or creates animations."""
import argparse,hashlib,json,os,pathlib,re,struct,subprocess,time
from urllib.request import Request,urlopen
P=pathlib.Path
API='https://apis.roblox.com/assets/v1/'
CREATOR=1718096156

def get(url):
 with urlopen(Request(url,headers={'User-Agent':'RunewakeImporter/1.0'}),timeout=45) as r:return json.load(r)

def validate(path,expected):
 raw=path.read_bytes()
 assert len(raw)<=20_000_000 and len(raw)>28,'GLB size'
 assert hashlib.sha256(raw).hexdigest()==expected,'File checksum'
 assert struct.unpack_from('<4sII',raw)==(b'glTF',2,len(raw)),'GLB header'
 n,kind=struct.unpack_from('<II',raw,12);assert kind==0x4e4f534a
 doc=json.loads(raw[20:20+n]);assert doc.get('meshes'),'No meshes'
 assert not any('uri' in x for x in doc.get('buffers',[])+doc.get('images',[])),'External dependency'
 return doc

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--manifest',required=True);ap.add_argument('--resume');ap.add_argument('--validate-only',action='store_true');a=ap.parse_args()
 manifest=json.loads(P(a.manifest).read_text());assets=manifest['assets'];assert assets and len({x['key'] for x in assets})==len(assets)
 for row in assets:validate(P(row['file']),row['sha256']);assert row['pack'] in ['village','props','outfits','stylized-nature-megakit','ultimate-stylized-nature','universal-base-characters','textured-stylized-trees','nature-crops','ultimate-nature'],'Pack not approved'
 if a.validate_only:print('Validated',len(assets));return
 assert os.environ.get('GITHUB_RUN_ATTEMPT','1')=='1','Do not rerun jobs; create a new reviewed request with merged ledger to avoid duplicate uploads'
 key=os.environ.get('ROBLOX_ASSET_API_KEY','');assert key,'ROBLOX_ASSET_API_KEY is missing; no uploads attempted.'
 # Secret is used only in the existing API header, never printed or persisted.
 owner=get('https://economy.roblox.com/v2/assets/5233405723/details')
 universe=get('https://develop.roblox.com/v1/universes/1831369670')
 assert owner['Creator']['Id']==CREATOR and universe['creatorTargetId']==CREATOR and universe['rootPlaceId']==5233405723,'Ownership changed'
 ledger=json.loads(P(a.resume).read_text()) if a.resume else {'creatorUserId':CREATOR,'assets':{}}
 assert ledger['creatorUserId']==CREATOR
 def save(row):
  ledger['assets'][row['key']]=row
  tmp=P('upload-results.json.tmp');tmp.write_text(json.dumps(ledger,indent=2)+'\n')
  with tmp.open('rb') as f:os.fsync(f.fileno())
  tmp.replace('upload-results.json')
  print('RUNEWAKE_STATE '+json.dumps(row,separators=(',',':')),flush=True)
 def call(args):
  result=subprocess.run(['curl','--http1.1','-H','Expect:','--silent','--show-error','--max-time','180','--write-out','\n%{http_code}','-H','x-api-key: '+key,*args],capture_output=True,text=True)
  body,_,status=result.stdout.rpartition('\n')
  if result.returncode:raise RuntimeError('Transport failure; create outcome may be uncertain. Inspect ledger, do not recreate.')
  if not status.startswith('2'):raise RuntimeError('Roblox HTTP '+status+': '+body[:1500])
  return json.loads(body)
 for asset in assets:
  old=ledger['assets'].get(asset['key'])
  if old:
   assert old['sha256']==asset['sha256'],'Source differs from resume ledger'
   if old.get('assetId'):continue
   if old.get('state') in ['create_intent','failed']:raise RuntimeError('Blocked uncertain/failed prior operation: '+asset['key'])
   row=old
  else:
   row={k:asset[k] for k in ['key','pack','name','sha256']};row['state']='create_intent';save(row)
   metadata={'assetType':'Model','displayName':'Runewake '+asset['name'],'description':'Quaternius CC0 modular pack: '+asset['pack']+'. Source-preserving import.','creationContext':{'creator':{'userId':str(CREATOR)},'expectedPrice':0}}
   for create_attempt in range(3):
    try:
     op=call(['-X','POST',API+'assets','-F','request='+json.dumps(metadata),'-F','fileContent=@'+asset['file']+';type=model/gltf-binary'])
     row.pop('error',None)
     break
    except Exception as e:
     row['error']=str(e);save(row)
     # Only an explicit server-side form-read rejection proves no create operation
     # began. Never retry uncertain transport errors or other POST failures.
     if str(e).startswith('Roblox HTTP 400:') and 'Failed to read the request form' in str(e) and 'MinRequestBodyDataRate' in str(e) and create_attempt<2:
      row.setdefault('rejectedRequestAttempts',[]).append(str(e));save(row);time.sleep(15*(create_attempt+1));continue
     raise
   path=op.get('path','');assert re.fullmatch(r'operations/[A-Za-z0-9_-]+',path),'Invalid operation path'
   row.update(state='processing',operation=path);save(row)
  for attempt in range(180):
   state=call([API+row['operation']])
   if state.get('done'):
    if state.get('error'):row.update(state='failed',error=state['error']);save(row);raise RuntimeError('Roblox rejected model '+asset['key'])
    response=state.get('response',{});aid=str(response.get('assetId',''));assert aid.isdigit() and int(aid)>0,'Missing asset ID'
    row.update(state='uploaded',assetId=int(aid),moderation=response.get('moderationResult'));save(row);break
   time.sleep(5)
  else:raise RuntimeError('Operation still processing; resume the saved operation, do not recreate')
  time.sleep(1)
 print('Uploaded or resumed',len(assets),'models. Studio insertion and Animation publication not performed.',flush=True)
if __name__=='__main__':main()
