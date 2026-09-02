#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SVG = path.join(LOGO_DIR, 'symbol.svg');

async function main() {
  let sharp;
  try {
    sharp = (await import('sharp')).default;
  } catch {
    console.error('Install sharp: npm i sharp');
    process.exit(1);
  }
  const svg = fs.readFileSync(SVG);
  const bg = '#3D5566';
  const sizes = [
    ['foreground.png', 1024, false],
    ['background.png', 1024, true],
    ['preview-1024.png', 1024, true],
    ['agc-216.png', 216, true],
  ];
  for (const [name, size, flat] of sizes) {
    let img = sharp(svg).resize(size, size);
    if (flat) {
      img = img.flatten({ background: bg });
    }
    await img.png().toFile(path.join(LOGO_DIR, name));
  }
  const targets = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/app_icon.png'),
  ];
  for (const dest of targets) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(path.join(LOGO_DIR, 'preview-1024.png'), dest);
  }
  console.log('Logo rendered OK');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
