/**
 * Rasterize 筑科质量巡查 mark (Node, no Python).
 * Geometry matches symbol.svg: geometric Z + quality check.
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BLUE = [0x25, 0x63, 0xeb, 255];
const WHITE = [255, 255, 255, 255];

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
  const y0 = Math.max(0, Math.floor(cy - r - 1));
  const y1 = Math.min(w - 1, Math.ceil(cy + r + 1));
  const x0 = Math.max(0, Math.floor(cx - r - 1));
  const x1 = Math.min(w - 1, Math.ceil(cx + r + 1));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const d = (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2;
      const cov = Math.max(0, Math.min(1, r + 0.55 - Math.sqrt(d)));
      if (cov > 0) blendPx(buf, w, x, y, c, cov);
    }
  }
}

function strokeLine(buf, w, x0, y0, x1, y1, width, c) {
  const dx = x1 - x0;
  const dy = y1 - y0;
  const len = Math.hypot(dx, dy) || 1;
  const steps = Math.ceil(len);
  const r = width / 2;
  for (let i = 0; i <= steps; i++) {
    const t = i / steps;
    fillCircle(buf, w, x0 + dx * t, y0 + dy * t, r, c);
  }
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

function renderMark(size, { transparentBg = false } = {}) {
  const buf = Buffer.alloc(size * size * 4);
  const k = size / 1024;
  if (!transparentBg) fillRect(buf, size, 0, 0, size, size, BLUE);
  strokeLine(buf, size, 236 * k, 286 * k, 788 * k, 286 * k, 96 * k, WHITE);
  strokeLine(buf, size, 760 * k, 300 * k, 268 * k, 724 * k, 96 * k, WHITE);
  strokeLine(buf, size, 236 * k, 738 * k, 560 * k, 738 * k, 96 * k, WHITE);
  strokeLine(buf, size, 500 * k, 640 * k, 640 * k, 790 * k, 88 * k, WHITE);
  strokeLine(buf, size, 640 * k, 790 * k, 860 * k, 470 * k, 88 * k, WHITE);
  if (transparentBg) {
    for (let i = 0; i < buf.length; i += 4) {
      const dr = Math.abs(buf[i] - BLUE[0]);
      const dg = Math.abs(buf[i + 1] - BLUE[1]);
      const db = Math.abs(buf[i + 2] - BLUE[2]);
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

function main() {
  const preview = renderMark(MASTER, { transparentBg: false });
  const fg = renderMark(MASTER, { transparentBg: true });
  const bg = Buffer.alloc(MASTER * MASTER * 4);
  fillRect(bg, MASTER, 0, 0, MASTER, MASTER, BLUE);
  const agc = boxResize(preview, MASTER, AGC);

  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePng(MASTER, MASTER, preview, { alpha: false }));
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(MASTER, MASTER, bg, { alpha: false }));
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePng(MASTER, MASTER, fg, { alpha: true }));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(AGC, AGC, agc, { alpha: false }));
  console.log('logo rendered');
}

main();
