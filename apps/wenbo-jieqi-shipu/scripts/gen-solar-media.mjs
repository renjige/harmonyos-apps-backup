import fs from 'fs';
import path from 'path';

const slugs = [
  'lichun', 'yushui', 'jingzhe', 'chunfen', 'qingming', 'guyu', 'lixia', 'xiaoman',
  'mangzhong', 'xiazhi', 'xiaoshu', 'dashu', 'liqiu', 'chushu', 'bailu', 'qiufen',
  'hanlu', 'shuangjiang', 'lidong', 'xiaoxue', 'daxue', 'dongzhi', 'xiaohan', 'dahan',
];
const extras = ['hero_bg', 'banner_01', 'banner_02', 'banner_03'];
const keys = [...extras];
for (const s of slugs) {
  keys.push(`term_${s}`, `tip_${s}`, `recipe_${s}_1`, `recipe_${s}_2`);
}
const lines = [
  '/** 栏目封面 → $r(\'app.media.*\')，一 key 一图 */',
  '',
  'export class SolarMedia {',
  '  static resource(key: string): Resource {',
];
for (const k of keys) {
  lines.push(`    if (key === '${k}') {`);
  lines.push(`      return $r('app.media.${k}')`);
  lines.push('    }');
}
lines.push("    return $r('app.media.hero_bg')");
lines.push('  }');
lines.push('}');
lines.push('');

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Z]:)/, '$1')), '..');
const out = path.join(root, 'app/entry/src/main/ets/services/SolarMedia.ets');
fs.writeFileSync(out, lines.join('\n'));
console.log('Wrote', keys.length, 'keys to', out);
