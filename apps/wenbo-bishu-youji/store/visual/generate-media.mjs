/**
 * Unique landscape stills for 避暑游记 (no Python). Atmospheric gradients + silhouettes.
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const ROOT = path.resolve(__dirname, '../..')
const OUT = path.join(ROOT, 'app/entry/src/main/resources/base/media')
const VIS = path.join(ROOT, 'store/visual')

function crc32(buf) {
  let c = 0xffffffff
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i]
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0)
  }
  return (c ^ 0xffffffff) >>> 0
}

function chunk(type, data) {
  const len = Buffer.alloc(4)
  len.writeUInt32BE(data.length, 0)
  const t = Buffer.from(type, 'ascii')
  const crc = Buffer.alloc(4)
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0)
  return Buffer.concat([len, t, data, crc])
}

function encodePng(w, h, rgba) {
  const raw = Buffer.alloc((w * 4 + 1) * h)
  for (let y = 0; y < h; y++) {
    raw[y * (w * 4 + 1)] = 0
    rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4)
  }
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(w, 0)
  ihdr.writeUInt32BE(h, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 6 })),
    chunk('IEND', Buffer.alloc(0)),
  ])
}

function lerp(a, b, t) {
  return a + (b - a) * t
}

function mix(c0, c1, t) {
  return [
    Math.round(lerp(c0[0], c1[0], t)),
    Math.round(lerp(c0[1], c1[1], t)),
    Math.round(lerp(c0[2], c1[2], t)),
    255,
  ]
}

function hash(n) {
  let x = (n * 374761393 + 668265263) | 0
  x = Math.imul(x ^ (x >>> 13), 1274126177)
  return ((x ^ (x >>> 16)) >>> 0) / 4294967296
}

function noise2(x, y, seed) {
  const ix = Math.floor(x)
  const iy = Math.floor(y)
  const fx = x - ix
  const fy = y - iy
  const u = fx * fx * (3 - 2 * fx)
  const v = fy * fy * (3 - 2 * fy)
  const a = hash(ix * 374 + iy * 593 + seed)
  const b = hash((ix + 1) * 374 + iy * 593 + seed)
  const c = hash(ix * 374 + (iy + 1) * 593 + seed)
  const d = hash((ix + 1) * 374 + (iy + 1) * 593 + seed)
  return lerp(lerp(a, b, u), lerp(c, d, u), v)
}

function fbm(x, y, seed) {
  let v = 0
  let a = 0.5
  let f = 1
  for (let i = 0; i < 5; i++) {
    v += a * noise2(x * f, y * f, seed + i * 17)
    a *= 0.5
    f *= 2.03
  }
  return v
}

function setPx(buf, w, h, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= h) return
  const i = (y * w + x) * 4
  buf[i] = c[0]
  buf[i + 1] = c[1]
  buf[i + 2] = c[2]
  buf[i + 3] = 255
}

function drawLandscape(w, h, spec) {
  const buf = Buffer.alloc(w * h * 4)
  const seed = spec.seed
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const ny = y / h
      const nx = x / w
      const skyT = ny + (fbm(nx * 3, ny * 2, seed) - 0.5) * 0.08
      let col = mix(spec.skyTop, spec.skyBot, Math.min(1, Math.max(0, skyT)))
      if (spec.kind === 'sea' && ny > 0.52) {
        const wave = Math.sin(nx * 28 + seed) * 0.02 + fbm(nx * 8, ny * 6, seed + 9) * 0.06
        col = mix(spec.water, spec.waterDark, Math.min(1, (ny - 0.52) * 2 + wave))
      }
      if (spec.kind === 'forest' && ny > 0.38) {
        const canopy = fbm(nx * 10, ny * 7, seed + 3)
        if (canopy > 0.42) col = mix(spec.far, spec.near, (canopy - 0.42) * 1.6)
      }
      if (spec.kind === 'mountain' || spec.kind === 'plateau') {
        const ridge = 0.58 + Math.sin(nx * spec.freq + spec.phase) * spec.amp + (fbm(nx * 4, 0.2, seed) - 0.5) * 0.12
        if (ny > ridge) {
          const d = (ny - ridge) / (1 - ridge)
          col = mix(spec.far, spec.near, Math.min(1, d + fbm(nx * 6, ny * 4, seed + 5) * 0.2))
        }
      }
      if (spec.kind === 'plateau' && ny > 0.62) {
        col = mix(spec.ground, spec.near, fbm(nx * 5, ny * 3, seed + 11))
      }
      const g = (hash(x * 13 + y * 97 + seed) - 0.5) * spec.grain
      col = [
        Math.max(0, Math.min(255, col[0] + g)),
        Math.max(0, Math.min(255, col[1] + g)),
        Math.max(0, Math.min(255, col[2] + g)),
        255,
      ]
      setPx(buf, w, h, x, y, col)
    }
  }
  if (spec.kind === 'sea') {
    const sunX = Math.round(w * spec.sunX)
    const sunY = Math.round(h * 0.28)
    const r = Math.round(h * 0.055)
    for (let y = sunY - r; y <= sunY + r; y++) {
      for (let x = sunX - r; x <= sunX + r; x++) {
        const dx = x - sunX
        const dy = y - sunY
        if (dx * dx + dy * dy <= r * r) setPx(buf, w, h, x, y, spec.sun)
      }
    }
  }
  return buf
}

const palettes = {
  mountain: {
    kind: 'mountain',
    skyTop: [120, 168, 210],
    skyBot: [232, 244, 253],
    far: [90, 130, 150],
    near: [45, 78, 88],
    freq: 6.2,
    amp: 0.12,
    phase: 0.4,
    grain: 7,
  },
  sea: {
    kind: 'sea',
    skyTop: [90, 150, 200],
    skyBot: [200, 226, 240],
    water: [70, 140, 180],
    waterDark: [28, 78, 110],
    sun: [245, 214, 160],
    sunX: 0.72,
    grain: 6,
  },
  plateau: {
    kind: 'plateau',
    skyTop: [150, 190, 220],
    skyBot: [240, 236, 220],
    far: [160, 140, 110],
    near: [110, 92, 70],
    ground: [186, 168, 128],
    freq: 3.4,
    amp: 0.06,
    phase: 1.1,
    grain: 8,
  },
  forest: {
    kind: 'forest',
    skyTop: [170, 210, 200],
    skyBot: [220, 236, 230],
    far: [46, 92, 70],
    near: [22, 58, 42],
    grain: 9,
  },
}

const dests = [
  ['dest_lushan', 'mountain', 11],
  ['dest_mogan', 'forest', 21],
  ['dest_jigong', 'mountain', 31],
  ['dest_tianmu', 'forest', 41],
  ['dest_wuyi', 'mountain', 51],
  ['dest_laoshan', 'sea', 61],
  ['dest_dalian', 'sea', 71],
  ['dest_weihai', 'sea', 81],
  ['dest_beidaihe', 'sea', 91],
  ['dest_dongji', 'sea', 101],
  ['dest_lijiang', 'plateau', 111],
  ['dest_shangri', 'plateau', 121],
  ['dest_xining', 'plateau', 131],
  ['dest_guiyang', 'forest', 141],
  ['dest_bashang', 'plateau', 151],
  ['dest_shennong', 'forest', 161],
  ['dest_changbai', 'mountain', 171],
  ['dest_aershan', 'forest', 181],
  ['dest_saihanba', 'forest', 191],
  ['dest_wuling', 'forest', 201],
]

const guides = [
  ['guide_temp', 'mountain', 301],
  ['guide_coast', 'sea', 311],
  ['guide_plateau', 'plateau', 321],
  ['guide_forest', 'forest', 331],
  ['guide_weekend', 'mountain', 341],
  ['guide_family', 'sea', 351],
  ['feat_lushan', 'mountain', 361],
  ['feat_mogan', 'forest', 371],
  ['feat_dalian', 'sea', 381],
  ['feat_xining', 'plateau', 391],
  ['feat_shennong', 'forest', 401],
  ['feat_wuling', 'forest', 411],
]

fs.mkdirSync(OUT, { recursive: true })
fs.mkdirSync(VIS, { recursive: true })

function write(name, kind, seed, w, h) {
  const spec = { ...palettes[kind], seed }
  spec.phase = (spec.phase ?? 0) + seed * 0.017
  spec.freq = (spec.freq ?? 5) + (seed % 7) * 0.11
  spec.amp = (spec.amp ?? 0.1) + (seed % 5) * 0.008
  spec.sunX = 0.35 + (seed % 9) * 0.05
  const buf = drawLandscape(w, h, spec)
  const png = encodePng(w, h, buf)
  fs.writeFileSync(path.join(OUT, `${name}.png`), png)
  fs.writeFileSync(path.join(VIS, `${name}.png`), png)
  console.log(name, png.length)
}

write('hero_cool', 'mountain', 7, 960, 1280)
write('texture_mist', 'sea', 88, 800, 480)
for (const [n, k, s] of dests) write(n, k, s, 720, 900)
for (const [n, k, s] of guides) write(n, k, s, 960, 640)

console.log('visual assets done')
