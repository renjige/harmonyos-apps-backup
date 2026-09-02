/** Copy store/visual/generated/*.png → entry media (skip if staging missing) */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const STAGING = path.join(ROOT, 'store/visual/generated');
const MEDIA = path.join(ROOT, 'app/entry/src/main/resources/base/media');

if (!fs.existsSync(STAGING)) {
  console.error('missing staging:', STAGING);
  process.exit(1);
}

const files = fs.readdirSync(STAGING).filter((f) => f.endsWith('.png'));
let copied = 0;
for (const f of files) {
  const src = path.join(STAGING, f);
  const dst = path.join(MEDIA, f);
  fs.copyFileSync(src, dst);
  copied += 1;
  console.log('installed', f, fs.statSync(dst).size);
}
console.log('done:', copied, 'files →', MEDIA);
