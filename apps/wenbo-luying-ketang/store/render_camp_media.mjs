/**
 * 露营课堂 · 内容影像（户外风格 procedural，一 key 一图）
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const OUT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../app/entry/src/main/resources/base/media')
const W = 800
const H = 600

const ORANGE = [251, 146, 60]
const NIGHT = [15, 60, 35]

const ITEMS = [
  { name: 'hero_camp_night', top: [12, 45, 28], bottom: [4, 18, 12], kind: 'hero', motif: 0 },
  { name: 'banner_pack', top: [34, 72, 48], bottom: [18, 42, 28], kind: 'hero', motif: 1 },
  { name: 'guide_tent', top: [38, 88, 52], bottom: [22, 48, 32], kind: 'guide', motif: 1 },
  { name: 'guide_rain', top: [48, 62, 78], bottom: [28, 38, 52], kind: 'guide', motif: 2 },
  { name: 'guide_cook', top: [55, 42, 28], bottom: [28, 22, 18], kind: 'guide', motif: 3 },
  { name: 'guide_stars', top: [8, 22, 42], bottom: [12, 28, 38], kind: 'guide', motif: 4 },
  { name: 'guide_kids', top: [72, 92, 58], bottom: [42, 68, 48], kind: 'guide', motif: 5 },
  { name: 'guide_altitude', top: [58, 72, 88], bottom: [32, 48, 62], kind: 'guide', motif: 6 },
  { name: 'tpl_newbie', top: [42, 78, 55], bottom: [24, 44, 30], kind: 'tpl', motif: 1 },
  { name: 'tpl_ultralight', top: [35, 65, 78], bottom: [18, 38, 48], kind: 'tpl', motif: 2 },
  { name: 'tpl_family', top: [68, 82, 58], bottom: [38, 58, 42], kind: 'tpl', motif: 3 },
]

function crc32(buf) {
  let c = 0xffffffff
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i]
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1))
  }
  return (c ^ 0xffffffff) >>> 0
}

function chunk(type, data) {
  const len = Buffer.alloc(4)
  len.writeUInt32BE(data.length, 0)
  const typeBuf = Buffer.from(type, 'ascii')
  const crcBuf = Buffer.alloc(4)
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0)
  return Buffer.concat([len, typeBuf, data, crcBuf])
}

function encodePngRgb(width, height, rgb) {
  const raw = Buffer.alloc((width * 3 + 1) * height)
  for (let y = 0; y < height; y++) {
    const dest = y * (width * 3 + 1)
    raw[dest] = 0
    rgb.copy(raw, dest + 1, y * width * 3, (y + 1) * width * 3)
  }
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 2
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))])
}

function lerp(a, b, t) {
  return Math.round(a + (b - a) * t)
}

function setPx(rgb, x, y, r, g, b) {
  if (x < 0 || y < 0 || x >= W || y >= H) return
  const o = (y * W + x) * 3
  rgb[o] = r
  rgb[o + 1] = g
  rgb[o + 2] = b
}

function fillRect(rgb, x0, y0, w, h, color) {
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      setPx(rgb, x, y, color[0], color[1], color[2])
    }
  }
}

function fillCircle(rgb, cx, cy, radius, color) {
  for (let dy = -radius; dy <= radius; dy++) {
    for (let dx = -radius; dx <= radius; dx++) {
      if (dx * dx + dy * dy <= radius * radius) {
        setPx(rgb, cx + dx, cy + dy, color[0], color[1], color[2])
      }
    }
  }
}

function drawTent(rgb, cx, baseY, scale, color) {
  const h = Math.floor(120 * scale)
  const w = Math.floor(140 * scale)
  for (let y = baseY - h; y <= baseY; y++) {
    const t = (baseY - y) / h
    const half = Math.floor(w * t * 0.5)
    for (let x = cx - half; x <= cx + half; x++) {
      setPx(rgb, x, y, color[0], color[1], color[2])
    }
  }
  fillRect(rgb, cx - Math.floor(w * 0.12), baseY - Math.floor(h * 0.45), Math.floor(w * 0.24), Math.floor(h * 0.45), NIGHT)
}

function applyMotif(rgb, spec) {
  const m = spec.motif
  if (spec.kind === 'hero' && m === 0) {
    for (let i = 0; i < 80; i++) {
      fillCircle(rgb, (i * 97) % W, (i * 53) % Math.floor(H * 0.45), 1 + (i % 2), [240, 245, 230])
    }
    drawTent(rgb, Math.floor(W * 0.55), Math.floor(H * 0.72), 1.1, [230, 235, 220])
    fillCircle(rgb, Math.floor(W * 0.18), Math.floor(H * 0.22), 36, ORANGE)
  } else if (spec.kind === 'hero' && m === 1) {
    fillRect(rgb, Math.floor(W * 0.08), Math.floor(H * 0.55), Math.floor(W * 0.84), Math.floor(H * 0.32), [48, 38, 32])
    for (let i = 0; i < 6; i++) {
      fillRect(rgb, Math.floor(W * (0.12 + i * 0.13)), Math.floor(H * 0.42), 48, 64, [72, 58, 48])
    }
  } else if (m === 1) {
    drawTent(rgb, Math.floor(W * 0.5), Math.floor(H * 0.78), 0.95, [245, 240, 232])
  } else if (m === 2) {
    for (let x = 0; x < W; x += 8) {
      for (let y = 0; y < H * 0.55; y++) {
        if ((x + y) % 16 === 0) setPx(rgb, x, y, 180, 200, 220)
      }
    }
    drawTent(rgb, Math.floor(W * 0.42), Math.floor(H * 0.7), 0.8, [220, 225, 230])
  } else if (m === 3) {
    fillCircle(rgb, Math.floor(W * 0.35), Math.floor(H * 0.62), 28, ORANGE)
    fillRect(rgb, Math.floor(W * 0.55), Math.floor(H * 0.58), 90, 12, [60, 50, 45])
  } else if (m === 4) {
    for (let i = 0; i < 120; i++) {
      fillCircle(rgb, (i * 67) % W, (i * 41) % Math.floor(H * 0.5), 1, [250, 250, 240])
    }
    drawTent(rgb, Math.floor(W * 0.62), Math.floor(H * 0.75), 0.85, [200, 210, 195])
  } else if (m === 5) {
    drawTent(rgb, Math.floor(W * 0.38), Math.floor(H * 0.72), 1.0, [248, 242, 230])
    drawTent(rgb, Math.floor(W * 0.62), Math.floor(H * 0.76), 0.75, [235, 228, 215])
  } else if (m === 6) {
    fillRect(rgb, 0, Math.floor(H * 0.35), W, Math.floor(H * 0.65), [180, 195, 210])
    for (let x = 0; x < W; x++) {
      const peak = Math.floor(H * 0.35 - Math.abs(x - W * 0.5) * 0.08)
      for (let y = Math.max(0, peak); y < H * 0.35; y++) {
        setPx(rgb, x, y, 220, 230, 240)
      }
    }
    drawTent(rgb, Math.floor(W * 0.5), Math.floor(H * 0.82), 0.7, [240, 245, 250])
  }
}

function renderItem(spec) {
  const rgb = Buffer.alloc(W * H * 3)
  for (let y = 0; y < H; y++) {
    const t = y / (H - 1)
    const r = lerp(spec.top[0], spec.bottom[0], t)
    const g = lerp(spec.top[1], spec.bottom[1], t)
    const b = lerp(spec.top[2], spec.bottom[2], t)
    for (let x = 0; x < W; x++) {
      const o = (y * W + x) * 3
      rgb[o] = r
      rgb[o + 1] = g
      rgb[o + 2] = b
    }
  }
  applyMotif(rgb, spec)
  return rgb
}

fs.mkdirSync(OUT, { recursive: true })
for (const item of ITEMS) {
  fs.writeFileSync(path.join(OUT, `${item.name}.png`), encodePngRgb(W, H, renderItem(item)))
}
console.log(`OK rendered ${ITEMS.length} camp media PNGs → ${OUT}`)
