#!/usr/bin/env node
/**
 * Rasterize 少儿画苑 brush+seedling mark (no Python / Pillow).
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { deflateSync, crc32 } from 'zlib';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const DEEP = [74, 42, 28];
const CREAM = [255, 245, 238];

function crc(buf) {
  return crc32(buf) >>> 0;
}

function chunk(type, data) {
  const t = Buffer.from(type);
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const body = Buffer.concat([t, data]);
  const c = Buffer.alloc(4);
  c.writeUInt32BE(crc(body));
  return Buffer.concat([len, body, c]);
}

function encodePng(width, height, bytesPerPixel, pixels) {
  const stride = width * bytesPerPixel;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (stride + 1)] = 0;
    pixels.copy(raw, y * (stride + 1) + 1, y * stride, (y + 1) * stride);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = bytesPerPixel === 4 ? 6 : 2;
  const png = Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
  return png;
}

function setRgb(buf, x, y, c) {
  if (x < 0 || y < 0 || x >= MASTER || y >= MASTER) return;
  const i = (y * MASTER + x) * 3;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
}

function fillRoundedRect(buf, x0, y0, x1, y1, r, c) {
  const left = Math.min(x0, x1);
  const right = Math.max(x0, x1);
  const top = Math.min(y0, y1);
  const bot = Math.max(y0, y1);
  const rad = Math.max(0, r);
  for (let y = top; y <= bot; y++) {
    for (let x = left; x <= right; x++) {
      let inside = true;
      if (x < left + rad && y < top + rad) {
        const dx = x - (left + rad);
        const dy = y - (top + rad);
        inside = dx * dx + dy * dy <= rad * rad;
      } else if (x > right - rad && y < top + rad) {
        const dx = x - (right - rad);
        const dy = y - (top + rad);
        inside = dx * dx + dy * dy <= rad * rad;
      } else if (x < left + rad && y > bot - rad) {
        const dx = x - (left + rad);
        const dy = y - (bot - rad);
        inside = dx * dx + dy * dy <= rad * rad;
      } else if (x > right - rad && y > bot - rad) {
        const dx = x - (right - rad);
        const dy = y - (bot - rad);
        inside = dx * dx + dy * dy <= rad * rad;
      }
      if (inside) setRgb(buf, x, y, c);
    }
  }
}

function fillTriangle(buf, ax, ay, bx, by, cx, cy, color) {
  const minX = Math.max(0, Math.floor(Math.min(ax, bx, cx)));
  const maxX = Math.min(MASTER - 1, Math.ceil(Math.max(ax, bx, cx)));
  const minY = Math.max(0, Math.floor(Math.min(ay, by, cy)));
  const maxY = Math.min(MASTER - 1, Math.ceil(Math.max(ay, by, cy)));
  const area = (bx - ax) * (cy - ay) - (cx - ax) * (by - ay);
  if (area === 0) return;
  for (let y = minY; y <= maxY; y++) {
    for (let x = minX; x <= maxX; x++) {
      const w0 = (bx - x) * (cy - y) - (cx - x) * (by - y);
      const w1 = (cx - x) * (ay - y) - (ax - x) * (cy - y);
      const w2 = (ax - x) * (by - y) - (bx - x) * (ay - y);
      if ((w0 >= 0 && w1 >= 0 && w2 >= 0) || (w0 <= 0 && w1 <= 0 && w2 <= 0)) {
        setRgb(buf, x, y, color);
      }
    }
  }
}

function fillEllipseRot(buf, cx, cy, rx, ry, deg, color) {
  const rad = (deg * Math.PI) / 180;
  const cos = Math.cos(rad);
  const sin = Math.sin(rad);
  const pad = Math.ceil(Math.max(rx, ry) + 2);
  for (let y = cy - pad; y <= cy + pad; y++) {
    for (let x = cx - pad; x <= cx + pad; x++) {
      const dx = x - cx;
      const dy = y - cy;
      const lx = dx * cos + dy * sin;
      const ly = -dx * sin + dy * cos;
      if ((lx * lx) / (rx * rx) + (ly * ly) / (ry * ry) <= 1) {
        setRgb(buf, x, y, color);
      }
    }
  }
}

function drawMark(bg, fg) {
  const buf = Buffer.alloc(MASTER * MASTER * 3);
  for (let i = 0; i < buf.length; i += 3) {
    buf[i] = bg[0];
    buf[i + 1] = bg[1];
    buf[i + 2] = bg[2];
  }
  fillRoundedRect(buf, 470, 548, 554, 824, 42, fg);
  fillRoundedRect(buf, 462, 500, 562, 556, 10, fg);
  fillTriangle(buf, 512, 236, 628, 508, 396, 508, fg);
  fillEllipseRot(buf, 404, 300, 78, 34, -32, fg);
  fillEllipseRot(buf, 620, 292, 78, 34, 32, fg);
  fillRoundedRect(buf, 500, 268, 524, 340, 12, bg);
  return buf;
}

function rgbToRgba(rgb, keepBg) {
  const out = Buffer.alloc(MASTER * MASTER * 4);
  for (let i = 0, j = 0; i < rgb.length; i += 3, j += 4) {
    const r = rgb[i];
    const g = rgb[i + 1];
    const b = rgb[i + 2];
    const isBg = r < 90 && g < 55 && b < 40;
    out[j] = r;
    out[j + 1] = g;
    out[j + 2] = b;
    out[j + 3] = keepBg || !isBg ? 255 : 0;
    if (!keepBg && !isBg) {
      out[j] = CREAM[0];
      out[j + 1] = CREAM[1];
      out[j + 2] = CREAM[2];
      out[j + 3] = 255;
    }
  }
  return out;
}

function resizeNearest(srcRgb, srcW, srcH, dstW, dstH) {
  const dst = Buffer.alloc(dstW * dstH * 3);
  for (let y = 0; y < dstH; y++) {
    const sy = Math.min(srcH - 1, Math.floor((y * srcH) / dstH));
    for (let x = 0; x < dstW; x++) {
      const sx = Math.min(srcW - 1, Math.floor((x * srcW) / dstW));
      const si = (sy * srcW + sx) * 3;
      const di = (y * dstW + x) * 3;
      dst[di] = srcRgb[si];
      dst[di + 1] = srcRgb[si + 1];
      dst[di + 2] = srcRgb[si + 2];
    }
  }
  return dst;
}

function main() {
  const preview = drawMark(DEEP, CREAM);
  fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePng(MASTER, MASTER, 3, preview));
  const bg = Buffer.alloc(MASTER * MASTER * 3);
  for (let i = 0; i < bg.length; i += 3) {
    bg[i] = DEEP[0];
    bg[i + 1] = DEEP[1];
    bg[i + 2] = DEEP[2];
  }
  fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(MASTER, MASTER, 3, bg));
  const fg = rgbToRgba(preview, false);
  fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePng(MASTER, MASTER, 4, fg));
  const agc = resizeNearest(preview, MASTER, MASTER, AGC, AGC);
  fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(AGC, AGC, 3, agc));
  console.log('OK rendered PNG masters from brush-seedling mark (node)');
}

main();
