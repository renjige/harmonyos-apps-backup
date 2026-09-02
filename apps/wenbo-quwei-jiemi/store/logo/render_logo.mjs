#!/usr/bin/env node
/** 趣味解谜 — 问号与灯泡融合图形 (#007AFF + #FF6B35) */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [0, 122, 255, 255];
const BLUE = [255, 255, 255, 255];
const ORANGE = [255, 107, 53, 255];

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3];
}

function fillCircle(buf, w, cx, cy, r, color) {
  const r2 = r * r;
  const x0 = Math.max(0, Math.floor(cx - r));
  const x1 = Math.min(w - 1, Math.ceil(cx + r));
  const y0 = Math.max(0, Math.floor(cy - r));
  const y1 = Math.min(w - 1, Math.ceil(cy + r));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(buf, w, x, y, color);
    }
  }
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

function strokeArc(buf, w, cx, cy, r, startDeg, endDeg, thickness, color) {
  const steps = Math.max(32, Math.floor(r * 2));
  for (let i = 0; i <= steps; i++) {
    const t = startDeg + ((endDeg - startDeg) * i) / steps;
    const rad = (t * Math.PI) / 180;
    const px = cx + r * Math.cos(rad);
    const py = cy + r * Math.sin(rad);
    fillCircle(buf, w, px, py, thickness / 2, color);
  }
}

function paintMark(buf, size) {
  const s = size / 1024;
  const cx = 512 * s;
  const cy = 420 * s;
  const r = 220 * s;
  const thick = 52 * s;
  strokeArc(buf, size, cx, cy, r, 200, -20, thick, BLUE);
  fillCircle(buf, size, cx + 88 * s, cy + 200 * s, 36 * s, BLUE);
  fillRect(buf, size, cx - 18 * s, cy + 200 * s, cx + 18 * s, cy + 290 * s, BLUE);
  fillCircle(buf, size, cx + 210 * s, cy - 60 * s, 78 * s, ORANGE);
  fillRect(buf, size, cx + 198 * s, cy + 10 * s, cx + 222 * s, cy + 48 * s, ORANGE);
  for (let i = 0; i < 5; i++) {
    const ang = (-70 + i * 18) * (Math.PI / 180);
    const x1 = cx + 210 * s + Math.cos(ang) * 92 * s;
    const y1 = cy - 60 * s + Math.sin(ang) * 92 * s;
    const x2 = cx + 210 * s + Math.cos(ang) * 130 * s;
    const y2 = cy - 60 * s + Math.sin(ang) * 130 * s;
    const mx = (x1 + x2) / 2;
    const my = (y1 + y2) / 2;
    fillCircle(buf, size, mx, my, 10 * s, ORANGE);
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
  console.log('OK rendered 趣味解谜 PNG masters');
}

main();
