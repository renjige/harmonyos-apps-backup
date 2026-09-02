/**
 * 明阅坊 — 翻开书卷 + 光芒（墨蓝底 · 象牙书页 · 琥珀光）
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [26, 42, 58];
const PAGE = [245, 240, 232];
const GOLD = [201, 169, 110];

const LEFT_PAGE = [
  [248, 380],
  [500, 420],
  [500, 720],
  [236, 668],
];
const RIGHT_PAGE = [
  [524, 420],
  [776, 380],
  [788, 668],
  [524, 720],
];
const LIGHT_BEAM = [
  [472, 260],
  [552, 260],
  [580, 520],
  [444, 520],
];

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) {
      c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function encodePngRgb(width, height, rgb) {
  const raw = Buffer.alloc((width * 3 + 1) * height);
  for (let y = 0; y < height; y++) {
    const dest = y * (width * 3 + 1);
    raw[dest] = 0;
    rgb.copy(raw, dest + 1, y * width * 3, (y + 1) * width * 3);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function encodePngRgba(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    const dest = y * (width * 4 + 1);
    raw[dest] = 0;
    rgba.copy(raw, dest + 1, y * width * 4, (y + 1) * width * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function fillPoly(rgb, poly, color, size) {
  const xs = new Float64Array(size);
  for (let y = 0; y < size; y++) {
    let n = 0;
    for (let i = 0; i < poly.length; i++) {
      const a = poly[i];
      const b = poly[(i + 1) % poly.length];
      const y0 = a[1];
      const y1 = b[1];
      if ((y0 <= y && y1 > y) || (y1 <= y && y0 > y)) {
        const t = (y - y0) / (y1 - y0);
        xs[n++] = a[0] + t * (b[0] - a[0]);
      }
    }
    const slice = xs.slice(0, n).sort((p, q) => p - q);
    for (let k = 0; k + 1 < slice.length; k += 2) {
      const x0 = Math.max(0, Math.ceil(slice[k]));
      const x1 = Math.min(size - 1, Math.floor(slice[k + 1]));
      for (let x = x0; x <= x1; x++) {
        const o = (y * size + x) * 3;
        rgb[o] = color[0];
        rgb[o + 1] = color[1];
        rgb[o + 2] = color[2];
      }
    }
  }
}

function fillCanvas(color, size) {
  const rgb = Buffer.alloc(size * size * 3);
  for (let i = 0; i < size * size; i++) {
    rgb[i * 3] = color[0];
    rgb[i * 3 + 1] = color[1];
    rgb[i * 3 + 2] = color[2];
  }
  return rgb;
}

function drawMark(rgb, size) {
  fillPoly(rgb, LIGHT_BEAM, GOLD, size);
  fillPoly(rgb, LEFT_PAGE, PAGE, size);
  fillPoly(rgb, RIGHT_PAGE, PAGE, size);
}

function scaleRgb(src, srcSize, destSize) {
  const dest = Buffer.alloc(destSize * destSize * 3);
  for (let y = 0; y < destSize; y++) {
    const sy = Math.min(srcSize - 1, Math.round((y + 0.5) * srcSize / destSize - 0.5));
    for (let x = 0; x < destSize; x++) {
      const sx = Math.min(srcSize - 1, Math.round((x + 0.5) * srcSize / destSize - 0.5));
      const si = (sy * srcSize + sx) * 3;
      const di = (y * destSize + x) * 3;
      dest[di] = src[si];
      dest[di + 1] = src[si + 1];
      dest[di + 2] = src[si + 2];
    }
  }
  return dest;
}

function rgbToForeground(rgb, size) {
  const rgba = Buffer.alloc(size * size * 4);
  for (let i = 0; i < size * size; i++) {
    const r = rgb[i * 3];
    const g = rgb[i * 3 + 1];
    const b = rgb[i * 3 + 2];
    const isBg = r === BG[0] && g === BG[1] && b === BG[2];
    const o = i * 4;
    if (isBg) {
      rgba[o] = 0;
      rgba[o + 1] = 0;
      rgba[o + 2] = 0;
      rgba[o + 3] = 0;
    } else {
      rgba[o] = r;
      rgba[o + 1] = g;
      rgba[o + 2] = b;
      rgba[o + 3] = 255;
    }
  }
  return rgba;
}

function main() {
  const preview = fillCanvas(BG, MASTER);
  drawMark(preview, MASTER);
  const bg = fillCanvas(BG, MASTER);
  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePngRgb(MASTER, MASTER, preview));
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePngRgb(MASTER, MASTER, bg));
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePngRgba(MASTER, MASTER, rgbToForeground(preview, MASTER)));
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePngRgb(AGC, AGC, scaleRgb(preview, MASTER, AGC)));
  console.log('OK rendered 明阅坊 PNG masters');
}

main();
