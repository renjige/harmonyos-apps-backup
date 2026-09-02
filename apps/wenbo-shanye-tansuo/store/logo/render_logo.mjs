/**
 * Rasterize 山野探索 logo — ink ground + pine ridge + amber compass needle.
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [0x1a, 0x1d, 0x1f, 255];
const PINE = [0x2d, 0x8f, 0x6f, 255];
const CREAM = [0xf4, 0xef, 0xe6, 255];
const AMBER = [0xd4, 0xa8, 0x4b, 255];

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
  buf[i + 3] = c[3] ?? 255;
}

function fill(buf, w, color) {
  for (let i = 0; i < w * w; i++) {
    const p = i * 4;
    buf[p] = color[0];
    buf[p + 1] = color[1];
    buf[p + 2] = color[2];
    buf[p + 3] = 255;
  }
}

function fillPoly(buf, w, pts, color) {
  const ys = pts.map((p) => p[1]);
  const minY = Math.max(0, Math.floor(Math.min(...ys)));
  const maxY = Math.min(w - 1, Math.ceil(Math.max(...ys)));
  for (let y = minY; y <= maxY; y++) {
    const xs = [];
    for (let i = 0; i < pts.length; i++) {
      const [x1, y1] = pts[i];
      const [x2, y2] = pts[(i + 1) % pts.length];
      if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
        xs.push(x1 + ((y - y1) * (x2 - x1)) / (y2 - y1));
      }
    }
    xs.sort((a, b) => a - b);
    for (let i = 0; i + 1 < xs.length; i += 2) {
      const x0 = Math.max(0, Math.floor(xs[i]));
      const x1 = Math.min(w - 1, Math.ceil(xs[i + 1]));
      for (let x = x0; x <= x1; x++) setPx(buf, w, x, y, color);
    }
  }
}

function fillCircle(buf, w, cx, cy, r, color) {
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

function paintMark(buf, w) {
  fill(buf, w, BG);
  const s = w / 1024;
  fillPoly(
    buf,
    w,
    [
      [168 * s, 704 * s],
      [392 * s, 368 * s],
      [512 * s, 520 * s],
      [640 * s, 352 * s],
      [856 * s, 704 * s],
    ],
    PINE,
  );
  fillPoly(
    buf,
    w,
    [
      [392 * s, 704 * s],
      [512 * s, 548 * s],
      [640 * s, 704 * s],
    ],
    BG,
  );
  fillPoly(
    buf,
    w,
    [
      [548 * s, 268 * s],
      [612 * s, 412 * s],
      [548 * s, 456 * s],
      [484 * s, 412 * s],
    ],
    CREAM,
  );
  fillPoly(
    buf,
    w,
    [
      [548 * s, 292 * s],
      [592 * s, 404 * s],
      [548 * s, 432 * s],
      [504 * s, 404 * s],
    ],
    AMBER,
  );
  fillCircle(buf, w, 548 * s, 424 * s, 28 * s, CREAM);
  fillCircle(buf, w, 548 * s, 424 * s, 12 * s, BG);
}

function writePng(file, w, painter) {
  const buf = Buffer.alloc(w * w * 4);
  painter(buf, w);
  fs.writeFileSync(file, encodePng(w, w, buf));
}

function writeFg(file, w) {
  const buf = Buffer.alloc(w * w * 4);
  paintMark(buf, w);
  for (let i = 0; i < w * w; i++) {
    const p = i * 4;
    if (buf[p] === BG[0] && buf[p + 1] === BG[1] && buf[p + 2] === BG[2]) {
      buf[p + 3] = 0;
    }
  }
  fs.writeFileSync(file, encodePng(w, w, buf));
}

function writeBg(file, w) {
  const buf = Buffer.alloc(w * w * 4);
  fill(buf, w, BG);
  fs.writeFileSync(file, encodePng(w, w, buf));
}

writePng(path.join(__dirname, 'preview-1024.png'), MASTER, paintMark);
writeFg(path.join(__dirname, 'foreground.png'), MASTER);
writeBg(path.join(__dirname, 'background.png'), MASTER);
writePng(path.join(__dirname, 'agc-216.png'), AGC, paintMark);
console.log('Rendered 山野探索 logo PNGs');
