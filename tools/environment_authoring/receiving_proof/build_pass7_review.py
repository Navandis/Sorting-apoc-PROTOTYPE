"""Package the fixed EAF5 Pass 7 wear comparison without source maps."""
import hashlib,json
from collections import defaultdict
from pathlib import Path
from zipfile import ZIP_DEFLATED,ZipFile
from PIL import Image,ImageDraw,ImageFont,ImageOps
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'reports/environment_receiving_proof/eaf5'
FOLDER=BASE/'final_wear_proof_01'
ZIP=BASE/'eaf5_final_wear_proof_01_review.zip'
CAMERAS=('EastApproachOverview','WallCausalDetail','FreightFloorDetail')
LIGHTS=('NEUTRAL_ARCHITECTURAL','RECEIVING_TARGET')
STATES=('WEAR_OFF','WEAR_ON')
IDS=('WEA01','WEA02','WEA03','WEA04')
CRITERIA=[
'Does the room remain strong with wear OFF?',
'Does wear add believable use/history rather than visual noise?',
'Can every wear mark be traced to a plausible cause?',
'Is wear sparse enough for an occupied, maintained bunker?',
'Do large quiet mineral areas remain?',
'Does any wear source dominate or repeat conspicuously?',
'Does the floor remain readable for loot/freight?',
'Does the wall remain readable for future services/signage?',
'Does the alternate remain genuinely viable?',
'Would removing all wear still leave an acceptable production palette?',
]
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def font(n):
 try:return ImageFont.truetype('C:/Windows/Fonts/arial.ttf',n)
 except OSError:return ImageFont.load_default()
def validate():
 m=load(FOLDER/'manifest.json')
 assert m['capture_type']=='CAUSAL_WEAR_FINAL' and len(m['records'])==24
 assert len(load(FOLDER/'sanity/manifest.json')['records'])==6
 by={}
 for r in m['records']:
  key=r['structural_palette_id'],r['camera'],r['light_mode'],r['wear_state']
  assert key not in by
  assert r['visible_wear_overlays']==(4 if r['wear_state']=='WEAR_ON' else 0)
  assert len(r['cause_proxies'])==2 and len(r['wear_instances'])==4
  with Image.open(FOLDER/r['filename']) as im:im.verify()
  by[key]=r
 for p in ('P01_C02','P05_C03'):
  for cam in CAMERAS:
   for light in LIGHTS:
    a=by[p,cam,light,'WEAR_OFF'];b=by[p,cam,light,'WEAR_ON']
    for k in ('camera_transform','camera_fov','light_settings','cause_proxies','piece_geometry_fingerprints','wall','floor','ceiling'):
     assert a[k]==b[k],(p,cam,light,k)
    assert all({k:v for k,v in x.items() if k!='visible'}=={k:v for k,v in y.items() if k!='visible'} for x,y in zip(a['wear_instances'],b['wear_instances']))
 return m,by
def sheet(role,palette,by):
 pid=palette['structural_palette_id']
 page=Image.new('RGB',(2100,1180),(246,245,241));draw=ImageDraw.Draw(page)
 draw.text((30,18),f'EAF5 FINAL CAUSAL WEAR / {role} / {pid}',font=font(33),fill=(24,28,31))
 names='  /  '.join(palette[k]['display_name'] for k in ('wall','floor','ceiling'))
 draw.text((30,62),names,font=font(22),fill=(45,45,45))
 draw.text((30,94),'NO_FINISH  |  NO STRUCTURAL SECONDARY  |  WEA01 mineral / WEA02 crack / WEA03 traffic dust / WEA04 rust',font=font(20),fill=(45,45,45))
 cols=[('NEUTRAL_ARCHITECTURAL','WEAR_OFF','Neutral OFF'),('NEUTRAL_ARCHITECTURAL','WEAR_ON','Neutral ON'),('RECEIVING_TARGET','WEAR_OFF','Receiving OFF'),('RECEIVING_TARGET','WEAR_ON','Receiving ON')]
 for ci,(light,state,label) in enumerate(cols):
  draw.text((30+ci*520,138),label,font=font(22),fill=(20,25,30))
 for ri,cam in enumerate(CAMERAS):
  y=180+ri*330
  draw.text((30,y),cam,font=font(21),fill=(20,25,30))
  for ci,(light,state,label) in enumerate(cols):
   r=by[pid,cam,light,state]
   with Image.open(FOLDER/r['filename']) as im: thumb=ImageOps.fit(im.convert('RGB'),(500,281),Image.Resampling.LANCZOS)
   page.paste(thumb,(30+ci*520,y+30))
 name='contact_sheet_'+role.lower()+'.png'
 page.save(FOLDER/name,optimize=True)
 return name
def main():
 m,by=validate();palettes=load(ROOT/'data/environment/receiving_proof/eaf5_receiving_palette_selection_01.json')['palettes']
 assert [(p['selection_role'],p['structural_palette_id']) for p in palettes]==[('PRIMARY','P01_C02'),('ALTERNATE','P05_C03')]
 sheets=[sheet(p['selection_role'],p,by) for p in palettes]
 template={'review':'EAF5 final causal-wear proof','allowed_decisions':['ACCEPT_WEAR_PROOF','REVISE_WEAR_COMPOSITION','REJECT_FINAL_PALETTE'],'palettes':[{'selection_role':p['selection_role'],'structural_palette_id':p['structural_palette_id'],'decision':'PENDING','rationale':''} for p in palettes],'guidance':'REJECT_FINAL_PALETTE only for a genuinely blocking palette problem exposed by this late proof; revise placement with REVISE_WEAR_COMPOSITION.'}
 save(FOLDER/'decision_template.json',template)
 summary='# EAF5 Pass 7 — final causal-wear proof\n\n'
 summary+='Compare each OFF/ON pair at fixed geometry, palette, proxy, camera and lighting. Only the four approved EAF4 overlays change visibility. The accepted Receiving shell, NO_FINISH base and STRUCTURAL_SECONDARY = NONE are held fixed.\n\n'
 summary+='PRIMARY P01_C02: Dirty Concrete / Worn Concrete Floor / Shuttered Concrete Wall. ALTERNATE P05_C03: KB3D_BTL_ConcreteRoughPanelBright / Worn Concrete Floor / KB3D_AMC_ConcreteWhite. The same wear manifest applies to both.\n\n'
 summary+='WEA01 mineral leak begins under the small service pipe; WEA02 crack sits at the upper east Backlog opening corner; WEA03 traffic dust follows the freight path; WEA04 rust debris sits beside existing BarrierProxy_Post02. The pipe and freight barrier remain in OFF.\n\n'
 summary+='## Human review criteria\n\n'+'\n'.join(f'{i}. {x}' for i,x in enumerate(CRITERIA,1))+'\n\n'
 summary+='Wear may enrich the palette; wear may not rescue it. Decide PRIMARY and ALTERNATE separately in decision_template.json. Structural selection is already human-approved.\n'
 (FOLDER/'summary.md').write_text(summary,encoding='utf-8')
 allow=[r['filename'] for r in m['records']]+sheets+['manifest.json','summary.md','decision_template.json']
 assert len(allow)==29 and len(set(allow))==29
 with ZipFile(ZIP,'w',ZIP_DEFLATED,compresslevel=6) as z:
  for name in allow:z.write(FOLDER/name,arcname=name)
 with ZipFile(ZIP) as z:
  assert z.testzip() is None and set(z.namelist())==set(allow)
 print('captures',24,'contact_sheets',2,'zip',ZIP,'sha256',hashlib.sha256(ZIP.read_bytes()).hexdigest())
if __name__=='__main__':main()
