import { EssayFormatSegment } from '../models/EssayModels'

export class EssayFormatter {
  static lines(body: string): EssayFormatSegment[][] {
    const rawLines = body.length === 0 ? [''] : body.split('\n')
    const out: EssayFormatSegment[][] = []
    for (const raw of rawLines) {
      out.push(EssayFormatter.parseLine(raw))
    }
    return out
  }

  private static parseLine(line: string): EssayFormatSegment[] {
    let rest = line
    const segments: EssayFormatSegment[] = []
    if (rest.startsWith('- ') || rest.startsWith('• ')) {
      const list = new EssayFormatSegment()
      list.text = '• '
      list.isList = true
      segments.push(list)
      rest = rest.substring(2)
    }
    while (rest.length > 0) {
      if (rest.startsWith('**')) {
        const end = rest.indexOf('**', 2)
        if (end > 2) {
          const seg = new EssayFormatSegment()
          seg.text = rest.substring(2, end)
          seg.bold = true
          segments.push(seg)
          rest = rest.substring(end + 2)
          continue
        }
      }
      if (rest.startsWith('__')) {
        const end = rest.indexOf('__', 2)
        if (end > 2) {
          const seg = new EssayFormatSegment()
          seg.text = rest.substring(2, end)
          seg.underline = true
          segments.push(seg)
          rest = rest.substring(end + 2)
          continue
        }
      }
      if (rest.startsWith('*') && !rest.startsWith('**')) {
        const end = rest.indexOf('*', 1)
        if (end > 1) {
          const seg = new EssayFormatSegment()
          seg.text = rest.substring(1, end)
          seg.italic = true
          segments.push(seg)
          rest = rest.substring(end + 1)
          continue
        }
      }
      const next = rest.search(/[\*_]/)
      const chunk = next >= 0 ? rest.substring(0, next) : rest
      if (chunk.length > 0) {
        const seg = new EssayFormatSegment()
        seg.text = chunk
        segments.push(seg)
      }
      rest = next >= 0 ? rest.substring(next) : ''
    }
    if (segments.length === 0) {
      const empty = new EssayFormatSegment()
      empty.text = ''
      segments.push(empty)
    }
    return segments
  }
}
