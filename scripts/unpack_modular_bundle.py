"""Reconstruct validated asset-only import inputs from repository chunks."""
import pathlib,json,hashlib,zipfile,sys
R=pathlib.Path('assets/runewake-bulk');request=json.loads((R/'request.json').read_text());request['assets']=request['assets'][int(sys.argv[1])*20:(int(sys.argv[1])+1)*20];pathlib.Path('batch-request.json').write_text(json.dumps(request));bundle=request['bundle'];out=pathlib.Path('runewake-inputs.zip');h=hashlib.sha256()
with out.open('wb') as f:
 for piece in bundle['parts']:
  p=R/piece['file'];b=p.read_bytes();assert hashlib.sha256(b).hexdigest()==piece['sha256'];h.update(b);f.write(b)
assert h.hexdigest()==bundle['sha256']
with zipfile.ZipFile(out) as z:
 recipes={a['key']:a for a in json.loads(z.read('recipes.json'))['assets']}
 for a in request['assets']:
  rec=recipes[a['key']];assert rec['sha256']==a['sha256'] and rec['file']==a['file'];p=pathlib.Path(a['file']);assert not p.is_absolute() and '..' not in p.parts and p.parts[0]=='asset-stage';p.parent.mkdir(parents=True,exist_ok=True);data=bytearray()
  for s in rec['chunks']:
   b=z.read('chunks/'+s);assert hashlib.sha256(b).hexdigest()==s;data.extend(b)
  assert len(data)==rec['bytes'] and hashlib.sha256(data).hexdigest()==a['sha256'];p.write_bytes(data)
 print('Reconstructed',len(request['assets']),'validated models')
