/** Sync Cursor assets/*.png → store/visual/generated + entry media (by manifest filenames) */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const ASSETS = path.resolve(ROOT, '../../../.cursor/projects/e-huawei001-master/assets');
const ALT_ASSETS = 'C:/Users/Administrator/.cursor/projects/e-huawei001-master/assets';
const STAGING = path.join(ROOT, 'store/visual/generated');
const MEDIA = path.join(ROOT, 'app/entry/src/main/resources/base/media');
const manifest = JSON.parse(fs.readFileSync(path.join(ROOT, 'store/visual/photo-manifest.json'), 'utf8'));

const srcDir = fs.existsSync(ASSETS) ? ASSETS : ALT_ASSETS;
fs.mkdirSync(STAGING, { recursive: true });

let copied = 0;
for (const item of manifest.items) {
  const src = path.join(srcDir, item.file);
  if (!fs.existsSync(src)) continue;
  const st = fs.statSync(src);
  if (st.size < 10000) continue;
  fs.copyFileSync(src, path.join(STAGING, item.file));
  fs.copyFileSync(src, path.join(MEDIA, item.file));
  copied += 1;
}
console.log('synced', copied, '/', manifest.items.length, 'from', srcDir);
