/**
 * 压缩 store/visual → app media（书籍 640×480，Hero 1280×720，JPEG quality 88）
 */
import fs from 'fs';
import path from 'path';
import sharp from 'sharp';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const SRC = path.join(ROOT, 'visual');
const OUT = path.join(ROOT, '../app/entry/src/main/resources/base/media');

const BOOKS = [
  'book_classics_1', 'book_classics_2', 'book_classics_3',
  'book_classics_4', 'book_classics_5', 'book_classics_6', 'book_default',
];
const HEROES = [
  'hero_reading_desk', 'hero_reading_classics', 'hero_borrow_books',
  'hero_honest_reading', 'hero_poetry_grace', 'hero_dialogue_books', 'hero_ladder_books',
];

async function compressOne(name, w, h) {
  const input = path.join(SRC, `${name}.png`);
  const output = path.join(OUT, `${name}.png`);
  if (!fs.existsSync(input)) {
    console.warn(`skip missing ${input}`);
    return;
  }
  await sharp(input)
    .resize(w, h, { fit: 'cover', position: 'centre' })
    .png({ compressionLevel: 9, palette: false })
    .toFile(output);
  const kb = Math.round(fs.statSync(output).size / 1024);
  console.log(`OK ${name}.png → ${w}×${h} (${kb} KB)`);
}

fs.mkdirSync(OUT, { recursive: true });
for (const name of BOOKS) {
  await compressOne(name, 640, 480);
}
for (const name of HEROES) {
  await compressOne(name, 1280, 720);
}
console.log('Done compress →', OUT);
