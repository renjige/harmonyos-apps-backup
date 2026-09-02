/**
 * Rasterize 晴川游 logo: deep indigo + white sun + twin peaks. Two colors only.
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const MASTER = 1024
const AGC = 216
const BG = [0x1b, 0x3a, 0x5c, 255]
const MARK = [0xf4, 0xfa, 0xff, 255]
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

function fillPoly(buf, w, pts, c) {
  let minY = w
  let maxY = 0
  for (const p of pts) {
    minY = Math.min(minY, p[1])
    maxY = Math.max(maxY, p[1])
  }
  for (let y = minY; y <= maxY; y++) {
    const xs = []
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i]
      const b = pts[(i + 1) % pts.length]
      if ((a[1] <= y && b[1] > y) || (b[1] <= y && a[1] > y)) {
        const t = (y - a[1]) / (b[1] - a[1] || 1)
        xs.push(Math.round(a[0] + t * (b[0] - a[0])))
      }
    }
    xs.sort((p, q) => p - q)
    for (let i = 0; i + 1 < xs.length; i += 2) {
      const x0 = Math.max(0, xs[i])
      const x1 = Math.min(w - 1, xs[i + 1])
      for (let x = x0; x <= x1; x++) setPx(buf, w, x, y, c)
    }
  }
}

function drawMark(size, bg) {
  const buf = Buffer.alloc(size * size * 4)
  fill(buf, size, bg)
  const s = size / 512
  fillCircle(buf, size, Math.round(256 * s), Math.round(168 * s), Math.round(64 * s), MARK)
  fillPoly(
    buf,
    size,
    [
      [Math.round(48 * s), Math.round(420 * s)],
      [Math.round(160 * s), Math.round(250 * s)],
      [Math.round(256 * s), Math.round(340 * s)],
      [Math.round(360 * s), Math.round(220 * s)],
      [Math.round(464 * s), Math.round(420 * s)],
    ],
    MARK,
  )
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

const composed = drawMark(MASTER, BG)
const solid = Buffer.alloc(MASTER * MASTER * 4)
fill(solid, MASTER, BG)
const fg = drawMark(MASTER, CLEAR)

fs.writeFileSync(path.join(__dirname, 'preview-1024.png'), encodePng(MASTER, MASTER, composed))
fs.writeFileSync(path.join(__dirname, 'background.png'), encodePng(MASTER, MASTER, solid))
fs.writeFileSync(path.join(__dirname, 'foreground.png'), encodePng(MASTER, MASTER, fg))
const agc = nearestResize(composed, MASTER, AGC)
fs.writeFileSync(path.join(__dirname, 'agc-216.png'), encodePng(AGC, AGC, agc))
console.log('OK rendered 晴川游 logo PNGs')
