export class MarkupSeg {
  text: string = ''
  heading: number = 0
  bold: boolean = false
  italic: boolean = false
}

export class MarkupLine {
  segs: MarkupSeg[] = []
}

export class MarkupService {
  static wrap(body: string, start: number, end: number, open: string, close: string): string {
    const s = start < 0 ? 0 : start
    const e = end < 0 ? 0 : end
    if (e > s && e <= body.length) {
      return `${body.substring(0, s)}${open}${body.substring(s, e)}${close}${body.substring(e)}`
    }
    const insert = `${open}文字${close}`
    const pos = s <= body.length ? s : body.length
    if (body.length === 0) {
      return insert
    }
    if (pos <= 0) {
      return `${insert}${body}`
    }
    if (pos >= body.length) {
      return `${body}${insert}`
    }
    return `${body.substring(0, pos)}${insert}${body.substring(pos)}`
  }

  static headingPrefix(level: number): string {
    if (level === 1) {
      return '# '
    }
    if (level === 2) {
      return '## '
    }
    return '### '
  }

  static insertLinePrefix(body: string, start: number, prefix: string): string {
    const pos = start < 0 || start > body.length ? body.length : start
    const before = body.substring(0, pos)
    const nl = before.lastIndexOf('\n')
    const lineStart = nl >= 0 ? nl + 1 : 0
    return `${body.substring(0, lineStart)}${prefix}${body.substring(lineStart)}`
  }

  static parse(body: string): MarkupLine[] {
    const out: MarkupLine[] = []
    const rawLines = body.split('\n')
    for (const raw of rawLines) {
      const line = new MarkupLine()
      let t = raw
      let heading = 0
      if (t.startsWith('### ')) {
        heading = 3
        t = t.substring(4)
      } else if (t.startsWith('## ')) {
        heading = 2
        t = t.substring(3)
      } else if (t.startsWith('# ')) {
        heading = 1
        t = t.substring(2)
      }
      if (t.startsWith('- ')) {
        t = `• ${t.substring(2)}`
      } else if (t.startsWith('1. ')) {
        t = `1. ${t.substring(3)}`
      }
      line.segs = MarkupService.splitInline(t, heading)
      out.push(line)
    }
    return out
  }

  private static splitInline(text: string, heading: number): MarkupSeg[] {
    const segs: MarkupSeg[] = []
    let bold = false
    let italic = false
    let buf = ''
    let i = 0
    const flush = (): void => {
      if (buf.length === 0) {
        return
      }
      const s = new MarkupSeg()
      s.text = buf
      s.heading = heading
      s.bold = bold
      s.italic = italic
      segs.push(s)
      buf = ''
    }
    while (i < text.length) {
      if (text.substring(i, i + 2) === '**') {
        flush()
        bold = !bold
        i += 2
      } else if (text.substring(i, i + 1) === '*') {
        flush()
        italic = !italic
        i += 1
      } else {
        buf = `${buf}${text.substring(i, i + 1)}`
        i += 1
      }
    }
    flush()
    if (segs.length === 0) {
      const empty = new MarkupSeg()
      empty.text = ' '
      empty.heading = heading
      segs.push(empty)
    }
    return segs
  }
}
