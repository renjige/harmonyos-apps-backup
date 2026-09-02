#!/usr/bin/env node
/** Derive unique level cover PNGs from category/level masters via crop offsets */
import fs from 'fs';
import path from 'path';
import zlib from 'zlib';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const media = path.join(__dirname, '../../app/entry/src/main/resources/base/media');
const assets = path.join(process.env.USERPROFILE || '', '.cursor/projects/e-huawei001-master/assets');

function decodePng(buf) {
  const w = buf.readUInt32BE(16);
  const h = buf.readUInt32BE(20);
  const compressed = buf.slice(33, buf.length - 12);
  const raw = zlib.inflateSync(compressed);
  const rgba = Buffer.alloc(w * h * 4);
  for (let y = 0; y < h; y++) {
    const row = raw.slice(y * (w * 4 + 1) + 1, y * (w * 4 + 1) + 1 + w * 4);
    row.copy(rgba, y * w * 4);
  }
  return { w, h, rgba };
}

function encodePng(w, h, rgba) {
  const stride = w * 4 + 1;
  const raw = Buffer.alloc(stride * h);
  for (let y = 0; y < h; y++) {
    raw[y * stride] = 0;
    rgba.copy(raw, y * stride + 1, y * w * 4, (y + 1) * w * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const crc32 = (b) => zlib.crc32(b) >>> 0;
  const chunk = (type, data) => {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length);
    const tb = Buffer.from(type);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(Buffer.concat([tb, data])));
    return Buffer.concat([len, tb, data, crc]);
  };
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

function cropSquare(srcPath, outPath, offsetX, offsetY, size) {
  if (!fs.existsSync(srcPath)) return false;
  const { w, h, rgba } = decodePng(fs.readFileSync(srcPath));
  const side = Math.min(size, w, h);
  const ox = Math.min(Math.max(0, offsetX), w - side);
  const oy = Math.min(Math.max(0, offsetY), h - side);
  const out = Buffer.alloc(side * side * 4);
  for (let y = 0; y < side; y++) {
    for (let x = 0; x < side; x++) {
      const si = ((oy + y) * w + (ox + x)) * 4;
      const di = (y * side + x) * 4;
      out[di] = rgba[si];
      out[di + 1] = rgba[si + 1];
      out[di + 2] = rgba[si + 2];
      out[di + 3] = rgba[si + 3];
    }
  }
  fs.writeFileSync(outPath, encodePng(side, side, out));
  return true;
}

const bases = {
  workplace: path.join(media, 'level_workplace_1.png'),
  life: path.join(media, 'level_life_1.png'),
  creative: path.join(media, 'level_creative_1.png'),
  thinking: path.join(media, 'level_thinking_1.png'),
};

for (const cat of ['workplace', 'life', 'creative', 'thinking']) {
  const base = bases[cat];
  for (let i = 1; i <= 5; i++) {
    const name = `level_${cat}_${i}.png`;
    const out = path.join(media, name);
    if (fs.existsSync(out)) continue;
    const src = i === 1 && cat === 'workplace' ? path.join(media, 'level_workplace_1.png') :
      i === 2 && cat === 'workplace' ? path.join(media, 'level_workplace_2.png') :
        base;
    if (!fs.existsSync(src) && fs.existsSync(path.join(assets, name))) {
      fs.copyFileSync(path.join(assets, name), out);
      continue;
    }
    cropSquare(src, out, 20 * i, 15 * i, 512 - i * 8);
  }
}
console.log('level covers derived');
