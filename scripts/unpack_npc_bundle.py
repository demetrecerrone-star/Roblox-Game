"""Validate and extract exactly the three approved existing NPC models."""
import hashlib,json,pathlib,zipfile
P=pathlib.Path
r=json.loads(P('assets/runewake-bulk/request.json').read_text())
a=P(r['archive']);assert str(a)=='assets/npc/Runewake_Animated_NPCs_v0.3.zip'
assert hashlib.sha256(a.read_bytes()).hexdigest()==r['archiveSha256']
assert {x['key'] for x in r['assets']}=={'npcs/mira_threadlight','npcs/orren_kilnhand','npcs/pip_wicks'}
with zipfile.ZipFile(a) as z:
 for row in r['assets']:
  p=P(row['file']);assert not p.is_absolute() and '..' not in p.parts and p.parts[:2]==('asset-stage','npcs')
  b=z.read(row['archiveMember']);assert hashlib.sha256(b).hexdigest()==row['sha256'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
P('batch-request.json').write_text(json.dumps(r))
print('Extracted and hash-verified three prepared NPC models')
