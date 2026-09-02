/** 生成菜谱封面占位图（暖色食物摄影风格渐变） */
import fs from 'fs'
import path from 'path'
import zlib from 'zlib'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const OUT = path.join(__dirname, '../../app/entry/src/main/resources/base/media')

const KEYS = [
  'recipe_tomato_egg', 'recipe_broccoli_garlic', 'recipe_braised_tofu', 'recipe_stir_fry_greens',
  'recipe_mushroom_soup', 'recipe_scallion_noodles', 'recipe_molecular_egg', 'recipe_salmon_pan',
  'recipe_mapo_tofu', 'recipe_lemon_tea', 'recipe_beef_potato', 'recipe_avocado_toast',
  'hero_kitchen_lab',
]

const PALETTES = [
  [[255, 140, 80], [180, 70, 40]],
  [[120, 180, 90], [40, 90, 50]],
  [[220, 180, 120], [140, 100, 60]],
  [[200, 160, 100], [120, 80, 40]],
  [[160, 130, 100], [80, 60, 40]],
  [[240, 200, 140], [160, 120, 70]],
  [[255, 220, 180], [200, 150, 100]],
  [[255, 120, 100], [180, 60, 50]],
]

function crc32(buf) {
  let c = 0xffffffff
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i]
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (c & 1 ? 0xedb88320 : 0)
  }
  return (c ^ 0xffffffff) >>> 0
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
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  const chunk = (type, data) => {
    const len = Buffer.alloc(4)
    len.writeUInt32BE(data.length, 0)
    const t = Buffer.from(type)
    const crc = Buffer.alloc(4)
    crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0)
    return Buffer.concat([len, t, data, crc])
  }
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))])
}

function render(w, h, top, bot) {
  const buf = Buffer.alloc(w * h * 4)
  for (let y = 0; y < h; y++) {
    const t = y / (h - 1)
    for (let x = 0; x < w; x++) {
      const i = (y * w + x) * 4
      const nx = (x / w - 0.5) * 0.3
      const ny = (y / h - 0.5) * 0.3
      const vignette = 1 - Math.min(0.35, nx * nx + ny * ny)
      buf[i] = Math.round((top[0] + (bot[0] - top[0]) * t) * vignette)
      buf[i + 1] = Math.round((top[1] + (bot[1] - top[1]) * t) * vignette)
      buf[i + 2] = Math.round((top[2] + (bot[2] - top[2]) * t) * vignette)
      buf[i + 3] = 255
    }
  }
  return buf
}

fs.mkdirSync(OUT, { recursive: true })
KEYS.forEach((key, idx) => {
  const [top, bot] = PALETTES[idx % PALETTES.length]
  fs.writeFileSync(path.join(OUT, `${key}.png`), encodePng(800, 600, render(800, 600, top, bot)))
  console.log(`wrote ${key}.png`)
})
