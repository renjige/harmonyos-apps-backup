#!/usr/bin/env node
/** Rasterize 球星风采 mark → PNG masters (no Python / cairosvg). */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [22, 17, 13, 255];
const MARK = [244, 230, 195, 255];

function starPoints(cx, cy, outer, inner) {
  const pts = [];
  for (let i = 0; i < 8; i++) {
    const ang = ((-90 + i * 45) * Math.PI) / 180;
    const r = i % 2 === 0 ? outer : inner;
    pts.push([cx + r * Math.cos(ang), cy + r * Math.sin(ang)]);
  }
  return pts;
}

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

function angleInSweep(deg, start, end) {
  let a = ((deg % 360) + 360) % 360;
  const s = ((start % 360) + 360) % 360;
  const e = ((end % 360) + 360) % 360;
  if (s <= e) return a >= s && a <= e;
  return a >= s || a <= e;
}

function drawThickArc(buf, w, cx, cy, radius, startDeg, endDeg, width, color) {
  const hw = width / 2;
  const r0 = radius - hw - 1;
  const r1 = radius + hw + 1;
  const minX = Math.max(0, Math.floor(cx - r1));
  const maxX = Math.min(w - 1, Math.ceil(cx + r1));
  const minY = Math.max(0, Math.floor(cy - r1));
  const maxY = Math.min(w - 1, Math.ceil(cy + r1));
  for (let y = minY; y <= maxY; y++) {
    for (let x = minX; x <= maxX; x++) {
      const dx = x + 0.5 - cx;
      const dy = y + 0.5 - cy;
      const d = Math.hypot(dx, dy);
      if (d < r0 || d > r1) continue;
      let deg = (Math.atan2(dy, dx) * 180) / Math.PI;
      if (deg < 0) deg += 360;
      if (!angleInSweep(deg, startDeg, endDeg)) continue;
      if (Math.abs(d - radius) <= hw) setPx(buf, w, x, y, color);
    }
  }
  const caps = [
    [cx + radius * Math.cos((startDeg * Math.PI) / 180), cy + radius * Math.sin((startDeg * Math.PI) / 180)],
    [cx + radius * Math.cos((endDeg * Math.PI) / 180), cy + radius * Math.sin((endDeg * Math.PI) / 180)],
  ];
  for (const [px, py] of caps) {
    const r = hw;
    const x0 = Math.max(0, Math.floor(px - r));
    const x1 = Math.min(w - 1, Math.ceil(px + r));
    const y0 = Math.max(0, Math.floor(py - r));
    const y1 = Math.min(w - 1, Math.ceil(py + r));
    for (let y = y0; y <= y1; y++) {
      for (let x = x0; x <= x1; x++) {
        if (Math.hypot(x + 0.5 - px, y + 0.5 - py) <= r) setPx(buf, w, x, y, color);
      }
    }
  }
}

function paintMark(buf, size) {
  const cx = size / 2;
  const cy = size / 2;
  const s = size / 1024;
  fillPolygon(buf, size, starPoints(cx, cy, 268 * s, 98 * s), MARK);
  drawThickArc(buf, size, cx, cy, 320 * s, 300, 70, 36 * s, MARK);
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
  console.log('OK rendered 球星风采 PNG masters');
}

main();
