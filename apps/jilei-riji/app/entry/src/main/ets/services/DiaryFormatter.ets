export class DiaryFormatSegment {
  text: string = ''
  bold: boolean = false
  italic: boolean = false
  isList: boolean = false
}

export class DiaryFormatter {
  static hasMarkup(body: string): boolean {
    return body.includes('**') || body.includes('*') || body.includes('\n- ') || body.includes('\n• ')
  }

  static lines(body: string): DiaryFormatSegment[][] {
    const rawLines = body.length === 0 ? [''] : body.split('\n')
    const out: DiaryFormatSegment[][] = []
    for (const raw of rawLines) {
      out.push(DiaryFormatter.parseLine(raw))
    }
    return out
  }

  private static parseLine(line: string): DiaryFormatSegment[] {
    let rest = line
    const segments: DiaryFormatSegment[] = []
    if (rest.startsWith('- ') || rest.startsWith('• ')) {
      const list = new DiaryFormatSegment()
      list.text = '• '
      list.isList = true
      segments.push(list)
      rest = rest.startsWith('- ') ? rest.substring(2) : rest.substring(2)
    }
    while (rest.length > 0) {
      if (rest.startsWith('**')) {
        const end = rest.indexOf('**', 2)
        if (end > 2) {
          const seg = new DiaryFormatSegment()
          seg.text = rest.substring(2, end)
          seg.bold = true
          segments.push(seg)
          rest = rest.substring(end + 2)
          continue
        }
      }
      if (rest.startsWith('*') && !rest.startsWith('**')) {
        const end = rest.indexOf('*', 1)
        if (end > 1) {
          const seg = new DiaryFormatSegment()
          seg.text = rest.substring(1, end)
          seg.italic = true
          segments.push(seg)
          rest = rest.substring(end + 1)
          continue
        }
      }
      const next = rest.search(/\*/)
      const chunk = next >= 0 ? rest.substring(0, next) : rest
      if (chunk.length > 0) {
        const seg = new DiaryFormatSegment()
        seg.text = chunk
        segments.push(seg)
      }
      rest = next >= 0 ? rest.substring(next) : ''
    }
    if (segments.length === 0) {
      const empty = new DiaryFormatSegment()
      empty.text = ''
      segments.push(empty)
    }
    return segments
  }
}
