/** 从接口原文拆出 list 对象块，避免 ArkTS JSON.parse 无法填入 class 字段导致首页空白 */

export class JsonChunks {
  static objectsInList(raw: string): string[] {
    const key = '"list"'
    const k = raw.indexOf(key)
    if (k < 0) {
      return []
    }
    const lb = raw.indexOf('[', k)
    if (lb < 0) {
      return []
    }
    const out: string[] = []
    let depth = 0
    let start = -1
    for (let i = lb; i < raw.length; i++) {
      const ch = raw.charAt(i)
      if (ch === '{') {
        if (depth === 0) {
          start = i
        }
        depth++
      } else if (ch === '}') {
        depth--
        if (depth === 0 && start >= 0) {
          out.push(raw.substring(start, i + 1))
          start = -1
        }
      } else if (ch === ']' && depth === 0) {
        break
      }
    }
    return out
  }

  static str(chunk: string, key: string): string {
    const pat = `"${key}":`
    const idx = chunk.indexOf(pat)
    if (idx < 0) {
      return ''
    }
    let i = idx + pat.length
    while (i < chunk.length) {
      const c = chunk.charAt(i)
      if (c === ' ' || c === '\n' || c === '\r' || c === '\t') {
        i++
        continue
      }
      break
    }
    if (i >= chunk.length) {
      return ''
    }
    if (chunk.charAt(i) === '"') {
      i++
      let s = ''
      while (i < chunk.length) {
        const c = chunk.charAt(i)
        if (c === '\\' && i + 1 < chunk.length) {
          const n = chunk.charAt(i + 1)
          if (n === 'n') {
            s += '\n'
          } else if (n === '"') {
            s += '"'
          } else {
            s += n
          }
          i += 2
          continue
        }
        if (c === '"') {
          return s
        }
        s += c
        i++
      }
      return s
    }
    if (chunk.substring(i, i + 4) === 'null') {
      return ''
    }
    let num = ''
    while (i < chunk.length) {
      const c = chunk.charAt(i)
      if ((c >= '0' && c <= '9') || c === '.' || c === '-') {
        num += c
        i++
      } else {
        break
      }
    }
    return num
  }

  static num(chunk: string, key: string, fallback: number): number {
    const t = JsonChunks.str(chunk, key)
    if (t.length === 0) {
      return fallback
    }
    const n = Number(t)
    if (n > 0) {
      return n
    }
    return fallback
  }
}
