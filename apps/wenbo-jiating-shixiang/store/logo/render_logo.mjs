#!/usr/bin/env node
/** Rasterize roof+check mark to PNG masters without Python. */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [36, 68, 58, 255];
const FG = [246, 241, 232, 255];

function makeCanvas(w, h, fill) {
  const data = Buffer.alloc(w * h * 4);
  for (let i = 0; i < w * h; i++) {
    data[i * 4] = fill[0];
    data[i * 4 + 1] = fill[1];
    data[i * 4 + 2] = fill[2];
    data[i * 4 + 3] = fill[3];
  }
  return { w, h, data };
}

function setPx(c, x, y, color) {
  if (x < 0 || y < 0 || x >= c.w || y >= c.h) return;
  const i = (y * c.w + x) * 4;
  c.data[i] = color[0];
  c.data[i + 1] = color[1];
  c.data[i + 2] = color[2];
  c.data[i + 3] = color[3];
}

function disc(c, cx, cy, r, color) {
  const r2 = r * r;
  const x0 = Math.floor(cx - r);
  const y0 = Math.floor(cy - r);
  const x1 = Math.ceil(cx + r);
  const y1 = Math.ceil(cy + r);
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(c, x, y, color);
    }
  }
}

function strokeLine(c, x0, y0, x1, y1, width, color) {
  const dx = x1 - x0;
  const dy = y1 - y0;
  const len = Math.hypot(dx, dy) || 1;
  const steps = Math.ceil(len);
  const r = width / 2;
  for (let i = 0; i <= steps; i++) {
    const t = i / steps;
    disc(c, x0 + dx * t, y0 + dy * t, r, color);
  }
}

function encodePng(c) {
  const raw = Buffer.alloc((c.w * 4 + 1) * c.h);
  for (let y = 0; y < c.h; y++) {
    raw[y * (c.w * 4 + 1)] = 0;
    c.data.copy(raw, y * (c.w * 4 + 1) + 1, y * c.w * 4, (y + 1) * c.w * 4);
  }
  const compressed = zlib.deflateSync(raw);
  function chunk(type, data) {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length, 0);
    const typeBuf = Buffer.from(type);
    const crc = zlib.crc32(Buffer.concat([typeBuf, data]));
    const crcBuf = Buffer.alloc(4);
    crcBuf.writeUInt32BE(crc >>> 0, 0);
    return Buffer.concat([len, typeBuf, data, crcBuf]);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(c.w, 0);
  ihdr.writeUInt32BE(c.h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', compressed), chunk('IEND', Buffer.alloc(0))]);
}

function scaleNearest(src, size) {
  const out = makeCanvas(size, size, BG);
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const sx = Math.floor((x * src.w) / size);
      const sy = Math.floor((y * src.h) / size);
      const i = (sy * src.w + sx) * 4;
      setPx(out, x, y, [src.data[i], src.data[i + 1], src.data[i + 2], src.data[i + 3]]);
    }
  }
  return out;
}

function main() {
  const c = makeCanvas(MASTER, MASTER, BG);
  strokeLine(c, 250, 530, 512, 268, 58, FG);
  strokeLine(c, 512, 268, 774, 530, 58, FG);
  strokeLine(c, 388, 572, 478, 670, 54, FG);
  strokeLine(c, 478, 670, 678, 430, 54, FG);
  const png = encodePng(c);
  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), png);
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), png);
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(makeCanvas(MASTER, MASTER, BG)));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(scaleNearest(c, AGC)));
  console.log('OK rendered PNG masters (node)');
}

main();
