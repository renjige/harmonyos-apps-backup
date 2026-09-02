/**
 * 职业课堂 — 渐变质感封面（非纯色块）
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(__dirname, '../entry/src/main/resources/base/media');

const W = 640;
const H = 420;

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crc]);
}

function lerp(a, b, t) {
  return Math.round(a + (b - a) * t);
}

function mix(c1, c2, t) {
  return [lerp(c1[0], c2[0], t), lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t)];
}

function dist(x, y, cx, cy) {
  const dx = x - cx;
  const dy = y - cy;
  return Math.sqrt(dx * dx + dy * dy);
}

/** @typedef {{ topLeft: number[], bottomRight: number[], accent?: number[], orbs?: {x:number,y:number,r:number,c:number[]}[] }} Scene */

const scenes = {
  hero_career: {
    topLeft: [15, 22, 70],
    bottomRight: [35, 55, 120],
    accent: [243, 156, 18],
    orbs: [
      { x: 0.78, y: 0.22, r: 0.35, c: [243, 156, 18] },
      { x: 0.15, y: 0.75, r: 0.28, c: [90, 120, 200] },
    ],
  },
  cover_skill: {
    topLeft: [26, 42, 108],
    bottomRight: [52, 72, 140],
    accent: [243, 156, 18],
    orbs: [{ x: 0.85, y: 0.15, r: 0.25, c: [243, 180, 60] }],
  },
  cover_manage: {
    topLeft: [20, 35, 95],
    bottomRight: [45, 65, 115],
    accent: [212, 175, 55],
    orbs: [{ x: 0.2, y: 0.3, r: 0.3, c: [180, 140, 80] }],
  },
  cover_comm: {
    topLeft: [30, 50, 110],
    bottomRight: [60, 90, 150],
    accent: [243, 156, 18],
    orbs: [{ x: 0.7, y: 0.65, r: 0.32, c: [100, 140, 220] }],
  },
  cover_plan: {
    topLeft: [22, 38, 88],
    bottomRight: [70, 55, 105],
    accent: [243, 156, 18],
    orbs: [{ x: 0.5, y: 0.4, r: 0.4, c: [140, 100, 180] }],
  },
  cover_career: {
    topLeft: [18, 30, 80],
    bottomRight: [40, 60, 100],
    accent: [243, 156, 18],
    orbs: [{ x: 0.75, y: 0.5, r: 0.35, c: [60, 90, 160] }],
  },
  banner_wisdom: {
    topLeft: [26, 42, 108],
    bottomRight: [45, 58, 95],
    accent: [243, 156, 18],
    orbs: [{ x: 0.9, y: 0.5, r: 0.45, c: [243, 156, 18] }],
  },
};

function renderScene(scene) {
  const rgb = Buffer.alloc(W * H * 3);
  for (let y = 0; y < H; y++) {
    const ty = y / (H - 1);
    for (let x = 0; x < W; x++) {
      const tx = x / (W - 1);
      const t = tx * 0.55 + ty * 0.45;
      let c = mix(scene.topLeft, scene.bottomRight, t);
      if (scene.orbs) {
        for (const o of scene.orbs) {
          const d = dist(x, y, o.x * W, o.y * H, 0);
          const influence = Math.max(0, 1 - d / (o.r * W));
          const blend = influence * influence * 0.55;
          c = mix(c, o.c, blend);
        }
      }
      // subtle vignette
      const cx = (x / W - 0.5) * 1.4;
      const cy = (y / H - 0.5) * 1.4;
      const vig = 1 - (cx * cx + cy * cy) * 0.15;
      const o = (y * W + x) * 3;
      rgb[o] = Math.min(255, Math.round(c[0] * vig));
      rgb[o + 1] = Math.min(255, Math.round(c[1] * vig));
      rgb[o + 2] = Math.min(255, Math.round(c[2] * vig));
    }
  }
  // accent stripe bottom
  if (scene.accent) {
    const stripeH = Math.floor(H * 0.04);
    for (let y = H - stripeH; y < H; y++) {
      for (let x = 0; x < W; x++) {
        const o = (y * W + x) * 3;
        rgb[o] = scene.accent[0];
        rgb[o + 1] = scene.accent[1];
        rgb[o + 2] = scene.accent[2];
      }
    }
  }
  return rgb;
}

function encodePng(w, h, rgb) {
  const raw = Buffer.alloc((w * 3 + 1) * h);
  for (let y = 0; y < h; y++) {
    raw[y * (w * 3 + 1)] = 0;
    rgb.copy(raw, y * (w * 3 + 1) + 1, y * w * 3, (y + 1) * w * 3);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
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

fs.mkdirSync(outDir, { recursive: true });
for (const [name, scene] of Object.entries(scenes)) {
  const rgb = renderScene(scene);
  fs.writeFileSync(path.join(outDir, `${name}.png`), encodePng(W, H, rgb));
  console.log('wrote', name);
}
