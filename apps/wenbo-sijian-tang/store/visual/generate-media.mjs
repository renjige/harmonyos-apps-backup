/**
 * 思见堂 — 东方美学影像（纯 Node PNG，无 Python）
 * 墨韵黑 #1A1A2E · 琥珀金 #C9A84C · 象牙白 #F5F0E8 · 青瓷绿 #7BA99C
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

function drawScene(w, h, spec) {
  const buf = Buffer.alloc(w * h * 4)
  const seed = spec.seed
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const ny = y / h
      const nx = x / w
      let col
      if (spec.kind === 'avatar') {
        col = mix(spec.bgTop, spec.bgBot, ny)
      } else {
        const skyT = ny + (fbm(nx * 2.5, ny * 2, seed) - 0.5) * 0.06
        col = mix(spec.skyTop, spec.skyBot, Math.min(1, Math.max(0, skyT)))
      }

      if (spec.kind === 'ink') {
        const wash = fbm(nx * 5 + seed * 0.01, ny * 4, seed)
        if (ny > 0.35 + wash * 0.15) {
          col = mix(spec.inkFar, spec.inkNear, (ny - 0.35) * 1.4 + wash * 0.3)
        }
        if (wash > 0.72 && ny > 0.5) {
          col = mix(col, spec.accent, (wash - 0.72) * 1.8)
        }
      }

      if (spec.kind === 'study') {
        const desk = 0.68 + Math.sin(nx * 2) * 0.02
        if (ny > desk) {
          col = mix(spec.desk, spec.deskDark, (ny - desk) * 2.5)
        }
        const beam = Math.exp(-Math.pow((nx - spec.lightX) * 3.2, 2)) * Math.exp(-Math.pow((ny - 0.35) * 4, 2))
        col = mix(col, spec.light, beam * spec.lightStr)
        if (ny > desk && ny < desk + 0.08 && nx > 0.15 && nx < 0.85) {
          col = mix(col, spec.paper, 0.85)
        }
      }

      if (spec.kind === 'window') {
        const beam = Math.exp(-Math.pow((nx - spec.lightX) * 2.8, 2)) * (1 - ny * 0.3)
        col = mix(col, spec.light, beam * spec.lightStr)
        const frame = Math.abs(nx - 0.5) < 0.02 || Math.abs(ny - 0.42) < 0.015
        if (frame && ny < 0.75) col = mix(col, spec.frame, 0.7)
      }

      if (spec.kind === 'tea') {
        const table = 0.72
        if (ny > table) col = mix(spec.table, spec.tableDark, (ny - table) * 3)
        const steam = fbm(nx * 12, ny * 8 - seed * 0.02, seed) * Math.exp(-(ny - 0.55) * 3)
        if (steam > 0.55 && ny > 0.45 && ny < 0.72) {
          col = mix(col, spec.steam, (steam - 0.55) * 0.6)
        }
        const cupX = Math.round(w * spec.cupX)
        const cupY = Math.round(h * 0.68)
        const cr = Math.round(w * 0.06)
        const dx = x - cupX
        const dy = y - cupY
        if (dx * dx + dy * dy < cr * cr) col = mix(col, spec.celadon, 0.9)
      }

      if (spec.kind === 'library') {
        const shelf = Math.floor(ny * 8) / 8
        if (ny > 0.25) {
          const band = (shelf % 2) * 0.08
          col = mix(spec.shelf, spec.book, band + fbm(nx * 20, ny * 15, seed) * 0.12)
        }
        const glow = Math.exp(-Math.pow((nx - 0.3) * 2, 2)) * (1 - ny)
        col = mix(col, spec.warm, glow * 0.35)
      }

      if (spec.kind === 'circle') {
        const card = fbm(nx * 8, ny * 6, seed)
        if (card > 0.5 && ny > 0.2 && ny < 0.85) {
          col = mix(spec.cardBg, spec.cardHi, (card - 0.5) * 1.2)
        }
        const glow = Math.exp(-Math.pow((nx - 0.5) * 2.5, 2) - Math.pow((ny - 0.4) * 3, 2))
        col = mix(col, spec.accent, glow * 0.25)
      }

      if (spec.kind === 'avatar') {
        const cx = w * 0.5
        const cy = h * 0.42
        const r = w * 0.32
        const d = Math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
        if (d < r) {
          col = mix(spec.skin, spec.shadow, d / r)
        } else {
          col = mix(spec.bgTop, spec.bgBot, ny)
        }
        if (d < r * 0.55 && y < cy) col = mix(col, spec.hair, 0.85)
      }

      const g = (hash(x * 13 + y * 97 + seed) - 0.5) * (spec.grain ?? 6)
      col = [
        Math.max(0, Math.min(255, col[0] + g)),
        Math.max(0, Math.min(255, col[1] + g)),
        Math.max(0, Math.min(255, col[2] + g)),
        255,
      ]
      setPx(buf, w, h, x, y, col)
    }
  }
  return buf
}

const palettes = {
  ink: {
    kind: 'ink',
    skyTop: [245, 240, 232],
    skyBot: [210, 200, 185],
    inkFar: [60, 58, 72],
    inkNear: [26, 26, 46],
    accent: [201, 168, 76],
    grain: 8,
  },
  study: {
    kind: 'study',
    skyTop: [240, 235, 225],
    skyBot: [220, 210, 195],
    desk: [180, 160, 130],
    deskDark: [120, 100, 80],
    paper: [250, 246, 238],
    light: [255, 248, 230],
    lightX: 0.72,
    lightStr: 0.55,
    grain: 7,
  },
  window: {
    kind: 'window',
    skyTop: [230, 238, 235],
    skyBot: [200, 215, 210],
    light: [255, 252, 245],
    frame: [60, 55, 50],
    lightX: 0.62,
    lightStr: 0.65,
    grain: 6,
  },
  tea: {
    kind: 'tea',
    skyTop: [235, 232, 220],
    skyBot: [210, 205, 190],
    table: [160, 140, 115],
    tableDark: [100, 85, 70],
    celadon: [123, 169, 156],
    steam: [245, 242, 235],
    cupX: 0.45,
    grain: 7,
  },
  library: {
    kind: 'library',
    skyTop: [200, 195, 185],
    skyBot: [140, 130, 120],
    shelf: [90, 75, 65],
    book: [160, 120, 90],
    warm: [255, 230, 200],
    grain: 9,
  },
  circle: {
    kind: 'circle',
    skyTop: [245, 240, 232],
    skyBot: [230, 225, 215],
    cardBg: [235, 230, 220],
    cardHi: [245, 240, 232],
    accent: [201, 168, 76],
    grain: 5,
  },
}

const avatarSpecs = [
  { hair: [45, 40, 55], skin: [210, 185, 165], shadow: [160, 130, 110], bgTop: [240, 235, 228], bgBot: [200, 195, 185] },
  { hair: [30, 35, 50], skin: [195, 170, 150], shadow: [145, 120, 100], bgTop: [235, 238, 240], bgBot: [190, 200, 205] },
  { hair: [55, 45, 40], skin: [220, 195, 175], shadow: [170, 145, 125], bgTop: [245, 240, 232], bgBot: [210, 200, 190] },
  { hair: [35, 40, 48], skin: [200, 175, 155], shadow: [150, 125, 105], bgTop: [228, 232, 235], bgBot: [185, 190, 195] },
  { hair: [50, 42, 38], skin: [215, 190, 170], shadow: [165, 140, 120], bgTop: [242, 238, 230], bgBot: [205, 198, 188] },
]

const assets = [
  ['hero_today', 'window', 7, 960, 1280],
  ['cover_wisdom_ink', 'ink', 11, 960, 720],
  ['cover_wisdom', 'ink', 13, 960, 720],
  ['cover_reading', 'study', 17, 960, 640],
  ['cover_read_wang', 'library', 21, 960, 640],
  ['cover_read_lao', 'tea', 25, 960, 640],
  ['cover_read_calm', 'window', 29, 960, 640],
  ['cover_read_classic', 'library', 33, 960, 640],
  ['cover_read_heart', 'study', 37, 960, 640],
  ['cover_read_inspire', 'ink', 41, 960, 640],
  ['cover_topic_daily', 'tea', 45, 960, 640],
  ['cover_circle', 'circle', 49, 960, 640],
  ['cover_circle_1', 'study', 53, 720, 900],
  ['cover_circle_2', 'ink', 57, 720, 900],
  ['cover_circle_3', 'window', 61, 720, 900],
  ['cover_circle_4', 'tea', 65, 720, 900],
  ['cover_circle_5', 'library', 69, 720, 900],
  ['cover_circle_6', 'circle', 73, 720, 900],
  ['cover_circle_7', 'study', 77, 720, 900],
  ['cover_circle_8', 'ink', 81, 720, 900],
  ['cover_tag_wisdom', 'ink', 85, 640, 640],
]

fs.mkdirSync(OUT, { recursive: true })
fs.mkdirSync(VIS, { recursive: true })

function write(name, kind, seed, w, h, extra = {}) {
  const spec = { ...palettes[kind], seed, ...extra }
  if (kind === 'study' || kind === 'window') {
    spec.lightX = 0.35 + (seed % 11) * 0.05
  }
  if (kind === 'tea') spec.cupX = 0.3 + (seed % 7) * 0.06
  const buf = drawScene(w, h, spec)
  const png = encodePng(w, h, buf)
  fs.writeFileSync(path.join(OUT, `${name}.png`), png)
  fs.writeFileSync(path.join(VIS, `${name}.png`), png)
  console.log(name, png.length)
}

for (const [n, k, s, w, h] of assets) write(n, k, s, w, h)

for (let i = 0; i < 5; i++) {
  const spec = { kind: 'avatar', seed: 100 + i * 13, grain: 4, ...avatarSpecs[i] }
  const size = 512
  const buf = drawScene(size, size, spec)
  const png = encodePng(size, size, buf)
  const name = `avatar_friend_${i + 1}`
  fs.writeFileSync(path.join(OUT, `${name}.png`), png)
  fs.writeFileSync(path.join(VIS, `${name}.png`), png)
  console.log(name, png.length)
}

// App icon — 方形墨韵+琥珀光点
function writeAppIcon() {
  const size = 1024
  const buf = Buffer.alloc(size * size * 4)
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const nx = x / size
      const ny = y / size
      let col = mix([26, 26, 46], [45, 42, 58], ny * 0.6 + fbm(nx * 4, ny * 4, 999) * 0.2)
      const win = nx > 0.28 && nx < 0.72 && ny > 0.22 && ny < 0.72
      if (win) {
        const inner = mix([240, 235, 225], [255, 248, 235], fbm(nx * 8, ny * 6, 1001))
        col = mix(col, inner, 0.75)
      }
      const gold = Math.exp(-((nx - 0.5) ** 2 + (ny - 0.38) ** 2) * 18)
      col = mix(col, [201, 168, 76], gold * 0.85)
      const g = (hash(x * 7 + y * 11) - 0.5) * 5
      col = [
        Math.max(0, Math.min(255, col[0] + g)),
        Math.max(0, Math.min(255, col[1] + g)),
        Math.max(0, Math.min(255, col[2] + g)),
        255,
      ]
      setPx(buf, size, size, x, y, col)
    }
  }
  const png = encodePng(size, size, buf)
  const targets = [
    path.join(ROOT, 'app/AppScope/resources/base/media/app_icon.png'),
    path.join(OUT, 'icon.png'),
    path.join(OUT, 'startIcon.png'),
    path.join(OUT, 'app_icon.png'),
    path.join(ROOT, 'store/logo/preview-1024.png'),
    path.join(ROOT, 'store/logo/foreground.png'),
    path.join(ROOT, 'store/logo/background.png'),
  ]
  for (const dest of targets) {
    fs.mkdirSync(path.dirname(dest), { recursive: true })
    fs.writeFileSync(dest, png)
  }
  console.log('app_icon', png.length)
}

writeAppIcon()
console.log('思见堂 visual assets done')
