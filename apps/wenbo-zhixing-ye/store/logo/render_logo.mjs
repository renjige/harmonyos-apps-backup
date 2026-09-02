#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import sharp from 'sharp';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const SYMBOL = path.join(LOGO_DIR, 'symbol.svg');

async function main() {
  const svg = fs.readFileSync(SYMBOL);
  const preview = await sharp(svg, { density: 384 })
    .resize(1024, 1024, { fit: 'cover' })
    .png()
    .toBuffer();
  fs.writeFileSync(path.join(LOGO_DIR, 'preview-1024.png'), preview);

  const bg = await sharp({
    create: { width: 1024, height: 1024, channels: 3, background: { r: 26, g: 42, b: 108 } }
  }).png().toBuffer();
  fs.writeFileSync(path.join(LOGO_DIR, 'background.png'), bg);

  const fgSvg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <path d="M268 348 L492 292 L492 732 L248 688 Z" fill="#F4EBD0"/>
  <path d="M532 292 L756 348 L776 688 L532 732 Z" fill="#E8D9B0"/>
  <rect x="492" y="276" width="40" height="468" rx="8" fill="#C9A84C"/>
  <path d="M512 640 L620 470 L742 318" fill="none" stroke="#C9A84C" stroke-width="36" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M686 268 L742 318 L692 374" fill="none" stroke="#C9A84C" stroke-width="36" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`;
  const fg = await sharp(Buffer.from(fgSvg), { density: 384 })
    .resize(1024, 1024)
    .png()
    .toBuffer();
  fs.writeFileSync(path.join(LOGO_DIR, 'foreground.png'), fg);

  const agc = await sharp(preview).resize(216, 216).png().toBuffer();
  fs.writeFileSync(path.join(LOGO_DIR, 'agc-216.png'), agc);

  const targets = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/app_icon.png'),
  ];
  for (const dest of targets) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, preview);
  }
  console.log('Logo rasterized and synced');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
