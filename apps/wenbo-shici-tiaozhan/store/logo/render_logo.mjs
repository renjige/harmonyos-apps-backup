#!/usr/bin/env node
/** 诗词挑战 — 墨底朱砂「诗」字 + 鸿蒙蓝数据纹 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [28, 40, 51, 255];
const MARK = [196, 26, 26, 255];
const TECH = [0, 122, 255, 200];

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3];
}

function fillRect(buf, w, x0, y0, x1, y1, color) {
  const xa = Math.max(0, Math.floor(Math.min(x0, x1)));
  const xb = Math.min(w - 1, Math.ceil(Math.max(x0, x1)));
  const ya = Math.max(0, Math.floor(Math.min(y0, y1)));
  const yb = Math.min(w - 1, Math.ceil(Math.max(y0, y1)));
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) setPx(buf, w, x, y, color);
  }
}

function strokeRect(buf, w, x, y, rw, rh, thickness, color) {
  fillRect(buf, w, x, y, x + rw, y + thickness, color);
  fillRect(buf, w, x, y + rh - thickness, x + rw, y + rh, color);
  fillRect(buf, w, x, y, x + thickness, y + rh, color);
  fillRect(buf, w, x + rw - thickness, y, x + rw, y + rh, color);
}

function paintMark(buf, size) {
  const s = size / 1024;
  strokeRect(buf, size, 180 * s, 180 * s, 664 * s, 664 * s, 36 * s, MARK);
  fillRect(buf, size, 280 * s, 300 * s, 740 * s, 360 * s, MARK);
  fillRect(buf, size, 280 * s, 420 * s, 740 * s, 480 * s, MARK);
  fillRect(buf, size, 280 * s, 540 * s, 740 * s, 600 * s, MARK);
  fillRect(buf, size, 470 * s, 360 * s, 530 * s, 720 * s, MARK);
  fillRect(buf, size, 620 * s, 360 * s, 680 * s, 620 * s, MARK);
  for (let i = 0; i < 6; i++) {
    const y = 720 * s + i * 28 * s;
    fillRect(buf, size, 240 * s, y, 780 * s, y + 4 * s, TECH);
    if (i % 2 === 0) {
      fillRect(buf, size, 300 * s + i * 40 * s, y - 20 * s, 304 * s + i * 40 * s, y + 24 * s, TECH);
    }
  }
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
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', zlib.deflateSync(raw)),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

function resizeNearest(src, srcSize, dstSize) {
  const dst = Buffer.alloc(dstSize * dstSize * 4);
  for (let y = 0; y < dstSize; y++) {
    const sy = Math.min(srcSize - 1, Math.floor((y * srcSize) / dstSize));
    for (let x = 0; x < dstSize; x++) {
      const sx = Math.min(srcSize - 1, Math.floor((x * srcSize) / dstSize));
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

function main() {
  const preview = Buffer.alloc(MASTER * MASTER * 4);
  for (let i = 0; i < MASTER * MASTER; i++) {
    preview[i * 4] = BG[0];
    preview[i * 4 + 1] = BG[1];
    preview[i * 4 + 2] = BG[2];
    preview[i * 4 + 3] = BG[3];
  }
  paintMark(preview, MASTER);

  const fg = Buffer.alloc(MASTER * MASTER * 4);
  paintMark(fg, MASTER);

  const bg = Buffer.alloc(MASTER * MASTER * 4);
  for (let i = 0; i < MASTER * MASTER; i++) {
    bg[i * 4] = BG[0];
    bg[i * 4 + 1] = BG[1];
    bg[i * 4 + 2] = BG[2];
    bg[i * 4 + 3] = BG[3];
  }

  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePng(MASTER, preview));
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePng(MASTER, fg));
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(MASTER, bg));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(AGC, resizeNearest(preview, MASTER, AGC)));
  fs.writeFileSync(path.join(ROOT, 'favicon-32.png'), encodePng(32, resizeNearest(preview, MASTER, 32)));

  const appMedia = path.resolve(ROOT, '../../app/entry/src/main/resources/base/media');
  fs.mkdirSync(appMedia, { recursive: true });
  fs.copyFileSync(path.join(ROOT, 'preview-1024.png'), path.join(appMedia, 'app_icon.png'));
  fs.copyFileSync(path.join(ROOT, 'preview-1024.png'), path.join(appMedia, 'icon.png'));
  fs.copyFileSync(path.join(ROOT, 'preview-1024.png'), path.join(appMedia, 'startIcon.png'));
  const appScope = path.resolve(ROOT, '../../app/AppScope/resources/base/media');
  fs.mkdirSync(appScope, { recursive: true });
  fs.copyFileSync(path.join(ROOT, 'preview-1024.png'), path.join(appScope, 'app_icon.png'));
  console.log('OK rendered 诗词挑战 PNG masters');
}

main();
