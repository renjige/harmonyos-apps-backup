#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_ROOT = path.resolve(__dirname, '../..');
const LOGO_DIR = path.join(APP_ROOT, 'store/logo');
const PREVIEW = path.join(LOGO_DIR, 'preview-1024.png');

function copy(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

async function main() {
  if (!fs.existsSync(PREVIEW)) {
    console.error('missing preview-1024.png');
    process.exit(1);
  }
  copy(PREVIEW, path.join(LOGO_DIR, 'foreground.png'));
  copy(PREVIEW, path.join(LOGO_DIR, 'background.png'));
  copy(PREVIEW, path.join(LOGO_DIR, 'agc-216.png'));
  const targets = [
    path.join(APP_ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/icon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/startIcon.png'),
    path.join(APP_ROOT, 'app/entry/src/main/resources/base/media/app_icon.png'),
  ];
  for (const dest of targets) {
    copy(PREVIEW, dest);
  }
  console.log('Logo files synced');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
