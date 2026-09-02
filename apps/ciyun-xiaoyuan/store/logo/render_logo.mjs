/**
 * 词韵小院 — 窗棂（院）+ 几何「词」笔（朱砂）· 墨底
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [44, 24, 16];
const PAPER = [245, 240, 232];
const CINNABAR = [139, 26, 26];

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

function fillRect(rgb, size, x0, y0, x1, y1, color) {
  const xa = Math.max(0, Math.floor(x0));
  const ya = Math.max(0, Math.floor(y0));
  const xb = Math.min(size - 1, Math.floor(x1));
  const yb = Math.min(size - 1, Math.floor(y1));
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) {
      const o = (y * size + x) * 3;
      rgb[o] = color[0];
      rgb[o + 1] = color[1];
      rgb[o + 2] = color[2];
    }
  }
}

function drawMark(rgb, size) {
  const s = size / 1024;
  fillRect(rgb, size, 236 * s, 236 * s, 788 * s, 280 * s, PAPER);
  fillRect(rgb, size, 236 * s, 744 * s, 788 * s, 788 * s, PAPER);
  fillRect(rgb, size, 236 * s, 236 * s, 280 * s, 788 * s, PAPER);
  fillRect(rgb, size, 744 * s, 236 * s, 788 * s, 788 * s, PAPER);
  fillRect(rgb, size, 500 * s, 258 * s, 524 * s, 766 * s, PAPER);
  fillRect(rgb, size, 258 * s, 488 * s, 766 * s, 512 * s, PAPER);
  fillRect(rgb, size, 300 * s, 300 * s, 460 * s, 328 * s, CINNABAR);
  fillRect(rgb, size, 300 * s, 360 * s, 460 * s, 388 * s, CINNABAR);
  fillRect(rgb, size, 300 * s, 420 * s, 420 * s, 448 * s, CINNABAR);
  fillRect(rgb, size, 560 * s, 300 * s, 596 * s, 520 * s, CINNABAR);
  fillRect(rgb, size, 560 * s, 300 * s, 700 * s, 328 * s, CINNABAR);
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
  console.log('OK rendered 词韵小院 PNG masters');
}

main();
