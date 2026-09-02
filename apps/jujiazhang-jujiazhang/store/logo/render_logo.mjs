#!/usr/bin/env node
/** Rasterize house + stamp ring to PNG masters (居家章). */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [26, 58, 92, 255];
const FG = [255, 107, 53, 255];

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

function strokeRing(c, cx, cy, radius, width, color) {
  const inner = radius - width / 2;
  const outer = radius + width / 2;
  const x0 = Math.floor(cx - outer);
  const y0 = Math.floor(cy - outer);
  const x1 = Math.ceil(cx + outer);
  const y1 = Math.ceil(cy + outer);
  const inner2 = inner * inner;
  const outer2 = outer * outer;
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      const d2 = dx * dx + dy * dy;
      if (d2 <= outer2 && d2 >= inner2) setPx(c, x, y, color);
    }
  }
}

function strokeRect(c, x, y, w, h, width, color) {
  strokeLine(c, x, y, x + w, y, width, color);
  strokeLine(c, x + w, y, x + w, y + h, width, color);
  strokeLine(c, x + w, y + h, x, y + h, width, color);
  strokeLine(c, x, y + h, x, y, width, color);
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

function drawMark(c) {
  const cx = 512;
  const cy = 512;
  strokeRing(c, cx, cy, 340, 36, FG);
  strokeRing(c, cx, cy, 300, 12, FG);
  strokeLine(c, 320, 560, 512, 340, 48, FG);
  strokeLine(c, 512, 340, 704, 560, 48, FG);
  strokeLine(c, 380, 560, 380, 720, 44, FG);
  strokeLine(c, 644, 720, 644, 560, 44, FG);
  strokeLine(c, 380, 720, 644, 720, 44, FG);
  strokeRect(c, 448, 600, 128, 128, 28, FG);
  strokeLine(c, 472, 640, 576, 640, 22, FG);
  strokeLine(c, 512, 600, 512, 680, 22, FG);
}

function main() {
  const c = makeCanvas(MASTER, MASTER, BG);
  drawMark(c);
  const png = encodePng(c);
  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), png);
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), png);
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(makeCanvas(MASTER, MASTER, BG)));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(scaleNearest(c, AGC)));
  console.log('OK rendered PNG masters (node) — 居家章 orange/navy');
}

main();
