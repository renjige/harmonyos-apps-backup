#!/usr/bin/env node
/** Generate puzzle category / hero / medal cover PNGs for DevEco media/ */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(ROOT, '../../app/entry/src/main/resources/base/media');
const W = 800;
const H = 520;

const PALETTE = {
  cat_riddle: [0, 122, 255],
  cat_math: [52, 199, 89],
  cat_visual: [175, 82, 222],
  cat_life: [255, 149, 0],
  cat_logic: [90, 200, 250],
  cat_animal: [255, 107, 53],
  hero_desk: [30, 58, 95],
  hero_space: [0, 82, 204],
  medal_first: [255, 204, 74],
  medal_streak: [255, 107, 53],
  medal_puzzler: [0, 122, 255],
  medal_family: [175, 82, 222],
  medal_observe: [52, 199, 89],
  medal_math: [255, 59, 48],
  medal_wisdom: [255, 149, 0],
};

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= H) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = 255;
}

function paint(name, rgb) {
  const buf = Buffer.alloc(W * H * 4);
  for (let y = 0; y < H; y++) {
    const t = y / H;
    const r = Math.round(rgb[0] * (1 - t * 0.35) + 20 * t);
    const g = Math.round(rgb[1] * (1 - t * 0.35) + 24 * t);
    const b = Math.round(rgb[2] * (1 - t * 0.35) + 36 * t);
    for (let x = 0; x < W; x++) {
      setPx(buf, W, x, y, [r, g, b, 255]);
    }
  }
  for (let y = H * 0.55; y < H; y++) {
    for (let x = 0; x < W; x++) {
      const a = Math.min(180, Math.round(((y - H * 0.55) / (H * 0.45)) * 180));
      setPx(buf, W, x, y, [20, 28, 40, a]);
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

function encodePng(rgba) {
  const stride = W * 4 + 1;
  const raw = Buffer.alloc(stride * H);
  for (let y = 0; y < H; y++) {
    raw[y * stride] = 0;
    rgba.copy(raw, y * stride + 1, y * W * 4, (y + 1) * W * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(W, 0);
  ihdr.writeUInt32BE(H, 4);
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

fs.mkdirSync(OUT, { recursive: true });
for (const [name, rgb] of Object.entries(PALETTE)) {
  fs.writeFileSync(path.join(OUT, `${name}.png`), encodePng(paint(name, rgb)));
  console.log('wrote', name);
}
