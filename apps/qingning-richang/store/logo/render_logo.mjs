#!/usr/bin/env node
/**
 * Rasterize symbol.svg → store/logo PNGs + sync app icons.
 * Requires: npm i sharp (repo root)
 */
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
  const sizes = [
    ['foreground.png', 1024, { flatten: false }],
    ['background.png', 1024, { flatten: { background: '#2D4A1E' } }],
    ['preview-1024.png', 1024, { flatten: { background: '#2D4A1E' } }],
    ['agc-216.png', 216, { flatten: { background: '#2D4A1E' } }],
  ];
  for (const [name, size, opts] of sizes) {
    let img = sharp(svg).resize(size, size);
    if (opts.flatten) {
      img = img.flatten(opts.flatten === true ? undefined : opts.flatten);
    }
    await img.png().toFile(path.join(LOGO_DIR, name));
  }
  const appIcon = path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png');
  const entryIcon = path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png');
  const startIcon = path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png');
  for (const dest of [appIcon, entryIcon, startIcon]) {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    await sharp(path.join(LOGO_DIR, 'preview-1024.png')).resize(512, 512).png().toFile(dest);
  }
  console.log('Logo rendered OK');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
