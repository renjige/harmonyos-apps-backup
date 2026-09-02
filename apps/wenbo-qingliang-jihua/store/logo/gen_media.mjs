/** Generate placeholder hero PNGs for DevEco media sync */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(__dirname, '../../app/entry/src/main/resources/base/media');

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const t = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0);
  return Buffer.concat([len, t, data, crc]);
}

function encodePng(w, h, rgba) {
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) {
    raw[y * (w * 4 + 1)] = 0;
    rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function grad(w, h, top, bot) {
  const buf = Buffer.alloc(w * h * 4);
  for (let y = 0; y < h; y++) {
    const t = y / (h - 1);
    for (let x = 0; x < w; x++) {
      const i = (y * w + x) * 4;
      buf[i] = Math.round(top[0] * (1 - t) + bot[0] * t);
      buf[i + 1] = Math.round(top[1] * (1 - t) + bot[1] * t);
      buf[i + 2] = Math.round(top[2] * (1 - t) + bot[2] * t);
      buf[i + 3] = 255;
    }
  }
  return buf;
}

const items = [
  ['hero_mist_lake', [0xe8, 0xf4, 0xf8], [0x2d, 0x8b, 0x7a]],
  ['hero_tea_steam', [0xf5, 0xfa, 0xf8], [0x4a, 0x9e, 0x9e]],
  ['hero_morning_leaf', [0xd4, 0xed, 0xe0], [0x1f, 0x6b, 0x5e]],
  ['hero_breath_calm', [0xc8, 0xe6, 0xdf], [0x2d, 0x8b, 0x7a]],
  ['hero_breath_focus', [0xb8, 0xd8, 0xe8], [0x1a, 0x5a, 0x72]],
  ['hero_breath_sleep', [0xd0, 0xd8, 0xf0], [0x3a, 0x4a, 0x7a]],
  ['banner_cool_ring', [0x7e, 0xc8, 0xb0], [0x2d, 0x8b, 0x7a]],
];

fs.mkdirSync(OUT, { recursive: true });
for (const [name, top, bot] of items) {
  fs.writeFileSync(path.join(OUT, `${name}.png`), encodePng(800, 480, grad(800, 480, top, bot)));
  console.log('wrote', name);
}

const logo = path.join(__dirname, 'preview-1024.png');
if (fs.existsSync(logo)) {
  for (const t of ['icon.png', 'startIcon.png']) {
    fs.copyFileSync(logo, path.join(OUT, t));
  }
  fs.copyFileSync(logo, path.join(__dirname, '../../app/AppScope/resources/base/media/app_icon.png'));
}

console.log('media done');
