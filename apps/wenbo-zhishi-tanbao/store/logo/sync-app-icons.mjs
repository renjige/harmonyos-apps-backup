#!/usr/bin/env node
/** 从 store/logo/app_icon.png 生成各尺寸工程图标（sharp 高质量缩放） */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { createRequire } from 'module';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);

const SRC = path.join(__dirname, 'app_icon.png');
const FALLBACK = path.join(__dirname, '../../../.cursor/projects/e-huawei001-master/assets/zhishi-tanbao-app-icon.png');
const SHARP_PATH = path.join(__dirname, '../../../mingyue-mingyue-fang/store/node_modules/sharp');

const input = fs.existsSync(SRC) ? SRC : FALLBACK;
if (!fs.existsSync(input)) {
  console.error('Missing app_icon source:', input);
  process.exit(1);
}

let sharp;
try {
  sharp = require(SHARP_PATH);
} catch {
  console.error('sharp not found at', SHARP_PATH);
  process.exit(1);
}

const root = path.join(__dirname, '../..');
const targets = [
  { size: 1024, dest: path.join(__dirname, 'preview-1024.png') },
  { size: 1024, dest: path.join(__dirname, 'app_icon.png') },
  { size: 1024, dest: path.join(root, 'app/AppScope/resources/base/media/app_icon.png') },
  { size: 256, dest: path.join(root, 'app/entry/src/main/resources/base/media/icon.png') },
  { size: 256, dest: path.join(root, 'app/entry/src/main/resources/base/media/startIcon.png') },
  { size: 128, dest: path.join(root, 'app/entry/src/main/resources/base/media/app_logo.png') },
];

async function main() {
  for (const t of targets) {
    if (path.resolve(t.dest) === path.resolve(input)) {
      continue;
    }
    fs.mkdirSync(path.dirname(t.dest), { recursive: true });
    await sharp(input)
      .resize(t.size, t.size, { fit: 'cover' })
      .png()
      .toFile(t.dest);
    console.log('wrote', t.dest, t.size);
  }
  console.log('done');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
