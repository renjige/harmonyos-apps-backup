#!/usr/bin/env node
/** Rasterize 脑力探秘 mark → PNG masters (no Python). */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [10, 22, 40, 255];
const MARK = [245, 166, 35, 255];

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3];
}

function fillPolygon(buf, w, pts, color) {
  let ymin = w;
  let ymax = 0;
  for (const p of pts) {
    ymin = Math.min(ymin, Math.floor(p[1]));
    ymax = Math.max(ymax, Math.ceil(p[1]));
  }
  ymin = Math.max(0, ymin);
  ymax = Math.min(w - 1, ymax);
  const n = pts.length;
  for (let y = ymin; y <= ymax; y++) {
    const xs = [];
    for (let i = 0; i < n; i++) {
      const [x1, y1] = pts[i];
      const [x2, y2] = pts[(i + 1) % n];
      if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
        xs.push(x1 + ((y - y1) * (x2 - x1)) / (y2 - y1));
      }
    }
    xs.sort((a, b) => a - b);
    for (let k = 0; k + 1 < xs.length; k += 2) {
      const x0 = Math.max(0, Math.floor(xs[k]));
      const x1 = Math.min(w - 1, Math.ceil(xs[k + 1]));
      for (let x = x0; x <= x1; x++) setPx(buf, w, x, y, color);
    }
  }
}

function fillCircle(buf, w, cx, cy, r, color) {
  const rr = r * r;
  const x0 = Math.max(0, Math.floor(cx - r));
  const x1 = Math.min(w - 1, Math.ceil(cx + r));
  const y0 = Math.max(0, Math.floor(cy - r));
  const y1 = Math.min(w - 1, Math.ceil(cy + r));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= rr) setPx(buf, w, x, y, color);
    }
  }
}

function strokePolygon(buf, w, pts, thickness, color) {
  const n = pts.length;
  for (let i = 0; i < n; i++) {
    const [x1, y1] = pts[i];
    const [x2, y2] = pts[(i + 1) % n];
    const dx = x2 - x1;
    const dy = y2 - y1;
    const len = Math.hypot(dx, dy) || 1;
    const steps = Math.ceil(len);
    for (let s = 0; s <= steps; s++) {
      const t = s / steps;
      fillCircle(buf, w, x1 + dx * t, y1 + dy * t, thickness / 2, color);
    }
  }
}

function paintMark(buf, size) {
  const s = size / 1024;
  const outer = [
    [512 * s, 236 * s],
    [772 * s, 512 * s],
    [512 * s, 788 * s],
    [252 * s, 512 * s],
  ];
  const inner = [
    [512 * s, 340 * s],
    [668 * s, 512 * s],
    [512 * s, 684 * s],
    [356 * s, 512 * s],
  ];
  strokePolygon(buf, size, outer, 44 * s, MARK);
  fillPolygon(buf, size, inner, MARK);
  fillCircle(buf, size, 512 * s, 200 * s, 42 * s, MARK);
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
  console.log('OK rendered 脑力探秘 PNG masters');
}

main();
