/**
 * 节气食谱 · 批量生成差异化封面 PNG（替换 70B 1×1 占位色块）
 * 已有真实大图（>80KB）的文件不覆盖。
 */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(__dirname, '../app/entry/src/main/resources/base/media');

const SLUGS = [
  'lichun', 'yushui', 'jingzhe', 'chunfen', 'qingming', 'guyu', 'lixia', 'xiaoman',
  'mangzhong', 'xiazhi', 'xiaoshu', 'dashu', 'liqiu', 'chushu', 'bailu', 'qiufen',
  'hanlu', 'shuangjiang', 'lidong', 'xiaoxue', 'daxue', 'dongzhi', 'xiaohan', 'dahan',
];

/** 四季色板：暖橙 #E8833A · 墨绿 #3A7D44 · 米白 #F5F0E8 */
const SEASON = {
  spring: { top: [245, 240, 232], mid: [232, 200, 160], bot: [58, 125, 68], accent: [232, 131, 58] },
  summer: { top: [255, 248, 235], mid: [255, 210, 150], bot: [200, 120, 60], accent: [232, 131, 58] },
  autumn: { top: [245, 235, 220], mid: [210, 160, 100], bot: [140, 90, 50], accent: [200, 100, 40] },
  winter: { top: [240, 238, 235], mid: [180, 170, 160], bot: [80, 70, 65], accent: [58, 125, 68] },
};

function seasonForSlug(slug) {
  const spring = ['lichun', 'yushui', 'jingzhe', 'chunfen', 'qingming', 'guyu'];
  const summer = ['lixia', 'xiaoman', 'mangzhong', 'xiazhi', 'xiaoshu', 'dashu'];
  const autumn = ['liqiu', 'chushu', 'bailu', 'qiufen', 'hanlu', 'shuangjiang'];
  if (spring.includes(slug)) return SEASON.spring;
  if (summer.includes(slug)) return SEASON.summer;
  if (autumn.includes(slug)) return SEASON.autumn;
  return SEASON.winter;
}

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

function encodePng(w, h, rgba) {
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) {
    raw[y * (w * 4 + 1)] = 0;
    rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 6 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function hash(n) {
  let x = (n * 374761393 + 668265263) | 0;
  x = Math.imul(x ^ (x >>> 13), 1274126177);
  return ((x ^ (x >>> 16)) >>> 0) / 4294967296;
}

function hashStr(s) {
  let h = 2166136261;
  for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619);
  return (h >>> 0) / 4294967296;
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}

function mix(c0, c1, t) {
  return [
    Math.round(lerp(c0[0], c1[0], t)),
    Math.round(lerp(c0[1], c1[1], t)),
    Math.round(lerp(c0[2], c1[2], t)),
    255,
  ];
}

function noise2(x, y, seed) {
  const ix = Math.floor(x);
  const iy = Math.floor(y);
  const fx = x - ix;
  const fy = y - iy;
  const u = fx * fx * (3 - 2 * fx);
  const v = fy * fy * (3 - 2 * fy);
  const a = hash(ix * 374 + iy * 593 + seed);
  const b = hash((ix + 1) * 374 + iy * 593 + seed);
  const c = hash(ix * 374 + (iy + 1) * 593 + seed);
  const d = hash((ix + 1) * 374 + (iy + 1) * 593 + seed);
  return lerp(lerp(a, b, u), lerp(c, d, u), v);
}

function fbm(x, y, seed) {
  let v = 0;
  let a = 0.5;
  let f = 1;
  for (let i = 0; i < 4; i++) {
    v += a * noise2(x * f, y * f, seed + i * 17);
    a *= 0.5;
    f *= 2.1;
  }
  return v;
}

function setPx(buf, w, h, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= h) return;
  const i = (y * w + x) * 4;
  buf[i] = c[0];
  buf[i + 1] = c[1];
  buf[i + 2] = c[2];
  buf[i + 3] = 255;
}

function fillCircle(buf, w, h, cx, cy, r, c) {
  const r2 = r * r;
  for (let y = Math.floor(cy - r); y <= Math.ceil(cy + r); y++) {
    for (let x = Math.floor(cx - r); x <= Math.ceil(cx + r); x++) {
      const dx = x - cx;
      const dy = y - cy;
      if (dx * dx + dy * dy <= r2) setPx(buf, w, h, x, y, c);
    }
  }
}

function fillEllipse(buf, w, h, cx, cy, rx, ry, c) {
  for (let y = Math.floor(cy - ry); y <= Math.ceil(cy + ry); y++) {
    for (let x = Math.floor(cx - rx); x <= Math.ceil(cx + rx); x++) {
      const nx = (x - cx) / rx;
      const ny = (y - cy) / ry;
      if (nx * nx + ny * ny <= 1) setPx(buf, w, h, x, y, c);
    }
  }
}

/** 食养静物：渐变底 + 瓷盘 + 食材色块 + 蒸汽 */
function drawFoodStill(w, h, name, slug, variant) {
  const buf = Buffer.alloc(w * h * 4);
  const pal = seasonForSlug(slug);
  const seed = Math.floor(hashStr(name) * 100000) + variant * 13;

  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const ny = y / h;
      const nx = x / w;
      const n = fbm(nx * 4, ny * 3, seed) * 0.12;
      let col;
      if (ny < 0.55) {
        col = mix(pal.top, pal.mid, ny / 0.55 + n);
      } else {
        col = mix(pal.mid, pal.bot, (ny - 0.55) / 0.45 + n * 0.5);
      }
      const g = (hash(x * 17 + y * 31 + seed) - 0.5) * 10;
      setPx(buf, w, h, x, y, [
        Math.max(0, Math.min(255, col[0] + g)),
        Math.max(0, Math.min(255, col[1] + g)),
        Math.max(0, Math.min(255, col[2] + g)),
        255,
      ]);
    }
  }

  const cx = w * (0.48 + hash(seed + 1) * 0.08);
  const cy = h * 0.62;
  const plateR = Math.min(w, h) * 0.28;
  fillCircle(buf, w, h, cx, cy, plateR + 8, [240, 235, 225]);
  fillCircle(buf, w, h, cx, cy, plateR, [250, 246, 240]);

  const foodColors = [
    pal.accent,
    pal.bot,
    [120, 160, 80],
    [180, 100, 60],
    [200, 140, 90],
  ];
  const fc = foodColors[(seed + variant) % foodColors.length];
  const fc2 = foodColors[(seed + variant + 2) % foodColors.length];
  fillEllipse(buf, w, h, cx - plateR * 0.2, cy - plateR * 0.1, plateR * 0.35, plateR * 0.22, fc);
  fillEllipse(buf, w, h, cx + plateR * 0.15, cy + plateR * 0.05, plateR * 0.28, plateR * 0.18, fc2);
  fillCircle(buf, w, h, cx, cy - plateR * 0.05, plateR * 0.12, mix(fc, fc2, 0.5));

  for (let s = 0; s < 5; s++) {
    const sx = cx + (hash(seed + s * 7) - 0.5) * plateR * 0.6;
    const sy = cy - plateR - 10 - s * 18;
    fillEllipse(buf, w, h, sx, sy, 10 + s, 16 + s * 3, [255, 255, 255]);
  }

  const vignette = (nx, ny) => {
    const dx = nx - 0.5;
    const dy = ny - 0.5;
    return Math.min(1, (dx * dx + dy * dy) * 1.2);
  };
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const v = vignette(x / w, y / h);
      if (v > 0.15) {
        const i = (y * w + x) * 4;
        const d = v * 0.35;
        buf[i] = Math.round(buf[i] * (1 - d));
        buf[i + 1] = Math.round(buf[i + 1] * (1 - d));
        buf[i + 2] = Math.round(buf[i + 2] * (1 - d));
      }
    }
  }
  return buf;
}

/** 节气封面：大留白 + 季节渐变 + 圆形节气符号 */
function drawTermCover(w, h, slug) {
  const buf = Buffer.alloc(w * h * 4);
  const pal = seasonForSlug(slug);
  const seed = Math.floor(hashStr(slug) * 100000);

  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const ny = y / h;
      const n = fbm(x / w * 3, ny * 2, seed) * 0.1;
      const col = mix(pal.top, mix(pal.mid, pal.bot, ny), ny + n);
      setPx(buf, w, h, x, y, col);
    }
  }
  const cx = w * 0.5;
  const cy = h * 0.55;
  const r = Math.min(w, h) * 0.32;
  fillCircle(buf, w, h, cx, cy, r, mix(pal.accent, pal.bot, 0.3));
  fillCircle(buf, w, h, cx, cy, r * 0.72, mix(pal.top, pal.mid, 0.4));
  for (let i = 0; i < 8; i++) {
    const ang = (i / 8) * Math.PI * 2 + seed * 0.01;
    const px = cx + Math.cos(ang) * r * 0.9;
    const py = cy + Math.sin(ang) * r * 0.9;
    fillCircle(buf, w, h, px, py, r * 0.06, pal.accent);
  }
  return buf;
}

/** 贴士横图：柔和编辑风 */
function drawTipBanner(w, h, slug) {
  const buf = Buffer.alloc(w * h * 4);
  const pal = seasonForSlug(slug);
  const seed = Math.floor(hashStr(`tip-${slug}`) * 100000);

  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const nx = x / w;
      const ny = y / h;
      const n = fbm(nx * 5, ny * 4, seed) * 0.08;
      const col = mix(pal.top, mix(pal.mid, pal.accent, nx * 0.4), ny * 0.7 + n);
      setPx(buf, w, h, x, y, col);
    }
  }
  fillEllipse(buf, w, h, w * 0.75, h * 0.5, w * 0.22, h * 0.35, [255, 252, 245]);
  fillEllipse(buf, w, h, w * 0.75, h * 0.52, w * 0.18, h * 0.28, mix(pal.accent, pal.bot, 0.5));
  return buf;
}

function shouldSkip(filePath) {
  if (!fs.existsSync(filePath)) return false;
  const size = fs.statSync(filePath).size;
  return size > 80000;
}

function writeIfNeeded(name, w, h, drawFn) {
  const filePath = path.join(OUT, `${name}.png`);
  if (shouldSkip(filePath)) {
    console.log('skip (real image):', name);
    return;
  }
  const rgba = drawFn();
  const png = encodePng(w, h, rgba);
  fs.writeFileSync(filePath, png);
  console.log('wrote', name, png.length);
}

fs.mkdirSync(OUT, { recursive: true });

for (const slug of SLUGS) {
  writeIfNeeded(`term_${slug}`, 720, 720, () => drawTermCover(720, 720, slug));
  writeIfNeeded(`tip_${slug}`, 840, 520, () => drawTipBanner(840, 520, slug));
  writeIfNeeded(`recipe_${slug}_1`, 800, 600, () => drawFoodStill(800, 600, `recipe_${slug}_1`, slug, 1));
  writeIfNeeded(`recipe_${slug}_2`, 800, 600, () => drawFoodStill(800, 600, `recipe_${slug}_2`, slug, 2));
}

console.log('done — solar media regenerated');
