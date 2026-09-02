class HslColor {
  h: number = 0
  s: number = 0
  l: number = 0
}

export class PaletteHarmonyService {
  static generate(baseHex: string, typeId: string): string[] {
    const base = PaletteHarmonyService.hexToHsl(baseHex)
    const hues: number[] = []
    if (typeId === 'complementary') {
      hues.push(base.h, PaletteHarmonyService.wrapHue(base.h + 180))
    } else if (typeId === 'triadic') {
      hues.push(base.h, PaletteHarmonyService.wrapHue(base.h + 120), PaletteHarmonyService.wrapHue(base.h + 240))
    } else if (typeId === 'split') {
      hues.push(base.h, PaletteHarmonyService.wrapHue(base.h + 150), PaletteHarmonyService.wrapHue(base.h + 210))
    } else {
      hues.push(
        PaletteHarmonyService.wrapHue(base.h - 30),
        base.h,
        PaletteHarmonyService.wrapHue(base.h + 30)
      )
    }
    const colors: string[] = []
    for (const h of hues) {
      colors.push(PaletteHarmonyService.hslToHex(h, base.s, base.l))
    }
    colors.push(PaletteHarmonyService.hslToHex(base.h, Math.max(20, base.s - 25), Math.min(92, base.l + 28)))
    colors.push(PaletteHarmonyService.hslToHex(base.h, base.s, Math.max(12, base.l - 28)))
    return colors
  }

  static normalizeHex(hex: string): string {
    let value = hex.trim().toUpperCase()
    if (value.indexOf('#') !== 0) {
      value = `#${value}`
    }
    if (value.length === 4) {
      const r = value.charAt(1)
      const g = value.charAt(2)
      const b = value.charAt(3)
      value = `#${r}${r}${g}${g}${b}${b}`
    }
    return value
  }

  private static wrapHue(h: number): number {
    let next = h
    while (next < 0) {
      next += 360
    }
    while (next >= 360) {
      next -= 360
    }
    return next
  }

  private static hexToHsl(hex: string): HslColor {
    const normalized = PaletteHarmonyService.normalizeHex(hex)
    const r = parseInt(normalized.substring(1, 3), 16) / 255
    const g = parseInt(normalized.substring(3, 5), 16) / 255
    const b = parseInt(normalized.substring(5, 7), 16) / 255
    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    const hsl = new HslColor()
    hsl.l = (max + min) / 2
    if (max === min) {
      hsl.h = 0
      hsl.s = 0
      return hsl
    }
    const delta = max - min
    hsl.s = hsl.l > 0.5 ? delta / (2 - max - min) : delta / (max + min)
    if (max === r) {
      hsl.h = (g - b) / delta + (g < b ? 6 : 0)
    } else if (max === g) {
      hsl.h = (b - r) / delta + 2
    } else {
      hsl.h = (r - g) / delta + 4
    }
    hsl.h = hsl.h * 60
    hsl.s = Math.round(hsl.s * 100)
    hsl.l = Math.round(hsl.l * 100)
    return hsl
  }

  private static hslToHex(h: number, s: number, l: number): string {
    const sat = s / 100
    const light = l / 100
    const c = (1 - Math.abs(2 * light - 1)) * sat
    const x = c * (1 - Math.abs((h / 60) % 2 - 1))
    const m = light - c / 2
    let r = 0
    let g = 0
    let b = 0
    if (h < 60) {
      r = c
      g = x
    } else if (h < 120) {
      r = x
      g = c
    } else if (h < 180) {
      g = c
      b = x
    } else if (h < 240) {
      g = x
      b = c
    } else if (h < 300) {
      r = x
      b = c
    } else {
      r = c
      b = x
    }
    const toHex = (v: number): string => {
      const n = Math.round((v + m) * 255)
      const s2 = n.toString(16).toUpperCase()
      return s2.length === 1 ? `0${s2}` : s2
    }
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`
  }
}
