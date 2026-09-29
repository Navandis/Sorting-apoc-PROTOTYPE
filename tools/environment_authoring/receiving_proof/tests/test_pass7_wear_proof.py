import json,unittest,hashlib
from pathlib import Path
from collections import Counter,defaultdict
from zipfile import ZipFile
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[4]
DATA=ROOT/'data/environment/receiving_proof'
BASE=ROOT/'reports/environment_receiving_proof/eaf5'
FOLDER=BASE/'final_wear_proof_01'
ZIP=BASE/'eaf5_final_wear_proof_01_review.zip'
IDS={'eaf4b_cd7701bd0cdb622c63628103','eaf4b_c3b63b5da3fbdda32be47bd0','eaf4b_7efdf22029c82320d62147c7','eaf4b_89c9cb7aa962b19eda21f278'}
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
class Pass7WearProofTests(unittest.TestCase):
 def test_decisions_palette_and_current_specs(self):
  d=read(DATA/'decisions/eaf5_applied_finish_layouts_01_human_review_01.json')
  self.assertEqual(Counter(x['decision'] for x in d['configurations']),{'HOLD_LAYOUT_VARIANT':5,'DROP_LAYOUT_VARIANT':5,'CONTROL_NO_FINISH':3})
  self.assertEqual(d['base_applied_finish_direction'],'NO_FINISH')
  p=read(DATA/'eaf5_receiving_palette_selection_01.json')
  self.assertEqual([(x['selection_role'],x['structural_palette_id']) for x in p['palettes']],[('PRIMARY','P01_C02'),('ALTERNATE','P05_C03')])
  self.assertTrue(all(x['applied_finish']==x['structural_secondary']=='NONE' for x in p['palettes']))
  m=read(DATA/'eaf5_receiving_wear_proof_01.json')
  self.assertEqual(m['accepted_shell_composition_sha256'],sha(DATA/'eaf5_receiving_proof_composition_v2.json'))
  self.assertEqual({x['catalog_wear_id'] for x in m['instances']},IDS)
  crack=next(x for x in m['instances'] if x['instance_id']=='WEA02')
  self.assertGreater(crack['world_position_m'][2],1.92)
  self.assertEqual(crack['target_eaf2_piece'],'ReceivingEastOpeningWall')
  catalog={x['catalog_wear_id']:x for x in read(ROOT/'data/environment/wear_catalog/catalog.json')['wear']}
  for x in m['instances']:
   c=catalog[x['catalog_wear_id']]
   self.assertEqual(c['effective_status'],'APPROVED')
   self.assertEqual(c['reviewed_source_fingerprint'],c['current_source_fingerprint'])
   self.assertEqual(x['approved_source_fingerprint'],c['reviewed_source_fingerprint'])
   if c.get('imperfection'):
    self.assertEqual(c['current_imperfection_fingerprint'],c['imperfection']['source_fingerprint'])
   self.assertEqual(x['approved_physical_size_m'],c['default_size'])
   self.assertTrue((ROOT/x['approved_spec_path'].removeprefix('res://')).is_file())
 def test_capture_matrix_and_parity(self):
  m=read(FOLDER/'manifest.json');s=read(FOLDER/'sanity/manifest.json')
  self.assertEqual(len(m['records']),24)
  self.assertEqual(len(s['records']),6)
  self.assertEqual(Counter(x['structural_palette_id'] for x in m['records']),{'P01_C02':12,'P05_C03':12})
  prior=read(BASE/'applied_finish_layouts_01/manifest.json')
  self.assertEqual(m['environment'],prior['environment'])
  self.assertEqual(m['pieces'],prior['pieces'])
  prior_lights={}
  for record in prior['records']:
   prior_lights.setdefault(record['light_mode'],record['light_settings'])
  pairs=defaultdict(dict)
  shared_cameras={}
  shared_lights={}
  shared_causes=None
  shared_overlay_placements=None
  for x in m['records']:
   self.assertEqual(len(x['wear_instances']),4)
   self.assertEqual(x['visible_wear_overlays'],4 if x['wear_state']=='WEAR_ON' else 0)
   self.assertEqual(len(x['cause_proxies']),2)
   self.assertEqual(len(x['piece_geometry_fingerprints']),14)
   self.assertEqual(x['light_settings'],prior_lights[x['light_mode']])
   self.assertEqual((x['camera_transform'],x['camera_fov']),shared_cameras.setdefault(x['camera'],(x['camera_transform'],x['camera_fov'])))
   if shared_causes is None:shared_causes=x['cause_proxies']
   self.assertEqual(x['cause_proxies'],shared_causes)
   placements=[{k:v for k,v in item.items() if k!='visible'} for item in x['wear_instances']]
   if shared_overlay_placements is None:shared_overlay_placements=placements
   self.assertEqual(placements,shared_overlay_placements)
   pairs[(x['structural_palette_id'],x['camera'],x['light_mode'])][x['wear_state']]=x
   with Image.open(FOLDER/x['filename']) as im:im.verify()
  self.assertEqual(len(pairs),12)
  for pair in pairs.values():
   self.assertEqual(set(pair),{'WEAR_OFF','WEAR_ON'})
   a,b=pair['WEAR_OFF'],pair['WEAR_ON']
   for key in ('camera_transform','camera_fov','light_settings','cause_proxies','piece_geometry_fingerprints','proof_composition_sha256','wall','floor','ceiling'):
    self.assertEqual(a[key],b[key],key)
   for ai,bi in zip(a['wear_instances'],b['wear_instances']):
    self.assertEqual({k:v for k,v in ai.items() if k!='visible'},{k:v for k,v in bi.items() if k!='visible'})
    self.assertFalse(ai['visible']);self.assertTrue(bi['visible'])
   with Image.open(FOLDER/a['filename']) as off,Image.open(FOLDER/b['filename']) as on:
    self.assertIsNotNone(ImageChops.difference(off.convert('RGB'),on.convert('RGB')).getbbox())
 def test_review_package(self):
  template=read(FOLDER/'decision_template.json')
  self.assertEqual([(x['selection_role'],x['decision']) for x in template['palettes']],[('PRIMARY','PENDING'),('ALTERNATE','PENDING')])
  expected={x['filename'] for x in read(FOLDER/'manifest.json')['records']}|{'contact_sheet_primary.png','contact_sheet_alternate.png','manifest.json','summary.md','decision_template.json'}
  for name in ('contact_sheet_primary.png','contact_sheet_alternate.png'):
   with Image.open(FOLDER/name) as im:im.verify()
  with ZipFile(ZIP) as z:
   self.assertIsNone(z.testzip())
   self.assertEqual(set(z.namelist()),expected)
if __name__=='__main__':unittest.main()
