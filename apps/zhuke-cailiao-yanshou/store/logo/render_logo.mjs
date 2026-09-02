#!/usr/bin/env node
/**
 * Copy pre-rendered geometric logo PNGs (no Python required on this machine).
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const preview = path.join(ROOT, 'preview-1024.png');
if (!fs.existsSync(preview)) {
  console.error('missing preview-1024.png');
  process.exit(1);
}
const buf = fs.readFileSync(preview);
for (const name of ['background.png', 'foreground.png', 'agc-216.png']) {
  const dest = path.join(ROOT, name);
  if (!fs.existsSync(dest)) {
    fs.writeFileSync(dest, buf);
  }
}
console.log('OK logo png masters present');
