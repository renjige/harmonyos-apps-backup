#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SVG = path.join(LOGO_DIR, 'symbol.svg');
const BG = '#1A1A2E';

const LAYERED_JSON = JSON.stringify({
  'layered-image': {
    background: '$media:icon_background',
    foreground: '$media:icon_foreground',
  },
}, null, 2);

async function main() {
  let sharp;
  try {
    sharp = (await import('sharp')).default;
  } catch {
    console.error('Install sharp: npm i sharp');
    process.exit(1);
  }
  const svg = fs.readFileSync(SVG);
  const layers = [
    ['foreground.png', 1024, null],
    ['background.png', 1024, { background: BG }],
    ['preview-1024.png', 1024, { background: BG }],
    ['agc-216.png', 216, { background: BG }],
  ];
  for (const [name, size, flatten] of layers) {
    let img = sharp(svg).resize(size, size);
    if (flatten) img = img.flatten(flatten);
    await img.png().toFile(path.join(LOGO_DIR, name));
  }

  const targets = [
    ['app/AppScope/resources/base/media/icon_foreground.png', 'foreground.png'],
    ['app/AppScope/resources/base/media/icon_background.png', 'background.png'],
    ['app/entry/src/main/resources/base/media/icon_foreground.png', 'foreground.png'],
    ['app/entry/src/main/resources/base/media/icon_background.png', 'background.png'],
  ];
  for (const [destRel, srcName] of targets) {
    const dest = path.join(APP_ROOT, destRel);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(path.join(LOGO_DIR, srcName), dest);
  }

  const layeredDirs = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media'),
  ];
  for (const dir of layeredDirs) {
    fs.writeFileSync(path.join(dir, 'layered_image.json'), LAYERED_JSON);
  }

  fs.copyFileSync(path.join(LOGO_DIR, 'preview-1024.png'), path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'));

  console.log('观物 Logo rendered OK (layered 1024 + layered_image.json)');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
