/**
 * 夏日漫游 logo — 薄荷绿渐变 + 阳光橙 + 漫游路径
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const MASTER = 1024
const AGC = 216
const SKY_TOP = [0x4e, 0xcd, 0xc4, 255]
const SKY_BOT = [0x45, 0xb7, 0xd1, 255]
const SUN = [0xff, 0xb3, 0x47, 255]
const WHITE = [0xff, 0xff, 0xff, 255]

function crc32(buf) {
  let c = 0xffffffff
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i]
    for (let k = 0; k < 8; k++) {
      c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0)
    }
  }
  return (c ^ 0xffffffff) >>> 0
}

function chunk(type, data) {
  const len = Buffer.alloc(4)
  len.writeUInt32BE(data.length, 0)
  const t = Buffer.from(type, 'ascii')
  const crcBuf = Buffer.concat([t, data])
  const crc = Buffer.alloc(4)
  crc.writeUInt32BE(crc32(crcBuf), 0)
  return Buffer.concat([len, t, data, crc])
}

function encodePng(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height)
  for (let y = 0; y < height; y++) {
    const rowStart = y * (width * 4 + 1)
    raw[rowStart] = 0
    rgba.copy(raw, rowStart + 1, y * width * 4, (y + 1) * width * 4)
  }
  const compressed = zlib.deflateSync(raw, { level: 9 })
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', compressed), chunk('IEND', Buffer.alloc(0))])
}

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return
  const i = (y * w + x) * 4
  buf[i] = c[0]
  buf[i + 1] = c[1]
  buf[i + 2] = c[2]
  buf[i + 3] = c[3]
}

function fillGradient(buf, w) {
  for (let y = 0; y < w; y++) {
    const t = y / (w - 1)
    const c = [
      Math.round(SKY_TOP[0] + (SKY_BOT[0] - SKY_TOP[0]) * t),
      Math.round(SKY_TOP[1] + (SKY_BOT[1] - SKY_TOP[1]) * t),
      Math.round(SKY_TOP[2] + (SKY_BOT[2] - SKY_TOP[2]) * t),
      255,
    ]
    for (let x = 0; x < w; x++) setPx(buf, w, x, y, c)
  }
}

function fillCircle(buf, w, cx, cy, r, c) {
  const r2 = r * r
  for (let y = Math.max(0, cy - r); y <= Math.min(w - 1, cy + r); y++) {
    for (let x = Math.max(0, cx - r); x <= Math.min(w - 1, cx + r); x++) {
      const dx = x - cx
      const dy = y - cy
      if (dx * dx + dy * dy <= r2) setPx(buf, w, x, y, c)
    }
  }
}

function strokePolyline(buf, w, pts, radius, c) {
  for (let i = 0; i < pts.length - 1; i++) {
    const [x0, y0] = pts[i]
    const [x1, y1] = pts[i + 1]
    const dx = x1 - x0
    const dy = y1 - y0
    const len = Math.max(1, Math.hypot(dx, dy))
    const n = Math.ceil(len)
    for (let s = 0; s <= n; s++) {
      const t = s / n
      fillCircle(buf, w, Math.round(x0 + dx * t), Math.round(y0 + dy * t), radius, c)
    }
  }
}

function drawMark(size) {
  const buf = Buffer.alloc(size * size * 4)
  fillGradient(buf, size)
  const s = size / 512
  fillCircle(buf, size, Math.round(360 * s), Math.round(152 * s), Math.round(52 * s), SUN)
  strokePolyline(
    buf,
    size,
    [
      [Math.round(96 * s), Math.round(340 * s)],
      [Math.round(160 * s), Math.round(280 * s)],
      [Math.round(220 * s), Math.round(360 * s)],
      [Math.round(280 * s), Math.round(300 * s)],
      [Math.round(340 * s), Math.round(260 * s)],
      [Math.round(416 * s), Math.round(320 * s)],
    ],
    Math.max(6, Math.round(7 * s)),
    WHITE,
  )
  strokePolyline(
    buf,
    size,
    [
      [Math.round(120 * s), Math.round(380 * s)],
      [Math.round(200 * s), Math.round(340 * s)],
      [Math.round(260 * s), Math.round(400 * s)],
      [Math.round(340 * s), Math.round(360 * s)],
      [Math.round(420 * s), Math.round(320 * s)],
      [Math.round(448 * s), Math.round(352 * s)],
    ],
    Math.max(4, Math.round(5 * s)),
    [255, 255, 255, 200],
  )
  fillCircle(buf, size, Math.round(200 * s), Math.round(368 * s), Math.round(18 * s), WHITE)
  fillCircle(buf, size, Math.round(320 * s), Math.round(328 * s), Math.round(12 * s), [255, 255, 255, 180])
  return buf
}

function nearestResize(src, srcSize, dstSize) {
  const out = Buffer.alloc(dstSize * dstSize * 4)
  for (let y = 0; y < dstSize; y++) {
    const sy = Math.min(srcSize - 1, Math.round((y * (srcSize - 1)) / (dstSize - 1)))
    for (let x = 0; x < dstSize; x++) {
      const sx = Math.min(srcSize - 1, Math.round((x * (srcSize - 1)) / (dstSize - 1)))
      const si = (sy * srcSize + sx) * 4
      const di = (y * dstSize + x) * 4
      out[di] = src[si]
      out[di + 1] = src[si + 1]
      out[di + 2] = src[si + 2]
      out[di + 3] = src[si + 3]
    }
  }
  return out
}

const master = drawMark(MASTER)
fs.writeFileSync(path.join(__dirname, 'preview-1024.png'), encodePng(MASTER, MASTER, master))
fs.writeFileSync(path.join(__dirname, 'background.png'), encodePng(MASTER, MASTER, master))
const fg = Buffer.from(master)
for (let i = 0; i < MASTER * MASTER; i++) {
  if (fg[i * 4 + 3] > 0) continue
  fg[i * 4 + 3] = 0
}
fs.writeFileSync(path.join(__dirname, 'foreground.png'), encodePng(MASTER, MASTER, fg))
const agc = nearestResize(master, MASTER, AGC)
fs.writeFileSync(path.join(__dirname, 'agc-216.png'), encodePng(AGC, AGC, agc))
console.log('OK rendered 夏日漫游 logo PNGs')
