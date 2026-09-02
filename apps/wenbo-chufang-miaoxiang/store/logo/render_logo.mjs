/**
 * Rasterize 厨房妙想 logo with Node only.
 * Mark: geometric kitchen spoon + inspiration sparkle.
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const MASTER = 1024
const AGC = 216
const BG = [0xf8, 0xf2, 0xe8, 255]
const GREEN = [0x12, 0x3f, 0x32, 255]
const GOLD = [0xb8, 0x91, 0x55, 255]
const CLEAR = [0, 0, 0, 0]

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

function fill(buf, w, c) {
  for (let i = 0; i < w * w; i++) {
    buf[i * 4] = c[0]
    buf[i * 4 + 1] = c[1]
    buf[i * 4 + 2] = c[2]
    buf[i * 4 + 3] = c[3]
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

function strokeLine(buf, w, x0, y0, x1, y1, radius, c) {
  const dx = x1 - x0
  const dy = y1 - y0
  const len = Math.max(1, Math.hypot(dx, dy))
  const n = Math.ceil(len)
  for (let s = 0; s <= n; s++) {
    const t = s / n
    fillCircle(buf, w, Math.round(x0 + dx * t), Math.round(y0 + dy * t), radius, c)
  }
}

function fillDiamond(buf, w, cx, cy, rx, ry, c) {
  for (let y = cy - ry; y <= cy + ry; y++) {
    const dy = Math.abs(y - cy) / ry
    const half = Math.round(rx * (1 - dy))
    for (let x = cx - half; x <= cx + half; x++) setPx(buf, w, x, y, c)
  }
}

function drawRoundedBackground(buf, w) {
  fill(buf, w, CLEAR)
  const r = Math.round(w * 0.222)
  for (let y = 0; y < w; y++) {
    for (let x = 0; x < w; x++) {
      const left = x < r
      const right = x >= w - r
      const top = y < r
      const bottom = y >= w - r
      let inside = true
      if (left && top) inside = (x - r) * (x - r) + (y - r) * (y - r) <= r * r
      if (right && top) inside = (x - (w - r - 1)) * (x - (w - r - 1)) + (y - r) * (y - r) <= r * r
      if (left && bottom) inside = (x - r) * (x - r) + (y - (w - r - 1)) * (y - (w - r - 1)) <= r * r
      if (right && bottom) inside = (x - (w - r - 1)) * (x - (w - r - 1)) + (y - (w - r - 1)) * (y - (w - r - 1)) <= r * r
      if (inside) setPx(buf, w, x, y, BG)
    }
  }
}

function drawMark(size) {
  const buf = Buffer.alloc(size * size * 4)
  drawRoundedBackground(buf, size)
  const s = size / 512

  fillCircle(buf, size, Math.round(340 * s), Math.round(194 * s), Math.round(84 * s), GREEN)
  strokeLine(buf, size, Math.round(284 * s), Math.round(258 * s), Math.round(118 * s), Math.round(472 * s), Math.round(30 * s), GREEN)
  fillCircle(buf, size, Math.round(340 * s), Math.round(194 * s), Math.round(34 * s), GREEN)
  strokeLine(buf, size, Math.round(294 * s), Math.round(186 * s), Math.round(254 * s), Math.round(268 * s), Math.round(16 * s), BG)
  fillDiamond(buf, size, Math.round(166 * s), Math.round(150 * s), Math.round(72 * s), Math.round(72 * s), GOLD)
  fillDiamond(buf, size, Math.round(166 * s), Math.round(150 * s), Math.round(32 * s), Math.round(104 * s), GOLD)
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
  const r = fg[i * 4]
  const g = fg[i * 4 + 1]
  const b = fg[i * 4 + 2]
  if (r === BG[0] && g === BG[1] && b === BG[2]) {
    fg[i * 4 + 3] = 0
  }
}
fs.writeFileSync(path.join(__dirname, 'foreground.png'), encodePng(MASTER, MASTER, fg))
fs.writeFileSync(path.join(__dirname, 'agc-216.png'), encodePng(AGC, AGC, nearestResize(master, MASTER, AGC)))
console.log('OK rendered 厨房妙想 logo PNGs')
