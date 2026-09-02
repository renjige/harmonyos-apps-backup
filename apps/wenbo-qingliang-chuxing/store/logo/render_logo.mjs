/**
 * Rasterize 清凉出行 logo — deep teal + cool halo + mint core.
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [0x0b, 0x2a, 0x36, 255];
const RING = [0xe8, 0xfb, 0xff, 255];
const MINT = [0x4e, 0xcd, 0xc4, 255];

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

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = 255;
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

function drawAnnulus(buf, w, cx, cy, rOut, rIn, color, gapStart, gapEnd) {
  const rOut2 = rOut * rOut;
  const rIn2 = rIn * rIn;
  const x0 = Math.max(0, Math.floor(cx - rOut - 1));
  const x1 = Math.min(w - 1, Math.ceil(cx + rOut + 1));
  const y0 = Math.max(0, Math.floor(cy - rOut - 1));
  const y1 = Math.min(w - 1, Math.ceil(cy + rOut + 1));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      const d2 = dx * dx + dy * dy;
      if (d2 > rOut2 || d2 < rIn2) continue;
      let ang = Math.atan2(dy, dx);
      if (ang < 0) ang += Math.PI * 2;
      if (ang >= gapStart && ang <= gapEnd) continue;
      setPx(buf, w, x, y, color);
    }
  }
}

function drawDisc(buf, w, cx, cy, r, color) {
  const r2 = r * r;
  const x0 = Math.max(0, Math.floor(cx - r - 1));
  const x1 = Math.min(w - 1, Math.ceil(cx + r + 1));
  const y0 = Math.max(0, Math.floor(cy - r - 1));
  const y1 = Math.min(w - 1, Math.ceil(cy + r + 1));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(buf, w, x, y, color);
    }
  }
}

function render(size) {
  const buf = Buffer.alloc(size * size * 4);
  fillBg(buf, size);
  const s = size / 1024;
  drawAnnulus(buf, size, 512 * s, 512 * s, 324 * s, 223 * s, RING, 5.2, 5.9);
  drawDisc(buf, size, 512 * s, 512 * s, 72 * s, MINT);
  drawDisc(buf, size, 718 * s, 306 * s, 28 * s, RING);
  return buf;
}

function writePng(file, size, buf) {
  fs.writeFileSync(file, encodePng(size, size, buf));
}

function main() {
  const master = render(MASTER);
  writePng(path.join(__dirname, 'preview-1024.png'), MASTER, master);
  writePng(path.join(__dirname, 'background.png'), MASTER, Buffer.from(master));
  const fg = Buffer.alloc(MASTER * MASTER * 4);
  // transparent-ish: copy master then keep pixels that aren't BG
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
  const agc = render(AGC);
  writePng(path.join(__dirname, 'agc-216.png'), AGC, agc);
  console.log('logo png written');
}

main();
