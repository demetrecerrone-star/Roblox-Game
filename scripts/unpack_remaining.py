import pathlib,json,zipfile,hashlib
P=pathlib.Path
r=json.loads(P('assets/runewake-bulk/request.json').read_text());assert r['phase']=='remaining-noncharacters65' and len(r['assets'])==65
p=P(r['archive']);assert str(p)=='assets/runewake-bulk/remaining-inputs.zip';assert hashlib.sha256(p.read_bytes()).hexdigest()==r['archiveSha256']
with zipfile.ZipFile(p) as z:
 for a in r['assets']:
  assert a['pack'] in ['weapons','dungeon'] and a['key'].split('/')[0]==a['pack'];f=P(a['file']);assert not f.is_absolute() and '..' not in f.parts and f.parts[0]=='asset-stage'
  b=z.read(a['archiveMember']);assert hashlib.sha256(b).hexdigest()==a['sha256'];f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(b)
P('batch-request.json').write_text(json.dumps(r))
