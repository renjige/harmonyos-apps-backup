#!/usr/bin/env node
/**
 * 将 AI 生成的精美封面复制到 DevEco media/（重建工程前运行）
 * 源图：仓库 assets/ 或 store/logo/content/
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '../../..');
const ASSETS = path.join(ROOT, '.cursor/projects/e-huawei001-master/assets');
const ALT = path.join(__dirname, 'content');
const DST = path.join(ROOT, 'apps/wenbo-zhishi-tanbao/app/entry/src/main/resources/base/media');

const FILES = [
  'card_history_paper.png',
  'card_science_light.png',
  'card_literature_shijing.png',
  'card_art_dunhuang.png',
  'card_philosophy_socrates.png',
  'card_general_compass.png',
  'card_science_dna.png',
  'hero_treasure.png',
];

function srcDir() {
  if (fs.existsSync(ASSETS)) return ASSETS;
  if (fs.existsSync(ALT)) return ALT;
  return null;
}

function main() {
  const src = srcDir();
  if (!src) {
    console.error('No image source found. Put PNGs in store/logo/content/');
    process.exit(1);
  }
  fs.mkdirSync(DST, { recursive: true });
  for (const f of FILES) {
    const from = path.join(src, f);
    if (!fs.existsSync(from)) {
      console.warn('skip missing', f);
      continue;
    }
    fs.copyFileSync(from, path.join(DST, f));
    console.log('copied', f);
  }
  const covers = [
    ['cover_history.png', 'card_history_paper.png'],
    ['cover_science.png', 'card_science_light.png'],
    ['cover_literature.png', 'card_literature_shijing.png'],
    ['cover_art.png', 'card_art_dunhuang.png'],
    ['cover_philosophy.png', 'card_philosophy_socrates.png'],
    ['cover_general.png', 'card_general_compass.png'],
  ];
  for (const [dest, from] of covers) {
    const p = path.join(DST, from);
    if (fs.existsSync(p)) {
      fs.copyFileSync(p, path.join(DST, dest));
    }
  }
  console.log('done →', DST);
}

main();
