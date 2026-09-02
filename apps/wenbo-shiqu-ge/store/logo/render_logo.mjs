/**
 * Rasterize 识趣阁 mark (Node, no Python).
 * Geometry matches store/logo/symbol.svg — eave + open pages.
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const DEEP = [0x3d, 0x34, 0x2c, 255];
const GOLD = [0xc4, 0xa8, 0x82, 255];
const CREAM = [0xf7, 0xf4, 0xf0, 255];

function crc32(buf) {
  let c = ~0;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) {
      c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
  }
  return (~c) >>> 0;
}

function u32(n) {
  const b = Buffer.alloc(4);
  b.writeUInt32BE(n >>> 0, 0);
  return b;
}

function pngChunk(type, data) {
  const t = Buffer.from(type, 'ascii');
  const crc = crc32(Buffer.concat([t, data]));
  return Buffer.concat([u32(data.length), t, data, u32(crc)]);
}

function encodePng(width, height, rgba, { alpha = true } = {}) {
  const bpp = alpha ? 4 : 3;
  const raw = Buffer.alloc((width * bpp + 1) * height);
  for (let y = 0; y < height; y++) {
    const row = y * (width * bpp + 1);
    raw[row] = 0;
    for (let x = 0; x < width; x++) {
      const s = (y * width + x) * 4;
      const d = row + 1 + x * bpp;
      raw[d] = rgba[s];
      raw[d + 1] = rgba[s + 1];
      raw[d + 2] = rgba[s + 2];
      if (alpha) raw[d + 3] = rgba[s + 3];
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = alpha ? 6 : 2;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3];
}

function fillRect(buf, w, x0, y0, x1, y1, c) {
  const xa = Math.max(0, Math.floor(x0));
  const ya = Math.max(0, Math.floor(y0));
  const xb = Math.min(w - 1, Math.ceil(x1) - 1);
  const yb = Math.min(w - 1, Math.ceil(y1) - 1);
  for (let y = ya; y <= yb; y++) {
    for (let x = xa; x <= xb; x++) setPx(buf, w, x, y, c);
  }
}

function fillPolygon(buf, w, pts, c) {
  let minY = w;
  let maxY = 0;
  for (const p of pts) {
    minY = Math.min(minY, p[1]);
    maxY = Math.max(maxY, p[1]);
  }
  const y0 = Math.max(0, Math.floor(minY));
  const y1 = Math.min(w - 1, Math.ceil(maxY));
  for (let y = y0; y <= y1; y++) {
    const ys = y + 0.5;
    const xs = [];
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i];
      const b = pts[(i + 1) % pts.length];
      if ((a[1] <= ys && b[1] > ys) || (b[1] <= ys && a[1] > ys)) {
        const t = (ys - a[1]) / (b[1] - a[1]);
        xs.push(a[0] + t * (b[0] - a[0]));
      }
    }
    xs.sort((p, q) => p - q);
    for (let i = 0; i + 1 < xs.length; i += 2) {
      const xa = Math.max(0, Math.floor(xs[i]));
      const xb = Math.min(w - 1, Math.ceil(xs[i + 1]) - 1);
      for (let x = xa; x <= xb; x++) setPx(buf, w, x, y, c);
    }
  }
}

function scalePts(pts, k) {
  return pts.map((p) => [p[0] * k, p[1] * k]);
}

function renderMark(size, { transparentBg = false } = {}) {
  const buf = Buffer.alloc(size * size * 4);
  const k = size / 1024;
  if (!transparentBg) fillRect(buf, size, 0, 0, size, size, DEEP);

  fillPolygon(buf, size, scalePts([[160, 500], [512, 250], [864, 500], [792, 528], [512, 318], [232, 528]], k), GOLD);
  fillRect(buf, size, 488 * k, 236 * k, 536 * k, 322 * k, CREAM);
  fillPolygon(buf, size, scalePts([[360, 560], [512, 530], [512, 820], [392, 848]], k), CREAM);
  fillPolygon(buf, size, scalePts([[664, 560], [512, 530], [512, 820], [632, 848]], k), GOLD);

  if (transparentBg) {
    for (let i = 0; i < buf.length; i += 4) {
      const dr = Math.abs(buf[i] - DEEP[0]);
      const dg = Math.abs(buf[i + 1] - DEEP[1]);
      const db = Math.abs(buf[i + 2] - DEEP[2]);
      if (dr + dg + db < 18) {
        buf[i] = 0;
        buf[i + 1] = 0;
        buf[i + 2] = 0;
        buf[i + 3] = 0;
      }
    }
  }
  return buf;
}

function boxResize(src, srcSize, dstSize) {
  const dst = Buffer.alloc(dstSize * dstSize * 4);
  const scale = srcSize / dstSize;
  for (let y = 0; y < dstSize; y++) {
    for (let x = 0; x < dstSize; x++) {
      const x0 = Math.floor(x * scale);
      const y0 = Math.floor(y * scale);
      const x1 = Math.min(srcSize, Math.ceil((x + 1) * scale));
      const y1 = Math.min(srcSize, Math.ceil((y + 1) * scale));
      let r = 0;
      let g = 0;
      let b = 0;
      let a = 0;
      let n = 0;
      for (let yy = y0; yy < y1; yy++) {
        for (let xx = x0; xx < x1; xx++) {
          const i = (yy * srcSize + xx) * 4;
          r += src[i];
          g += src[i + 1];
          b += src[i + 2];
          a += src[i + 3];
          n += 1;
        }
      }
      const di = (y * dstSize + x) * 4;
      dst[di] = Math.round(r / n);
      dst[di + 1] = Math.round(g / n);
      dst[di + 2] = Math.round(b / n);
      dst[di + 3] = Math.round(a / n);
    }
  }
  return dst;
}

function main() {
  const preview = renderMark(MASTER, { transparentBg: false });
  const fg = renderMark(MASTER, { transparentBg: true });
  const bg = Buffer.alloc(MASTER * MASTER * 4);
  fillRect(bg, MASTER, 0, 0, MASTER, MASTER, DEEP);
  const agc = boxResize(preview, MASTER, AGC);

  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePng(MASTER, MASTER, preview, { alpha: false }));
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(MASTER, MASTER, bg, { alpha: false }));
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePng(MASTER, MASTER, fg, { alpha: true }));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(AGC, AGC, agc, { alpha: false }));
  console.log('识趣阁 logo rendered');
}

main();
