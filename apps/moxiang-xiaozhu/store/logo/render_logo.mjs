/**
 * 墨香小筑 — 墨晕水滴 + 抽象小筑屋脊 · 墨底鎏金
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [26, 26, 46];
const GOLD = [201, 169, 110];

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) {
      c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function encodePngRgb(width, height, rgb) {
  const raw = Buffer.alloc((width * 3 + 1) * height);
  for (let y = 0; y < height; y++) {
    const dest = y * (width * 3 + 1);
    raw[dest] = 0;
    rgb.copy(raw, dest + 1, y * width * 3, (y + 1) * width * 3);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function encodePngRgba(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    const dest = y * (width * 4 + 1);
    raw[dest] = 0;
    rgba.copy(raw, dest + 1, y * width * 4, (y + 1) * width * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function fillCanvas(color, size) {
  const rgb = Buffer.alloc(size * size * 3);
  for (let i = 0; i < size * size; i++) {
    rgb[i * 3] = color[0];
    rgb[i * 3 + 1] = color[1];
    rgb[i * 3 + 2] = color[2];
  }
  return rgb;
}

function setPx(rgb, size, x, y, color) {
  if (x < 0 || y < 0 || x >= size || y >= size) return;
  const o = (y * size + x) * 3;
  rgb[o] = color[0];
  rgb[o + 1] = color[1];
  rgb[o + 2] = color[2];
}

function fillRect(rgb, size, x0, y0, x1, y1, color) {
  const xa = Math.max(0, Math.floor(x0));
  const ya = Math.max(0, Math.floor(y0));
  const xb = Math.min(size - 1, Math.floor(x1));
  const yb = Math.min(size - 1, Math.floor(y1));
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) {
      setPx(rgb, size, x, y, color);
    }
  }
}

function fillCircle(rgb, size, cx, cy, r, color) {
  const r2 = r * r;
  const xa = Math.max(0, Math.floor(cx - r));
  const ya = Math.max(0, Math.floor(cy - r));
  const xb = Math.min(size - 1, Math.ceil(cx + r));
  const yb = Math.min(size - 1, Math.ceil(cy + r));
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(rgb, size, x, y, color);
    }
  }
}

function fillTriangle(rgb, size, x1, y1, x2, y2, x3, y3, color) {
  const minX = Math.max(0, Math.floor(Math.min(x1, x2, x3)));
  const maxX = Math.min(size - 1, Math.ceil(Math.max(x1, x2, x3)));
  const minY = Math.max(0, Math.floor(Math.min(y1, y2, y3)));
  const maxY = Math.min(size - 1, Math.ceil(Math.max(y1, y2, y3)));
  const area = (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2));
  if (area === 0) return;
  for (let y = minY; y <= maxY; y++) {
    for (let x = minX; x <= maxX; x++) {
      const w1 = (x1 * (y2 - y) + x2 * (y - y1) + x * (y1 - y2)) / area;
      const w2 = (x2 * (y3 - y) + x3 * (y - y2) + x * (y2 - y3)) / area;
      const w3 = (x3 * (y1 - y) + x1 * (y - y3) + x * (y3 - y1)) / area;
      if (w1 >= 0 && w2 >= 0 && w3 >= 0) setPx(rgb, size, x, y, color);
    }
  }
}

function drawMark(rgb, size) {
  const s = size / 1024;
  fillCircle(rgb, size, 430 * s, 470 * s, 168 * s, GOLD);
  fillTriangle(rgb, size, 430 * s, 638 * s, 358 * s, 560 * s, 502 * s, 560 * s, GOLD);
  fillTriangle(rgb, size, 560 * s, 320 * s, 780 * s, 500 * s, 340 * s, 500 * s, GOLD);
  fillRect(rgb, size, 536 * s, 500 * s, 584 * s, 696 * s, GOLD);
}

function scaleRgb(src, srcSize, destSize) {
  const dest = Buffer.alloc(destSize * destSize * 3);
  for (let y = 0; y < destSize; y++) {
    const sy = Math.min(srcSize - 1, Math.round((y + 0.5) * srcSize / destSize - 0.5));
    for (let x = 0; x < destSize; x++) {
      const sx = Math.min(srcSize - 1, Math.round((x + 0.5) * srcSize / destSize - 0.5));
      const si = (sy * srcSize + sx) * 3;
      const di = (y * destSize + x) * 3;
      dest[di] = src[si];
      dest[di + 1] = src[si + 1];
      dest[di + 2] = src[si + 2];
    }
  }
  return dest;
}

function rgbToForeground(rgb, size) {
  const rgba = Buffer.alloc(size * size * 4);
  for (let i = 0; i < size * size; i++) {
    const r = rgb[i * 3];
    const g = rgb[i * 3 + 1];
    const b = rgb[i * 3 + 2];
    const isBg = r === BG[0] && g === BG[1] && b === BG[2];
    const o = i * 4;
    if (isBg) {
      rgba[o] = 0;
      rgba[o + 1] = 0;
      rgba[o + 2] = 0;
      rgba[o + 3] = 0;
    } else {
      rgba[o] = r;
      rgba[o + 1] = g;
      rgba[o + 2] = b;
      rgba[o + 3] = 255;
    }
  }
  return rgba;
}

function main() {
  const preview = fillCanvas(BG, MASTER);
  drawMark(preview, MASTER);
  const bg = fillCanvas(BG, MASTER);
  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePngRgb(MASTER, MASTER, preview));
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePngRgb(MASTER, MASTER, bg));
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePngRgba(MASTER, MASTER, rgbToForeground(preview, MASTER)));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePngRgb(AGC, AGC, scaleRgb(preview, MASTER, AGC)));
  console.log('OK rendered 墨香小筑 PNG masters');
}

main();
