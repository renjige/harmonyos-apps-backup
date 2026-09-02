#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SVG = path.join(LOGO_DIR, 'symbol.svg');
const BG = '#1A2332';

async function main() {
  let sharp;
  try {
    sharp = (await import('sharp')).default;
  } catch {
    console.error('Install sharp: npm i sharp');
    process.exit(1);
  }
  const svg = fs.readFileSync(SVG);
  await sharp(svg).resize(1024, 1024).png().toFile(path.join(LOGO_DIR, 'foreground.png'));
  await sharp({ create: { width: 1024, height: 1024, channels: 3, background: BG } })
    .png().toFile(path.join(LOGO_DIR, 'background.png'));
  await sharp(svg).resize(1024, 1024).flatten({ background: BG }).png().toFile(path.join(LOGO_DIR, 'preview-1024.png'));
  await sharp(svg).resize(216, 216).flatten({ background: BG }).png().toFile(path.join(LOGO_DIR, 'agc-216.png'));
  const targets = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
  ];
  for (const dest of targets) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    await sharp(path.join(LOGO_DIR, 'preview-1024.png')).resize(512, 512).png().toFile(dest);
  }
  console.log('Logo rendered OK (foreground + background split)');
}

main().catch((e) => { console.error(e); process.exit(1); });
