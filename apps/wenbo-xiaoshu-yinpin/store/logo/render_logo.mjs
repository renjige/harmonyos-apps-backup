/**
 * Rasterize 消暑饮品 logo: deep teal + near-white glass + mint leaf.
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const MASTER = 1024
const AGC = 216
const BG = [0x0b, 0x3a, 0x48, 255]
const MARK = [0xf4, 0xfb, 0xff, 255]
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

function fillEllipse(buf, w, cx, cy, rx, ry, c) {
  for (let y = Math.max(0, cy - ry); y <= Math.min(w - 1, cy + ry); y++) {
    for (let x = Math.max(0, cx - rx); x <= Math.min(w - 1, cx + rx); x++) {
      const dx = (x - cx) / rx
      const dy = (y - cy) / ry
      if (dx * dx + dy * dy <= 1) setPx(buf, w, x, y, c)
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
        const t = (y - a[1]) / (b[1] - a[1])
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

function drawMark(size, hole) {
  const buf = Buffer.alloc(size * size * 4)
  fill(buf, size, hole[3] === 0 && hole[0] === 0 ? CLEAR : hole)
  if (hole[3] !== 0) {
    fill(buf, size, hole)
  } else {
    fill(buf, size, CLEAR)
  }
  const s = size / 512
  const sc = (n) => Math.round(n * s)
  fillEllipse(buf, size, sc(256), sc(168), sc(102), sc(30), MARK)
  fillPoly(buf, size, [
    [sc(168), sc(176)],
    [sc(198), sc(392)],
    [sc(256), sc(416)],
    [sc(314), sc(392)],
    [sc(344), sc(176)],
  ], MARK)
  fillPoly(buf, size, [
    [sc(198), sc(196)],
    [sc(218), sc(372)],
    [sc(256), sc(388)],
    [sc(294), sc(372)],
    [sc(314), sc(196)],
  ], hole[3] === 0 ? CLEAR : BG)
  fillPoly(buf, size, [
    [sc(214), sc(300)],
    [sc(256), sc(328)],
    [sc(298), sc(300)],
    [sc(292), sc(368)],
    [sc(256), sc(384)],
    [sc(220), sc(368)],
  ], MARK)
  fillEllipse(buf, size, sc(256), sc(176), sc(78), sc(18), hole[3] === 0 ? CLEAR : BG)
  fillEllipse(buf, size, sc(256), sc(176), sc(56), sc(12), MARK)
  fillEllipse(buf, size, sc(332), sc(150), sc(30), sc(14), MARK)
  fillEllipse(buf, size, sc(358), sc(162), sc(24), sc(12), MARK)
  fillPoly(buf, size, [
    [sc(336), sc(158)],
    [sc(344), sc(158)],
    [sc(350), sc(180)],
    [sc(340), sc(180)],
  ], MARK)
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
console.log('OK rendered 消暑饮品 logo PNGs')
