#!/usr/bin/env node
/** 知识探宝 — 封面 / Hero 摄影风格渐变 PNG */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(ROOT, '../../app/entry/src/main/resources/base/media');
const APP_SCOPE = path.join(ROOT, '../../app/AppScope/resources/base/media');
const W = 800;
const H = 520;

const PALETTE = {
  cover_history: [26, 42, 108],
  cover_science: [0, 82, 140],
  cover_literature: [75, 54, 33],
  cover_art: [139, 58, 98],
  cover_philosophy: [27, 58, 45],
  cover_general: [26, 42, 108],
  card_history_paper: [180, 150, 100],
  card_science_light: [60, 120, 200],
  card_literature_shijing: [90, 70, 50],
  card_art_dunhuang: [200, 120, 60],
  card_philosophy_socrates: [40, 80, 70],
  card_general_compass: [201, 168, 76],
  card_science_dna: [50, 100, 180],
  hero_treasure: [26, 42, 108],
  icon: [26, 42, 108],
  startIcon: [26, 42, 108],
};

function setPx(buf, w, h, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= h) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3] ?? 255;
}

function paint(w, h, rgb) {
  const buf = Buffer.alloc(w * h * 4);
  for (let y = 0; y < h; y++) {
    const t = y / h;
    const r = Math.round(rgb[0] * (1 - t * 0.35) + 18 * t);
    const g = Math.round(rgb[1] * (1 - t * 0.35) + 22 * t);
    const b = Math.round(rgb[2] * (1 - t * 0.35) + 40 * t);
    for (let x = 0; x < w; x++) {
      setPx(buf, w, h, x, y, [r, g, b, 255]);
    }
  }
  for (let y = Math.floor(h * 0.55); y < h; y++) {
    for (let x = 0; x < w; x++) {
      const a = Math.min(200, Math.round(((y - h * 0.55) / (h * 0.45)) * 200));
      setPx(buf, w, h, x, y, [10, 18, 48, a]);
    }
  }
  return buf;
}

function crc32(buf) {
  return zlib.crc32(buf) >>> 0;
}

function pngChunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const typeBuf = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])));
  return Buffer.concat([len, typeBuf, data, crc]);
}

function encodePng(rgba, w, h) {
  const stride = w * 4 + 1;
  const raw = Buffer.alloc(stride * h);
  for (let y = 0; y < h; y++) {
    raw[y * stride] = 0;
    rgba.copy(raw, y * stride + 1, y * w * 4, (y + 1) * w * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', zlib.deflateSync(raw)),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

function writeImage(name, rgb, w, h, destDir) {
  fs.mkdirSync(destDir, { recursive: true });
  fs.writeFileSync(path.join(destDir, `${name}.png`), encodePng(paint(w, h, rgb), w, h));
  console.log('wrote', path.join(destDir, `${name}.png`));
}

fs.mkdirSync(OUT, { recursive: true });
for (const [name, rgb] of Object.entries(PALETTE)) {
  if (name === 'icon' || name === 'startIcon') continue;
  writeImage(name, rgb, W, H, OUT);
}

writeImage('icon', PALETTE.icon, 256, 256, OUT);
writeImage('startIcon', PALETTE.startIcon, 256, 256, OUT);
writeImage('app_icon', [26, 42, 108], 1024, 1024, APP_SCOPE);
writeImage('app_icon', [26, 42, 108], 1024, 1024, ROOT);
fs.copyFileSync(path.join(ROOT, 'app_icon.png'), path.join(ROOT, 'preview-1024.png'));
console.log('done');
