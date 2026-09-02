#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SVG = path.join(LOGO_DIR, 'symbol.svg');
const BG = '#007AFF';

async function main() {
  let sharp;
  try {
    sharp = (await import('sharp')).default;
  } catch {
    console.error('Install sharp: npm i sharp');
    process.exit(1);
  }
  const svg = fs.readFileSync(SVG);
  const fgSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" fill="none">
  <path d="M512 168 L792 312 V512 C792 692 672 832 512 872 C352 832 232 692 232 512 V312 Z" fill="#FFFFFF"/>
  <path d="M360 520 L470 640 L680 400" stroke="#007AFF" stroke-width="72" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="692" cy="332" r="36" fill="#FF6B35"/>
</svg>`;
  await sharp(Buffer.from(fgSvg)).resize(1024, 1024).png().toFile(path.join(LOGO_DIR, 'foreground.png'));
  await sharp({ create: { width: 1024, height: 1024, channels: 3, background: BG } }).png().toFile(path.join(LOGO_DIR, 'background.png'));
  await sharp(svg).resize(1024, 1024).flatten({ background: BG }).png().toFile(path.join(LOGO_DIR, 'preview-1024.png'));
  await sharp(svg).resize(216, 216).flatten({ background: BG }).png().toFile(path.join(LOGO_DIR, 'agc-216.png'));
  const dests = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/app_icon.png'),
  ];
  for (const dest of dests) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    await sharp(path.join(LOGO_DIR, 'preview-1024.png')).resize(512, 512).png().toFile(dest);
  }
  console.log('训练拾趣 Logo rendered OK');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
