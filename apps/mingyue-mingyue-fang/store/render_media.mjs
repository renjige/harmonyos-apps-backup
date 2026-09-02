/**
 * 明阅坊 · 离线兜底占位图（勿用于正式交付）
 * 正式资产：store/visual/ 摄影图 → node store/compress_media.mjs
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const OUT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../app/entry/src/main/resources/base/media');
const W = 640;
const H = 480;

const ITEMS = [
  { name: 'hero_reading_desk', top: [26, 42, 58], bottom: [45, 65, 85], accent: [201, 169, 110], kind: 'hero', motif: 0 },
  { name: 'hero_reading_classics', top: [32, 48, 68], bottom: [26, 42, 58], accent: [201, 169, 110], kind: 'hero', motif: 1 },
  { name: 'hero_borrow_books', top: [40, 55, 72], bottom: [26, 42, 58], accent: [245, 240, 232], kind: 'hero', motif: 2 },
  { name: 'hero_honest_reading', top: [26, 42, 58], bottom: [60, 80, 100], accent: [201, 169, 110], kind: 'hero', motif: 3 },
  { name: 'hero_poetry_grace', top: [50, 65, 82], bottom: [26, 42, 58], accent: [201, 169, 110], kind: 'hero', motif: 4 },
  { name: 'hero_dialogue_books', top: [26, 42, 58], bottom: [35, 52, 70], accent: [245, 240, 232], kind: 'hero', motif: 5 },
  { name: 'hero_ladder_books', top: [30, 46, 64], bottom: [26, 42, 58], accent: [201, 169, 110], kind: 'hero', motif: 6 },
  // 《活着》— 暖褐左侧书脊 + 琥珀光
  { name: 'book_classics_1', top: [42, 32, 28], bottom: [26, 42, 58], accent: [201, 169, 110], kind: 'book', motif: 1 },
  // 《百年孤独》— 深紫 + 斜向金纹
  { name: 'book_classics_2', top: [48, 38, 62], bottom: [22, 28, 42], accent: [201, 169, 110], kind: 'book', motif: 2 },
  // 《苏菲的世界》— 青绿哲学感
  { name: 'book_classics_3', top: [28, 52, 58], bottom: [18, 38, 48], accent: [180, 210, 195], kind: 'book', motif: 3 },
  // 《人类简史》— 沙色大地 + 大圆
  { name: 'book_classics_4', top: [72, 58, 42], bottom: [38, 48, 58], accent: [201, 169, 110], kind: 'book', motif: 4 },
  // 《瓦尔登湖》— 湖蓝下半
  { name: 'book_classics_5', top: [38, 58, 72], bottom: [22, 48, 68], accent: [160, 195, 220], kind: 'book', motif: 5 },
  // 《思考，快与慢》— 灰蓝理性 + 双块
  { name: 'book_classics_6', top: [52, 58, 68], bottom: [28, 36, 48], accent: [201, 169, 110], kind: 'book', motif: 6 },
  { name: 'book_default', top: [26, 42, 58], bottom: [45, 65, 85], accent: [201, 169, 110], kind: 'book', motif: 0 },
];

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
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]);
}

function lerp(a, b, t) {
  return Math.round(a + (b - a) * t);
}

function setPx(rgb, x, y, r, g, b) {
  if (x < 0 || y < 0 || x >= W || y >= H) return;
  const o = (y * W + x) * 3;
  rgb[o] = r;
  rgb[o + 1] = g;
  rgb[o + 2] = b;
}

function fillRect(rgb, x0, y0, w, h, color) {
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      setPx(rgb, x, y, color[0], color[1], color[2]);
    }
  }
}

function fillCircle(rgb, cx, cy, radius, color) {
  for (let dy = -radius; dy <= radius; dy++) {
    for (let dx = -radius; dx <= radius; dx++) {
      if (dx * dx + dy * dy <= radius * radius) {
        setPx(rgb, cx + dx, cy + dy, color[0], color[1], color[2]);
      }
    }
  }
}

function applyBookMotif(rgb, motif, accent) {
  if (motif === 1) {
    fillRect(rgb, 0, 0, Math.floor(W * 0.22), H, [92, 58, 42]);
    fillRect(rgb, Math.floor(W * 0.22), Math.floor(H * 0.62), Math.floor(W * 0.78), 12, accent);
    fillCircle(rgb, Math.floor(W * 0.72), Math.floor(H * 0.35), 48, [220, 180, 120]);
  } else if (motif === 2) {
    for (let i = -3; i < 8; i++) {
      const offset = i * 56;
      for (let y = 0; y < H; y++) {
        const x = Math.floor(offset + y * 0.55);
        for (let t = 0; t < 14; t++) {
          setPx(rgb, x + t, y, accent[0], accent[1], accent[2]);
        }
      }
    }
  } else if (motif === 3) {
    fillRect(rgb, 0, Math.floor(H * 0.55), W, Math.floor(H * 0.45), [24, 68, 72]);
    fillCircle(rgb, Math.floor(W * 0.5), Math.floor(H * 0.32), 72, [200, 230, 215]);
  } else if (motif === 4) {
    fillCircle(rgb, Math.floor(W * 0.5), Math.floor(H * 0.42), 110, [201, 169, 110]);
    fillRect(rgb, 0, Math.floor(H * 0.78), W, Math.floor(H * 0.22), [48, 42, 38]);
  } else if (motif === 5) {
    fillRect(rgb, 0, Math.floor(H * 0.48), W, Math.floor(H * 0.52), [28, 72, 98]);
    fillRect(rgb, Math.floor(W * 0.08), Math.floor(H * 0.12), Math.floor(W * 0.35), Math.floor(H * 0.28), accent);
  } else if (motif === 6) {
    fillRect(rgb, Math.floor(W * 0.08), Math.floor(H * 0.18), Math.floor(W * 0.38), Math.floor(H * 0.32), [201, 169, 110]);
    fillRect(rgb, Math.floor(W * 0.54), Math.floor(H * 0.48), Math.floor(W * 0.38), Math.floor(H * 0.32), [140, 155, 170]);
  } else {
    fillRect(rgb, Math.floor(W * 0.1), Math.floor(H * 0.15), Math.floor(W * 0.8), Math.floor(H * 0.12), accent);
  }
}

function applyHeroMotif(rgb, motif, accent) {
  if (motif % 3 === 1) {
    for (let x = 0; x < W; x += 24) {
      for (let y = 0; y < H; y++) {
        const o = (y * W + x) * 3;
        rgb[o] = Math.min(255, rgb[o] + 18);
        rgb[o + 1] = Math.min(255, rgb[o + 1] + 14);
        rgb[o + 2] = Math.min(255, rgb[o + 2] + 10);
      }
    }
  } else if (motif % 3 === 2) {
    for (let y = 0; y < H; y += 18) {
      for (let x = 0; x < W; x++) {
        const o = (y * W + x) * 3;
        rgb[o] = Math.min(255, rgb[o] + 12);
        rgb[o + 1] = Math.min(255, rgb[o + 1] + 10);
      }
    }
  }
  if (motif >= 4 && motif <= 6) {
    fillCircle(rgb, Math.floor(W * (0.3 + (motif - 4) * 0.15)), Math.floor(H * 0.38), 40, accent);
  }
  const barY = Math.floor(H * 0.72);
  fillRect(rgb, Math.floor(W * 0.08), barY, Math.floor(W * 0.84), 8, accent);
}

function renderItem(spec) {
  const rgb = Buffer.alloc(W * H * 3);
  for (let y = 0; y < H; y++) {
    const t = y / (H - 1);
    const r = lerp(spec.top[0], spec.bottom[0], t);
    const g = lerp(spec.top[1], spec.bottom[1], t);
    const b = lerp(spec.top[2], spec.bottom[2], t);
    for (let x = 0; x < W; x++) {
      const o = (y * W + x) * 3;
      rgb[o] = r;
      rgb[o + 1] = g;
      rgb[o + 2] = b;
    }
  }
  const motif = spec.motif ?? 0;
  if (spec.kind === 'book') {
    applyBookMotif(rgb, motif, spec.accent);
  } else {
    applyHeroMotif(rgb, motif, spec.accent);
  }
  return rgb;
}

fs.mkdirSync(OUT, { recursive: true });
for (const item of ITEMS) {
  fs.writeFileSync(path.join(OUT, `${item.name}.png`), encodePngRgb(W, H, renderItem(item)));
}
console.log(`OK rendered ${ITEMS.length} media PNGs → ${OUT}`);
