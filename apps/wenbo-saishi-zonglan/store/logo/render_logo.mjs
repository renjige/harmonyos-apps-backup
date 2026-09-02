#!/usr/bin/env node
/**
 * Rasterize store/logo/symbol geometry → HarmonyOS layered icon (1024×1024).
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const SIZE = 1024;
const AGC = 216;
const BG = { r: 15, g: 23, b: 42 };
const WHITE = { r: 255, g: 255, b: 255 };
const PURPLE = { r: 124, g: 58, b: 237 };

function createCanvas(w, h, fill) {
  const data = Buffer.alloc(w * h * 4);
  for (let i = 0; i < w * h; i++) {
    const o = i * 4;
    data[o] = fill.r;
    data[o + 1] = fill.g;
    data[o + 2] = fill.b;
    data[o + 3] = fill.a !== undefined ? fill.a : 255;
  }
  return { w, h, data };
}

function createTransparent(w, h) {
  return createCanvas(w, h, { r: 0, g: 0, b: 0, a: 0 });
}

function mix(dst, i, color, a) {
  if (a <= 0) return;
  const o = i * 4;
  const ia = Math.min(1, a);
  const dstA = dst[o + 3] / 255;
  const outA = ia + dstA * (1 - ia);
  if (outA <= 0) return;
  dst[o] = Math.round((color.r * ia + dst[o] * dstA * (1 - ia)) / outA);
  dst[o + 1] = Math.round((color.g * ia + dst[o + 1] * dstA * (1 - ia)) / outA);
  dst[o + 2] = Math.round((color.b * ia + dst[o + 2] * dstA * (1 - ia)) / outA);
  dst[o + 3] = Math.round(outA * 255);
}

function strokeCircle(canvas, cx, cy, radius, width, color) {
  const { w, h, data } = canvas;
  const hw = width / 2;
  const pad = Math.ceil(hw + 2);
  const x0 = Math.max(0, Math.floor(cx - radius - pad));
  const y0 = Math.max(0, Math.floor(cy - radius - pad));
  const x1 = Math.min(w - 1, Math.ceil(cx + radius + pad));
  const y1 = Math.min(h - 1, Math.ceil(cy + radius + pad));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const d = Math.abs(Math.hypot(x + 0.5 - cx, y + 0.5 - cy) - radius);
      const a = 1 - Math.max(0, (d - hw) / 1.2);
      mix(data, y * w + x, color, a);
    }
  }
}

function strokeCubic(canvas, p0, p1, p2, p3, width, color) {
  const { w, h, data } = canvas;
  const hw = width / 2;
  const samples = 420;
  const pts = [];
  for (let i = 0; i <= samples; i++) {
    const t = i / samples;
    const u = 1 - t;
    const x =
      u * u * u * p0.x +
      3 * u * u * t * p1.x +
      3 * u * t * t * p2.x +
      t * t * t * p3.x;
    const y =
      u * u * u * p0.y +
      3 * u * u * t * p1.y +
      3 * u * t * t * p2.y +
      t * t * t * p3.y;
    pts.push({ x, y });
  }
  let minX = w;
  let minY = h;
  let maxX = 0;
  let maxY = 0;
  for (const p of pts) {
    minX = Math.min(minX, p.x);
    minY = Math.min(minY, p.y);
    maxX = Math.max(maxX, p.x);
    maxY = Math.max(maxY, p.y);
  }
  const pad = Math.ceil(hw + 2);
  const x0 = Math.max(0, Math.floor(minX - pad));
  const y0 = Math.max(0, Math.floor(minY - pad));
  const x1 = Math.min(w - 1, Math.ceil(maxX + pad));
  const y1 = Math.min(h - 1, Math.ceil(maxY + pad));
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      let best = 1e9;
      const px = x + 0.5;
      const py = y + 0.5;
      for (const p of pts) {
        const d = Math.hypot(px - p.x, py - p.y);
        if (d < best) best = d;
      }
      const a = 1 - Math.max(0, (best - hw) / 1.2);
      mix(data, y * w + x, color, a);
    }
  }
}

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
  const typeBuf = Buffer.from(type, 'ascii');
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const crcSrc = Buffer.concat([typeBuf, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcSrc), 0);
  return Buffer.concat([len, crcSrc, crc]);
}

function encodePng(canvas) {
  const { w, h, data } = canvas;
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) {
    const row = y * (w * 4 + 1);
    raw[row] = 0;
    data.copy(raw, row + 1, y * w * 4, (y + 1) * w * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function composePreview(fg, bg) {
  const out = createCanvas(SIZE, SIZE, BG);
  for (let i = 0; i < SIZE * SIZE; i++) {
    const o = i * 4;
    const ba = bg.data[o + 3] / 255;
    const fa = fg.data[o + 3] / 255;
    out.data[o] = Math.round(bg.data[o] * ba + fg.data[o] * fa * (1 - ba));
    out.data[o + 1] = Math.round(bg.data[o + 1] * ba + fg.data[o + 1] * fa * (1 - ba));
    out.data[o + 2] = Math.round(bg.data[o + 2] * ba + fg.data[o + 2] * fa * (1 - ba));
    out.data[o + 3] = 255;
  }
  return out;
}

function writePng(filePath, canvas) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, encodePng(canvas));
}

function writeLayeredJson(dir) {
  const json = JSON.stringify({
    'layered-image': {
      background: '$media:icon_background',
      foreground: '$media:icon_foreground',
    },
  }, null, 2);
  fs.writeFileSync(path.join(dir, 'layered_image.json'), json);
}

function main() {
  const fg = createTransparent(SIZE, SIZE);
  strokeCircle(fg, 512, 512, 306, 72, WHITE);
  strokeCubic(
    fg,
    { x: 208, y: 600 },
    { x: 248, y: 792 },
    { x: 468, y: 888 },
    { x: 692, y: 836 },
    56,
    PURPLE,
  );

  const bg = createCanvas(SIZE, SIZE, BG);
  const preview = composePreview(fg, bg);

  const delivery = path.resolve(ROOT, '../..');
  const app = path.join(delivery, 'app');
  const appScopeMedia = path.join(app, 'AppScope/resources/base/media');
  const entryMedia = path.join(app, 'entry/src/main/resources/base/media');

  writePng(path.join(ROOT, 'foreground.png'), fg);
  writePng(path.join(ROOT, 'background.png'), bg);
  writePng(path.join(ROOT, 'preview-1024.png'), preview);
  writePng(path.join(appScopeMedia, 'icon_foreground.png'), fg);
  writePng(path.join(appScopeMedia, 'icon_background.png'), bg);
  // preview 仅落 store/logo，禁止写入 AppScope media（资源名不可含连字符）
  writeLayeredJson(appScopeMedia);
  writeLayeredJson(entryMedia);

  // Legacy start window icon (144) — from preview composite
  const start144 = createCanvas(144, 144, BG);
  const scale = SIZE / 144;
  for (let y = 0; y < 144; y++) {
    for (let x = 0; x < 144; x++) {
      const sx = Math.min(SIZE - 1, Math.floor(x * scale));
      const sy = Math.min(SIZE - 1, Math.floor(y * scale));
      const si = (sy * SIZE + sx) * 4;
      const di = (y * 144 + x) * 4;
      start144.data[di] = preview.data[si];
      start144.data[di + 1] = preview.data[si + 1];
      start144.data[di + 2] = preview.data[si + 2];
      start144.data[di + 3] = 255;
    }
  }
  writePng(path.join(entryMedia, 'startIcon.png'), start144);

  const legacyIcon = path.join(entryMedia, 'icon.png');
  if (fs.existsSync(legacyIcon)) {
    fs.unlinkSync(legacyIcon);
  }
  const legacyAppIcon = path.join(appScopeMedia, 'app_icon.png');
  if (fs.existsSync(legacyAppIcon)) {
    fs.unlinkSync(legacyAppIcon);
  }

  console.log('OK layered icon: icon_foreground/icon_background 1024×1024');
  console.log('OK layered_image.json in AppScope + entry');
  console.log('OK preview-1024.png + store/logo masters');
}

main();
