#!/usr/bin/env node
/** Rasterize 益智王国 mark to PNG masters (pure Node, no Python). */
import fs from 'fs';
import path from 'path';
import { deflateSync } from 'zlib';
import { fileURLToPath } from 'url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const MASTER = 1024;
const AGC = 216;
const BG = [26, 26, 46, 255];
const FG = [245, 200, 66, 255];

function crc32(buf) {
  let c = ~0;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
  }
  return ~c >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(td));
  return Buffer.concat([len, td, crc]);
}

function encodePng(width, height, rgba) {
  const stride = width * 4 + 1;
  const raw = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    raw[y * stride] = 0;
    rgba.copy(raw, y * stride + 1, y * width * 4, (y + 1) * width * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

function fillRect(px, w, x0, y0, x1, y1, color, r = 0) {
  const rr = Math.max(0, r);
  for (let y = y0; y < y1; y++) {
    for (let x = x0; x < x1; x++) {
      if (x < 0 || y < 0 || x >= w) continue;
      let inside = true;
      if (rr > 0) {
        const dx = x < x0 + rr ? x0 + rr - x : x >= x1 - rr ? x - (x1 - rr - 1) : 0;
        const dy = y < y0 + rr ? y0 + rr - y : y >= y1 - rr ? y - (y1 - rr - 1) : 0;
        if (dx > 0 && dy > 0 && dx * dx + dy * dy > rr * rr) inside = false;
      }
      if (!inside) continue;
      const i = (y * w + x) * 4;
      px[i] = color[0];
      px[i + 1] = color[1];
      px[i + 2] = color[2];
      px[i + 3] = color[3];
    }
  }
}

function fillCircle(px, w, cx, cy, radius, color) {
  const r2 = radius * radius;
  for (let y = cy - radius; y <= cy + radius; y++) {
    for (let x = cx - radius; x <= cx + radius; x++) {
      if (x < 0 || y < 0 || x >= w) continue;
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy > r2) continue;
      const i = (y * w + x) * 4;
      px[i] = color[0];
      px[i + 1] = color[1];
      px[i + 2] = color[2];
      px[i + 3] = color[3];
    }
  }
}

function drawMark(size, transparentBg) {
  const px = Buffer.alloc(size * size * 4);
  const s = size / MASTER;
  const sc = (n) => Math.round(n * s);
  if (!transparentBg) {
    for (let i = 0; i < px.length; i += 4) {
      px[i] = BG[0];
      px[i + 1] = BG[1];
      px[i + 2] = BG[2];
      px[i + 3] = 255;
    }
  }
  fillRect(px, size, sc(232), sc(268), sc(276), sc(312), FG, sc(8));
  fillRect(px, size, sc(300), sc(268), sc(440), sc(312), FG, sc(8));
  fillRect(px, size, sc(464), sc(268), sc(604), sc(312), FG, sc(8));
  fillRect(px, size, sc(628), sc(268), sc(768), sc(312), FG, sc(8));
  fillRect(px, size, sc(300), sc(312), sc(768), sc(376), FG, sc(12));
  fillCircle(px, size, sc(254), sc(344), sc(38), FG);
  fillRect(px, size, sc(340), sc(456), sc(684), sc(512), FG, sc(12));
  fillRect(px, size, sc(300), sc(620), sc(768), sc(684), FG, sc(12));
  fillRect(px, size, sc(480), sc(312), sc(544), sc(684), FG, sc(12));
  return px;
}

function downsample(src, srcSize, dstSize) {
  const dst = Buffer.alloc(dstSize * dstSize * 4);
  const scale = srcSize / dstSize;
  for (let y = 0; y < dstSize; y++) {
    for (let x = 0; x < dstSize; x++) {
      const x0 = Math.floor(x * scale);
      const y0 = Math.floor(y * scale);
      const x1 = Math.max(x0 + 1, Math.floor((x + 1) * scale));
      const y1 = Math.max(y0 + 1, Math.floor((y + 1) * scale));
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
      const o = (y * dstSize + x) * 4;
      dst[o] = Math.round(r / n);
      dst[o + 1] = Math.round(g / n);
      dst[o + 2] = Math.round(b / n);
      dst[o + 3] = Math.round(a / n);
    }
  }
  return dst;
}

function solid(size, color) {
  const px = Buffer.alloc(size * size * 4);
  for (let i = 0; i < px.length; i += 4) {
    px[i] = color[0];
    px[i + 1] = color[1];
    px[i + 2] = color[2];
    px[i + 3] = color[3];
  }
  return px;
}

const preview = drawMark(MASTER, false);
fs.writeFileSync(path.join(ROOT, 'preview-1024.png'), encodePng(MASTER, MASTER, preview));
fs.writeFileSync(path.join(ROOT, 'background.png'), encodePng(MASTER, MASTER, solid(MASTER, BG)));
fs.writeFileSync(path.join(ROOT, 'foreground.png'), encodePng(MASTER, MASTER, drawMark(MASTER, true)));
const agc = downsample(preview, MASTER, AGC);
fs.writeFileSync(path.join(ROOT, 'agc-216.png'), encodePng(AGC, AGC, agc));
console.log('OK rendered PNG masters from Node mark');
