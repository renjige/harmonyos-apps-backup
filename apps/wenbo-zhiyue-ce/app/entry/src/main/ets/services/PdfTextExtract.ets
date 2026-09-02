/**
 * Best-effort text from uncompressed PDF string operators.
 * Scanned / compressed Chinese PDFs may yield little text; the reader still
 * shows original pages via local preview.
 */
export class PdfTextExtract {
  static fromBytes(buf: ArrayBuffer): string {
    const bytes = new Uint8Array(buf)
    const src = PdfTextExtract.asLatin1(bytes)
    const chunks: string[] = []
    PdfTextExtract.collectTj(src, chunks)
    const joined = PdfTextExtract.clean(chunks.join(''))
    if (joined.length < 8) {
      return ''
    }
    if (joined.length > 80000) {
      return joined.substring(0, 80000)
    }
    return joined
  }

  private static asLatin1(bytes: Uint8Array): string {
    let out = ''
    const n = bytes.length > 2000000 ? 2000000 : bytes.length
    for (let i = 0; i < n; i++) {
      out += String.fromCharCode(bytes[i])
    }
    return out
  }

  private static collectTj(src: string, out: string[]): void {
    let i = 0
    while (i < src.length) {
      const start = src.indexOf('(', i)
      if (start < 0) {
        return
      }
      let j = start + 1
      let piece = ''
      let escaped = false
      while (j < src.length) {
        const ch = src.charAt(j)
        if (escaped) {
          if (ch === 'n' || ch === 'r') {
            piece += '\n'
          } else {
            piece += ch
          }
          escaped = false
          j++
          continue
        }
        if (ch === '\\') {
          escaped = true
          j++
          continue
        }
        if (ch === ')') {
          break
        }
        piece += ch
        j++
      }
      const rest = src.substring(j + 1, j + 16)
      if (rest.indexOf('Tj') >= 0 || rest.indexOf('TJ') >= 0) {
        if (PdfTextExtract.printable(piece)) {
          out.push(piece)
        }
      }
      i = j + 1
    }
  }

  private static printable(s: string): boolean {
    if (s.length === 0) {
      return false
    }
    let good = 0
    for (let i = 0; i < s.length; i++) {
      const c = s.charCodeAt(i)
      if (c === 9 || c === 10 || c === 13 || (c >= 32 && c < 127) || c >= 0x80) {
        good++
      }
    }
    return good * 2 >= s.length
  }

  private static clean(raw: string): string {
    return raw.replace(/\u0000/g, '').replace(/[ \t]+/g, ' ').trim()
  }
}
