/**
 * 厨验Lab logo — 锅具 + 烧杯负空间融合，暖橙实验感
 */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const MASTER = 1024
const AGC = 216
const BG_TOP = [0xff, 0xf4, 0xeb, 255]
const BG_BOT = [0xf5, 0xd9, 0xc0, 255]
const ORANGE = [0xe8, 0x82, 0x3a, 255]
const INK = [0x2d, 0x34, 0x36, 255]
const CLEAR = [0, 0, 0, 0]

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

function encodePng(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height)
  for (let y = 0; y < height; y++) {
    const rowStart = y * (width * 4 + 1)
    raw[rowStart] = 0
    rgba.copy(raw, rowStart + 1, y * width * 4, (y + 1) * width * 4)
  }
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ])
}

function setPx(buf, w, x, y, c) {
  if (x < 0 || y < 0 || x >= w || y >= w) return
  const i = (y * w + x) * 4
  buf[i] = c[0]
  buf[i + 1] = c[1]
  buf[i + 2] = c[2]
  buf[i + 3] = c[3]
}

function fillCircle(buf, w, cx, cy, r, c) {
  for (let y = Math.max(0, cy - r); y <= Math.min(w - 1, cy + r); y++) {
    for (let x = Math.max(0, cx - r); x <= Math.min(w - 1, cx + r); x++) {
      if ((x - cx) ** 2 + (y - cy) ** 2 <= r * r) setPx(buf, w, x, y, c)
    }
  }
}

function strokeLine(buf, w, x0, y0, x1, y1, radius, c) {
  const n = Math.ceil(Math.hypot(x1 - x0, y1 - y0))
  for (let s = 0; s <= n; s++) {
    const t = s / Math.max(1, n)
    fillCircle(buf, w, Math.round(x0 + (x1 - x0) * t), Math.round(y0 + (y1 - y0) * t), radius, c)
  }
}

function fillRect(buf, w, x0, y0, x1, y1, c) {
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) setPx(buf, w, x, y, c)
  }
}

function drawMark(size) {
  const buf = Buffer.alloc(size * size * 4)
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const t = y / (size - 1)
      setPx(buf, size, x, y, [
        Math.round(BG_TOP[0] + (BG_BOT[0] - BG_TOP[0]) * t),
        Math.round(BG_TOP[1] + (BG_BOT[1] - BG_TOP[1]) * t),
        Math.round(BG_TOP[2] + (BG_BOT[2] - BG_TOP[2]) * t),
        255,
      ])
    }
  }
  const s = size / 512
  // 烧杯轮廓
  strokeLine(buf, size, Math.round(148 * s), Math.round(130 * s), Math.round(148 * s), Math.round(360 * s), Math.round(18 * s), INK)
  strokeLine(buf, size, Math.round(148 * s), Math.round(130 * s), Math.round(228 * s), Math.round(130 * s), Math.round(16 * s), INK)
  strokeLine(buf, size, Math.round(228 * s), Math.round(130 * s), Math.round(248 * s), Math.round(360 * s), Math.round(18 * s), INK)
  strokeLine(buf, size, Math.round(148 * s), Math.round(360 * s), Math.round(248 * s), Math.round(360 * s), Math.round(16 * s), INK)
  fillRect(buf, size, Math.round(168 * s), Math.round(250 * s), Math.round(220 * s), Math.round(340 * s), ORANGE)
  // 锅具负形
  fillCircle(buf, size, Math.round(340 * s), Math.round(250 * s), Math.round(110 * s), ORANGE)
  fillCircle(buf, size, Math.round(340 * s), Math.round(250 * s), Math.round(72 * s), [
    Math.round(BG_TOP[0] * 0.85 + BG_BOT[0] * 0.15),
    Math.round(BG_TOP[1] * 0.85 + BG_BOT[1] * 0.15),
    Math.round(BG_TOP[2] * 0.85 + BG_BOT[2] * 0.15),
    255,
  ])
  strokeLine(buf, size, Math.round(260 * s), Math.round(210 * s), Math.round(420 * s), Math.round(210 * s), Math.round(14 * s), INK)
  // 分子节点
  fillCircle(buf, size, Math.round(380 * s), Math.round(150 * s), Math.round(16 * s), INK)
  fillCircle(buf, size, Math.round(420 * s), Math.round(190 * s), Math.round(12 * s), INK)
  strokeLine(buf, size, Math.round(380 * s), Math.round(150 * s), Math.round(420 * s), Math.round(190 * s), Math.round(4 * s), INK)
  return buf
}

function copyToAppIcon(srcPath, destPath) {
  fs.mkdirSync(path.dirname(destPath), { recursive: true })
  fs.copyFileSync(srcPath, destPath)
}

const master = drawMark(MASTER)
fs.writeFileSync(path.join(__dirname, 'preview-1024.png'), encodePng(MASTER, MASTER, master))
fs.writeFileSync(path.join(__dirname, 'background.png'), encodePng(MASTER, MASTER, master))
const fg = Buffer.from(master)
for (let i = 0; i < MASTER * MASTER; i++) {
  const r = fg[i * 4]
  const g = fg[i * 4 + 1]
  const b = fg[i * 4 + 2]
  const t = (i / 4) % MASTER
  const grad = [
    Math.round(BG_TOP[0] + (BG_BOT[0] - BG_TOP[0]) * (t / MASTER)),
    Math.round(BG_TOP[1] + (BG_BOT[1] - BG_TOP[1]) * (t / MASTER)),
    Math.round(BG_TOP[2] + (BG_BOT[2] - BG_TOP[2]) * (t / MASTER)),
  ]
  if (Math.abs(r - grad[0]) < 8 && Math.abs(g - grad[1]) < 8 && Math.abs(b - grad[2]) < 8) {
    fg[i * 4 + 3] = 0
  }
}
fs.writeFileSync(path.join(__dirname, 'foreground.png'), encodePng(MASTER, MASTER, fg))
fs.writeFileSync(path.join(__dirname, 'agc-216.png'), encodePng(AGC, AGC, master))
const appRoot = path.resolve(__dirname, '../../app')
copyToAppIcon(path.join(__dirname, 'preview-1024.png'), path.join(appRoot, 'AppScope/resources/base/media/app_icon.png'))
copyToAppIcon(path.join(__dirname, 'preview-1024.png'), path.join(appRoot, 'entry/src/main/resources/base/media/icon.png'))
copyToAppIcon(path.join(__dirname, 'preview-1024.png'), path.join(appRoot, 'entry/src/main/resources/base/media/startIcon.png'))
console.log('OK rendered 厨验Lab logo PNGs')
