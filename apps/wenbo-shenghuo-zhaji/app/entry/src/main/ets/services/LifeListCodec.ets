/** 清单正文编解码：0/1 + 制表符 + 文案，每行一项 */
export class LifeListLine {
  text: string = ''
  done: boolean = false
}

export class LifeListCodec {
  static encode(lines: LifeListLine[]): string {
    const parts: string[] = []
    for (let i = 0; i < lines.length; i++) {
      const flag = lines[i].done ? '1' : '0'
      parts.push(`${flag}\t${lines[i].text}`)
    }
    return parts.join('\n')
  }

  static decode(body: string): LifeListLine[] {
    const out: LifeListLine[] = []
    if (body.length === 0) {
      return out
    }
    const rows = body.split('\n')
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i].trim()
      if (row.length === 0) {
        continue
      }
      const line = new LifeListLine()
      const tab = row.indexOf('\t')
      if (tab === 1 && (row.startsWith('0') || row.startsWith('1'))) {
        line.done = row.startsWith('1')
        line.text = row.substring(2)
      } else {
        line.text = row
        line.done = false
      }
      out.push(line)
    }
    return out
  }

  static fromPlain(raw: string): LifeListLine[] {
    const out: LifeListLine[] = []
    const rows = raw.split('\n')
    for (let i = 0; i < rows.length; i++) {
      const text = rows[i].trim()
      if (text.length > 0) {
        const line = new LifeListLine()
        line.text = text
        out.push(line)
      }
    }
    return out
  }
}
