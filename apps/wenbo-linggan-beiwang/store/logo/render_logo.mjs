/**
 * Rasterize 灵感备忘 mark (Node, no Python/Pillow).
 * Geometry matches symbol.svg.
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const DEEP = [0x2b, 0x17, 0x48, 255];
const FOG = [0xf5, 0xf6, 0xfa, 255];
const CREAM = [0xf5, 0xf6, 0xfa];
const INK = [0x2b, 0x17, 0x48];
const MUTED = [0x64, 0x74, 0x8b];

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

function blendPx(buf, w, x, y, c, a) {
  if (a <= 0 || x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  const da = buf[i + 3] / 255;
  const sa = Math.min(1, a) * (c[3] / 255);
  const outA = sa + da * (1 - sa);
  if (outA <= 0) {
    buf[i + 3] = 0;
    return;
  }
  buf[i] = Math.round((c[0] * sa + buf[i] * da * (1 - sa)) / outA);
  buf[i + 1] = Math.round((c[1] * sa + buf[i + 1] * da * (1 - sa)) / outA);
  buf[i + 2] = Math.round((c[2] * sa + buf[i + 2] * da * (1 - sa)) / outA);
  buf[i + 3] = Math.round(outA * 255);
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

function fillCircle(buf, w, cx, cy, r, c) {
  const r2 = r * r;
  const y0 = Math.max(0, Math.floor(cy - r - 1));
  const y1 = Math.min(w - 1, Math.ceil(cy + r + 1));
  const x0 = Math.max(0, Math.floor(cx - r - 1));
  const x1 = Math.min(w - 1, Math.ceil(cx + r + 1));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const d = (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2;
      const cov = Math.max(0, Math.min(1, (r + 0.55 - Math.sqrt(d))));
      if (cov > 0) blendPx(buf, w, x, y, c, cov);
    }
  }
}

function fillRoundRect(buf, w, x, y, rw, rh, rad, c) {
  const r = Math.min(rad, rw / 2, rh / 2);
  fillRect(buf, w, x + r, y, x + rw - r, y + rh, c);
  fillRect(buf, w, x, y + r, x + rw, y + rh - r, c);
  fillCircle(buf, w, x + r, y + r, r, c);
  fillCircle(buf, w, x + rw - r, y + r, r, c);
  fillCircle(buf, w, x + r, y + rh - r, r, c);
  fillCircle(buf, w, x + rw - r, y + rh - r, r, c);
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

  fillRoundRect(buf, size, 264 * k, 236 * k, 524 * k, 624 * k, 80 * k, FOG);
  fillPolygon(buf, size, scalePts([[640, 236], [788, 236], [788, 384]], k), DEEP);
  fillPolygon(
    buf,
    size,
    scalePts(
      [
        [512, 456],
        [548, 544],
        [636, 580],
        [548, 616],
        [512, 704],
        [476, 616],
        [388, 580],
        [476, 544],
      ],
      k,
    ),
    DEEP,
  );

  if (transparentBg) {
    for (let i = 0; i < buf.length; i += 4) {
      const dr = Math.abs(buf[i] - DEEP[0]);
      const dg = Math.abs(buf[i + 1] - DEEP[1]);
      const db = Math.abs(buf[i + 2] - DEEP[2]);
      if (buf[i + 3] === 0 || (dr + dg + db < 24 && buf[i] < 80)) {
        buf[i] = 0;
        buf[i + 1] = 0;
        buf[i + 2] = 0;
        buf[i + 3] = 0;
      }
    }
  }
  return buf;
}

function nearestResize(src, srcSize, dstSize) {
  const dst = Buffer.alloc(dstSize * dstSize * 4);
  for (let y = 0; y < dstSize; y++) {
    const sy = Math.min(srcSize - 1, Math.round((y + 0.5) * srcSize / dstSize - 0.5));
    for (let x = 0; x < dstSize; x++) {
      const sx = Math.min(srcSize - 1, Math.round((x + 0.5) * srcSize / dstSize - 0.5));
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

  const boardW = 1280;
  const boardH = 360;
  const board = Buffer.alloc(boardW * boardH * 4);
  for (let i = 0; i < boardW * boardH; i++) {
    board[i * 4] = CREAM[0];
    board[i * 4 + 1] = CREAM[1];
    board[i * 4 + 2] = CREAM[2];
    board[i * 4 + 3] = 255;
  }
  const icon = boxResize(preview, MASTER, 288);
  for (let y = 0; y < 288; y++) {
    for (let x = 0; x < 288; x++) {
      const si = (y * 288 + x) * 4;
      const di = ((y + 36) * boardW + (x + 40)) * 4;
      board[di] = icon[si];
      board[di + 1] = icon[si + 1];
      board[di + 2] = icon[si + 2];
      board[di + 3] = 255;
    }
  }
  fs.writeFileSync(path.join(ROOT, 'logo-horizontal.png'), encodePng(boardW, boardH, board, { alpha: false }));
  void nearestResize;
  void INK;
  void MUTED;
  console.log('logo rendered');
}

main();
