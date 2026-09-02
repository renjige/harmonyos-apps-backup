/**
 * Rasterize 清凉衣橱 logo with pure Node.js (no Python dependency).
 * Wardrobe outline + breeze curve + hanging garment + mint green aesthetic.
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;

const BG_TOP = [0x2d, 0x8c, 0x70, 255]; // #2D8C70
const BG_BOT = [0x1e, 0x6b, 0x54, 255]; // #1E6B54
const WHITE = [0xff, 0xff, 0xff, 255];
const CREAM = [0xea, 0xf7, 0xf3, 255]; // #EAF7F3
const MINT = [0xbf, 0xe8, 0xdc, 255];  // #BFE8DC

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) {
      c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0);
    }
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const t = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.concat([t, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcBuf), 0);
  return Buffer.concat([len, t, data, crc]);
}

function encodePng(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    const rowStart = y * (width * 4 + 1);
    raw[rowStart] = 0;
    rgba.copy(raw, rowStart + 1, y * width * 4, (y + 1) * width * 4);
  }
  const compressed = zlib.deflateSync(raw, { level: 9 });
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', compressed), chunk('IEND', Buffer.alloc(0))]);
}

function setPx(buf, w, x, y, c, alpha = 1) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  if (alpha >= 0.99) {
    buf[i] = c[0];
    buf[i + 1] = c[1];
    buf[i + 2] = c[2];
    buf[i + 3] = c[3];
  } else {
    const a = alpha * (c[3] / 255);
    const invA = 1 - a;
    buf[i] = Math.round(buf[i] * invA + c[0] * a);
    buf[i + 1] = Math.round(buf[i + 1] * invA + c[1] * a);
    buf[i + 2] = Math.round(buf[i + 2] * invA + c[2] * a);
    buf[i + 3] = 255;
  }
}

function fillGradient(buf, w) {
  for (let y = 0; y < w; y++) {
    const t = y / (w - 1);
    const r = Math.round(BG_TOP[0] * (1 - t) + BG_BOT[0] * t);
    const g = Math.round(BG_TOP[1] * (1 - t) + BG_BOT[1] * t);
    const b = Math.round(BG_TOP[2] * (1 - t) + BG_BOT[2] * t);
    for (let x = 0; x < w; x++) {
      const i = (y * w + x) * 4;
      buf[i] = r;
      buf[i + 1] = g;
      buf[i + 2] = b;
      buf[i + 3] = 255;
    }
  }
}

function fillCircle(buf, w, cx, cy, r, c, alpha = 1) {
  const r2 = r * r;
  for (let y = Math.max(0, cy - r); y <= Math.min(w - 1, cy + r); y++) {
    for (let x = Math.max(0, cx - r); x <= Math.min(w - 1, cx + r); x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(buf, w, x, y, c, alpha);
    }
  }
}

function strokeLine(buf, w, x0, y0, x1, y1, radius, c, alpha = 1) {
  const dx = x1 - x0;
  const dy = y1 - y0;
  const len = Math.max(1, Math.hypot(dx, dy));
  const n = Math.ceil(len * 2);
  for (let s = 0; s <= n; s++) {
    const t = s / n;
    fillCircle(buf, w, Math.round(x0 + dx * t), Math.round(y0 + dy * t), radius, c, alpha);
  }
}

function strokeRoundRect(buf, w, rx0, ry0, rx1, ry1, radius, strokeW, c, alpha = 1) {
  // 4 edges
  strokeLine(buf, w, rx0 + radius, ry0, rx1 - radius, ry0, strokeW, c, alpha);
  strokeLine(buf, w, rx0 + radius, ry1, rx1 - radius, ry1, strokeW, c, alpha);
  strokeLine(buf, w, rx0, ry0 + radius, rx0, ry1 - radius, strokeW, c, alpha);
  strokeLine(buf, w, rx1, ry0 + radius, rx1, ry1 - radius, strokeW, c, alpha);
  // 4 corners
  const step = 0.05;
  for (let a = 0; a <= Math.PI / 2; a += step) {
    const dx = Math.round(Math.cos(a) * radius);
    const dy = Math.round(Math.sin(a) * radius);
    fillCircle(buf, w, rx1 - radius + dx, ry1 - radius + dy, strokeW, c, alpha);
    fillCircle(buf, w, rx0 + radius - dx, ry1 - radius + dy, strokeW, c, alpha);
    fillCircle(buf, w, rx0 + radius - dx, ry0 + radius - dy, strokeW, c, alpha);
    fillCircle(buf, w, rx1 - radius + dx, ry0 + radius - dy, strokeW, c, alpha);
  }
}

function fillPoly(buf, w, pts, c, alpha = 1) {
  let minY = w;
  let maxY = 0;
  for (const p of pts) {
    minY = Math.min(minY, p[1]);
    maxY = Math.max(maxY, p[1]);
  }
  for (let y = minY; y <= maxY; y++) {
    const xs = [];
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i];
      const b = pts[(i + 1) % pts.length];
      if ((a[1] <= y && b[1] > y) || (b[1] <= y && a[1] > y)) {
        const t = (y - a[1]) / (b[1] - a[1]);
        xs.push(Math.round(a[0] + t * (b[0] - a[0])));
      }
    }
    xs.sort((p, q) => p - q);
    for (let i = 0; i + 1 < xs.length; i += 2) {
      const x0 = Math.max(0, xs[i]);
      const x1 = Math.min(w - 1, xs[i + 1]);
      for (let x = x0; x <= x1; x++) setPx(buf, w, x, y, c, alpha);
    }
  }
}

function drawMark(size) {
  const buf = Buffer.alloc(size * size * 4);
  fillGradient(buf, size);
  const s = size / 512;

  // 1. Wardrobe Minimal Outline
  const boxX0 = Math.round(116 * s);
  const boxY0 = Math.round(104 * s);
  const boxX1 = Math.round(396 * s);
  const boxY1 = Math.round(408 * s);
  const cornerR = Math.round(36 * s);
  const borderW = Math.max(3, Math.round(8 * s));
  strokeRoundRect(buf, size, boxX0, boxY0, boxX1, boxY1, cornerR, borderW, WHITE, 0.95);

  // 2. Middle divider line
  const midX = Math.round(256 * s);
  strokeLine(buf, size, midX, boxY0, midX, boxY1, Math.max(2, Math.round(5 * s)), WHITE, 0.6);

  // 3. Garment Silhouette
  const garmentPts = [
    [Math.round(220 * s), Math.round(208 * s)],
    [Math.round(256 * s), Math.round(186 * s)],
    [Math.round(292 * s), Math.round(208 * s)],
    [Math.round(284 * s), Math.round(316 * s)],
    [Math.round(256 * s), Math.round(328 * s)],
    [Math.round(228 * s), Math.round(316 * s)],
  ];
  fillPoly(buf, size, garmentPts, CREAM, 0.9);

  // 4. Breeze Flowing Curve (Bezier sampling)
  const curvePts = [];
  const p0 = [96 * s, 296 * s];
  const p1 = [170 * s, 210 * s];
  const p2 = [240 * s, 340 * s];
  const p3 = [320 * s, 240 * s];
  const p4 = [424 * s, 224 * s];

  // Catmull-Rom or multi-segment spline
  for (let t = 0; t <= 1; t += 0.005) {
    let x, y;
    if (t < 0.5) {
      const u = t * 2;
      x = (1 - u) * (1 - u) * p0[0] + 2 * (1 - u) * u * p1[0] + u * u * p2[0];
      y = (1 - u) * (1 - u) * p0[1] + 2 * (1 - u) * u * p1[1] + u * u * p2[1];
    } else {
      const u = (t - 0.5) * 2;
      x = (1 - u) * (1 - u) * p2[0] + 2 * (1 - u) * u * p3[0] + u * u * p4[0];
      y = (1 - u) * (1 - u) * p2[1] + 2 * (1 - u) * u * p3[1] + u * u * p4[1];
    }
    curvePts.push([Math.round(x), Math.round(y)]);
  }

  for (let i = 0; i < curvePts.length - 1; i++) {
    strokeLine(buf, size, curvePts[i][0], curvePts[i][1], curvePts[i + 1][0], curvePts[i + 1][1], Math.max(3, Math.round(10 * s)), MINT, 0.95);
  }

  // 5. Secondary Breeze Line
  const subCurve = [];
  for (let t = 0; t <= 1; t += 0.01) {
    const x = (1 - t) * (1 - t) * (144 * s) + 2 * (1 - t) * t * (250 * s) + t * t * (368 * s);
    const y = (1 - t) * (1 - t) * (348 * s) + 2 * (1 - t) * t * (320 * s) + t * t * (346 * s);
    subCurve.push([Math.round(x), Math.round(y)]);
  }
  for (let i = 0; i < subCurve.length - 1; i++) {
    strokeLine(buf, size, subCurve[i][0], subCurve[i][1], subCurve[i + 1][0], subCurve[i + 1][1], Math.max(2, Math.round(5 * s)), MINT, 0.75);
  }

  return buf;
}

function nearestResize(src, srcSize, dstSize) {
  const out = Buffer.alloc(dstSize * dstSize * 4);
  for (let y = 0; y < dstSize; y++) {
    const sy = Math.min(srcSize - 1, Math.round((y * (srcSize - 1)) / (dstSize - 1)));
    for (let x = 0; x < dstSize; x++) {
      const sx = Math.min(srcSize - 1, Math.round((x * (srcSize - 1)) / (dstSize - 1)));
      const si = (sy * srcSize + sx) * 4;
      const di = (y * dstSize + x) * 4;
      out[di] = src[si];
      out[di + 1] = src[si + 1];
      out[di + 2] = src[si + 2];
      out[di + 3] = src[si + 3];
    }
  }
  return out;
}

const master = drawMark(MASTER);
fs.writeFileSync(path.join(__dirname, 'preview-1024.png'), encodePng(MASTER, MASTER, master));
fs.writeFileSync(path.join(__dirname, 'background.png'), encodePng(MASTER, MASTER, master));
fs.writeFileSync(path.join(__dirname, 'foreground.png'), encodePng(MASTER, MASTER, master));
const agc = nearestResize(master, MASTER, AGC);
fs.writeFileSync(path.join(__dirname, 'agc-216.png'), encodePng(AGC, AGC, agc));
console.log('Generated 清凉衣橱 logo PNGs (1024 / 216)');
