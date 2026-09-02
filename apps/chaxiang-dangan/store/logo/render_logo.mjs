#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SVG = path.join(LOGO_DIR, 'symbol.svg');
const BG = '#1C2E26';

async function main() {
  let sharp;
  try {
    sharp = (await import('sharp')).default;
  } catch {
    console.error('Install sharp: npm i sharp');
    process.exit(1);
  }
  const svg = fs.readFileSync(SVG);
  const jobs = [
    ['foreground.png', 1024, null],
    ['background.png', 1024, { background: BG }],
    ['preview-1024.png', 1024, { background: BG }],
    ['agc-216.png', 216, { background: BG }],
  ];
  for (const job of jobs) {
    const name = job[0];
    const size = job[1];
    const flatten = job[2];
    let img = sharp(svg).resize(size, size);
    if (flatten) {
      img = img.flatten(flatten);
    }
    await img.png().toFile(path.join(LOGO_DIR, name));
  }
  const preview = path.join(LOGO_DIR, 'preview-1024.png');
  const dests = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/app_icon.png'),
  ];
  for (const dest of dests) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(preview, dest);
  }
  console.log('茶香档案 Logo rendered OK');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
