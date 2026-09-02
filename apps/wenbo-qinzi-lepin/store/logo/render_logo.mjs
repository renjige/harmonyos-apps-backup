#!/usr/bin/env node
/** Rasterize 亲子乐拼 interlocking-piece mark without Python/Pillow. */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const SIZE = 1024;
const AGC = 216;
const DEEP = [92, 46, 18, 255];
const WHITE = [255, 252, 246, 255];
const ORANGE = [255, 140, 66, 255];

function buf(size) {
  return Buffer.alloc(size * size * 4);
}

function setPx(data, size, x, y, rgba) {
  if (x < 0 || y < 0 || x >= size || y >= size) return;
  const i = (y * size + x) * 4;
  data[i] = rgba[0];
  data[i + 1] = rgba[1];
  data[i + 2] = rgba[2];
  data[i + 3] = rgba[3];
}

function fillRect(data, size, x0, y0, x1, y1, rgba) {
  const xa = Math.max(0, Math.floor(x0));
  const ya = Math.max(0, Math.floor(y0));
  const xb = Math.min(size - 1, Math.ceil(x1));
  const yb = Math.min(size - 1, Math.ceil(y1));
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) setPx(data, size, x, y, rgba);
  }
}

function fillCircle(data, size, cx, cy, r, rgba) {
  const r2 = r * r;
  const x0 = Math.max(0, Math.floor(cx - r));
  const y0 = Math.max(0, Math.floor(cy - r));
  const x1 = Math.min(size - 1, Math.ceil(cx + r));
  const y1 = Math.min(size - 1, Math.ceil(cy + r));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(data, size, x, y, rgba);
    }
  }
}

function fillRoundRect(data, size, x0, y0, x1, y1, rad, rgba) {
  fillRect(data, size, x0 + rad, y0, x1 - rad, y1, rgba);
  fillRect(data, size, x0, y0 + rad, x1, y1 - rad, rgba);
  fillCircle(data, size, x0 + rad, y0 + rad, rad, rgba);
  fillCircle(data, size, x1 - rad, y0 + rad, rad, rgba);
  fillCircle(data, size, x0 + rad, y1 - rad, rad, rgba);
  fillCircle(data, size, x1 - rad, y1 - rad, rad, rgba);
}

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
  const t = Buffer.from(type);
  const crcSrc = Buffer.concat([t, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcSrc), 0);
  return Buffer.concat([len, t, data, crc]);
}

function encodePng(size, rgba) {
  const stride = size * 4 + 1;
  const raw = Buffer.alloc(stride * size);
  for (let y = 0; y < size; y++) {
    raw[y * stride] = 0;
    rgba.copy(raw, y * stride + 1, y * size * 4, (y + 1) * size * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function scaleNearest(src, srcSize, dstSize) {
  const dst = buf(dstSize);
  for (let y = 0; y < dstSize; y++) {
    for (let x = 0; x < dstSize; x++) {
      const sx = Math.floor((x * srcSize) / dstSize);
      const sy = Math.floor((y * srcSize) / dstSize);
      const si = (sy * srcSize + sx) * 4;
      const di = (y * dstSize + x) * 4;
      dst[di] = src[si];
      dst[di + 1] = src[si + 1];
      dst[di + 2] = src[si + 2];
      dst[di + 3] = src[si + 3];
    }
  }
  return dst;
}

function drawMark(size, bg, fg) {
  const data = buf(size);
  fillRect(data, size, 0, 0, size - 1, size - 1, bg);
  const s = size / 1024;
  const left = {
    x0: 268 * s,
    y0: 332 * s,
    x1: 508 * s,
    y1: 692 * s,
  };
  const right = {
    x0: 508 * s,
    y0: 332 * s,
    x1: 748 * s,
    y1: 692 * s,
  };
  const rad = 48 * s;
  const tabR = 58 * s;
  const cy = 512 * s;
  fillRoundRect(data, size, left.x0, left.y0, left.x1, left.y1, rad, fg);
  fillCircle(data, size, left.x1, cy, tabR, fg);
  fillRoundRect(data, size, right.x0, right.y0, right.x1, right.y1, rad, fg);
  fillCircle(data, size, right.x0, cy, tabR, bg);
  fillCircle(data, size, 388 * s, 428 * s, 18 * s, bg);
  fillCircle(data, size, 628 * s, 428 * s, 18 * s, bg);
  return data;
}

function writePng(file, size, data) {
  fs.writeFileSync(file, encodePng(size, data));
}

function main() {
  const preview = drawMark(SIZE, DEEP, WHITE);
  writePng(path.join(ROOT, 'preview-1024.png'), SIZE, preview);
  const bg = buf(SIZE);
  fillRect(bg, SIZE, 0, 0, SIZE - 1, SIZE - 1, DEEP);
  writePng(path.join(ROOT, 'background.png'), SIZE, bg);

  const fg = buf(SIZE);
  const whiteOnDeep = drawMark(SIZE, DEEP, WHITE);
  for (let i = 0; i < SIZE * SIZE; i++) {
    const o = i * 4;
    const r = whiteOnDeep[o];
    const g = whiteOnDeep[o + 1];
    const b = whiteOnDeep[o + 2];
    if (r > 200 && g > 200 && b > 200) {
      fg[o] = 255;
      fg[o + 1] = 252;
      fg[o + 2] = 246;
      fg[o + 3] = 255;
    }
  }
  writePng(path.join(ROOT, 'foreground.png'), SIZE, fg);
  writePng(path.join(ROOT, 'agc-216.png'), AGC, scaleNearest(preview, SIZE, AGC));
  for (const n of [512, 192, 144, 96, 72, 48]) {
    writePng(path.join(ROOT, `icon-${n}.png`), n, scaleNearest(preview, SIZE, n));
  }
  const orangeMark = drawMark(SIZE, [255, 248, 240, 255], ORANGE);
  writePng(path.join(ROOT, 'symbol-light.png'), SIZE, orangeMark);
  console.log('OK rendered interlocking puzzle mark');
}

main();
