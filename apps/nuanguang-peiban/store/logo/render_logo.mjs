/**
 * 暖光陪伴 logo — 米白底 + 暖阳金光晕 + 相依轮廓
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [0xff, 0xf8, 0xf0, 255];
const GOLD = [0xf5, 0xa6, 0x23, 255];
const CORAL = [0xff, 0x8a, 0x7a, 255];
const GLOW = [0xff, 0xd4, 0xb8, 255];

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const t = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0);
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

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = c[3] ?? 255;
}

function fillBg(buf, w) {
  for (let i = 0; i < w * w; i++) {
    const p = i * 4;
    buf[p] = BG[0];
    buf[p + 1] = BG[1];
    buf[p + 2] = BG[2];
    buf[p + 3] = 255;
  }
}

function drawDisc(buf, w, cx, cy, r, color) {
  const r2 = r * r;
  for (let y = Math.floor(cy - r - 1); y <= Math.ceil(cy + r + 1); y++) {
    for (let x = Math.floor(cx - r - 1); x <= Math.ceil(cx + r + 1); x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(buf, w, x, y, color);
    }
  }
}

function drawRing(buf, w, cx, cy, rOut, rIn, color) {
  const ro2 = rOut * rOut;
  const ri2 = rIn * rIn;
  for (let y = Math.floor(cy - rOut - 1); y <= Math.ceil(cy + rOut + 1); y++) {
    for (let x = Math.floor(cx - rOut - 1); x <= Math.ceil(cx + rOut + 1); x++) {
      const d2 = (x - cx) ** 2 + (y - cy) ** 2;
      if (d2 <= ro2 && d2 >= ri2) setPx(buf, w, x, y, color);
    }
  }
}

function render(size) {
  const buf = Buffer.alloc(size * size * 4);
  fillBg(buf, size);
  const s = size / 1024;
  const cx = 512 * s;
  const cy = 512 * s;
  drawRing(buf, size, cx, cy, 300 * s, 260 * s, GLOW);
  drawRing(buf, size, cx, cy, 220 * s, 192 * s, GOLD);
  drawDisc(buf, size, cx, cy, 140 * s, [0xf5, 0xa6, 0x23, 64]);
  drawDisc(buf, size, cx - 92 * s, cy - 32 * s, 52 * s, GOLD);
  drawDisc(buf, size, cx + 92 * s, cy - 32 * s, 52 * s, CORAL);
  return buf;
}

function writePng(file, size, buf) {
  fs.writeFileSync(file, encodePng(size, size, buf));
}

function main() {
  fs.mkdirSync(__dirname, { recursive: true });
  const master = render(MASTER);
  writePng(path.join(__dirname, 'preview-1024.png'), MASTER, master);
  writePng(path.join(__dirname, 'background.png'), MASTER, Buffer.from(master));
  const fg = Buffer.alloc(MASTER * MASTER * 4);
  for (let i = 0; i < MASTER * MASTER; i++) {
    const p = i * 4;
    const isBg = master[p] === BG[0] && master[p + 1] === BG[1] && master[p + 2] === BG[2];
    if (isBg) {
      fg[p] = 0;
      fg[p + 1] = 0;
      fg[p + 2] = 0;
      fg[p + 3] = 0;
    } else {
      fg[p] = master[p];
      fg[p + 1] = master[p + 1];
      fg[p + 2] = master[p + 2];
      fg[p + 3] = 255;
    }
  }
  writePng(path.join(__dirname, 'foreground.png'), MASTER, fg);
  writePng(path.join(__dirname, 'agc-216.png'), AGC, render(AGC));
  console.log('warm-companion logo written');
}

main();
