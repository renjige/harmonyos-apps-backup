export class SenseCardDraft {
  see: string = ''
  hear: string = ''
  scent: string = ''
  touch: string = ''
  verdict: string = ''
}

export class SenseCardService {
  static hasAny(d: SenseCardDraft): boolean {
    return d.see.trim().length > 0 || d.hear.trim().length > 0 ||
      d.scent.trim().length > 0 || d.touch.trim().length > 0 ||
      d.verdict.trim().length > 0
  }

  static compose(d: SenseCardDraft): string {
    const parts: string[] = []
    SenseCardService.pushBlock(parts, '【看见】', d.see)
    SenseCardService.pushBlock(parts, '【听见】', d.hear)
    SenseCardService.pushBlock(parts, '【气味】', d.scent)
    SenseCardService.pushBlock(parts, '【触感】', d.touch)
    SenseCardService.pushBlock(parts, '【一句判断】', d.verdict)
    return parts.join('\n').trim()
  }

  static parse(body: string): SenseCardDraft {
    const d = new SenseCardDraft()
    d.see = SenseCardService.extract(body, '【看见】', ['【听见】', '【气味】', '【触感】', '【一句判断】'])
    d.hear = SenseCardService.extract(body, '【听见】', ['【气味】', '【触感】', '【一句判断】'])
    d.scent = SenseCardService.extract(body, '【气味】', ['【触感】', '【一句判断】'])
    d.touch = SenseCardService.extract(body, '【触感】', ['【一句判断】'])
    d.verdict = SenseCardService.extract(body, '【一句判断】', [])
    return d
  }

  static looksLikeCard(body: string): boolean {
    return body.indexOf('【看见】') >= 0 || body.indexOf('【听见】') >= 0 ||
      body.indexOf('【气味】') >= 0 || body.indexOf('【触感】') >= 0 ||
      body.indexOf('【一句判断】') >= 0
  }

  static inferSenseKey(d: SenseCardDraft): string {
    if (d.see.trim().length > 0) {
      return 'light'
    }
    if (d.hear.trim().length > 0) {
      return 'sound'
    }
    if (d.scent.trim().length > 0) {
      return 'scent'
    }
    if (d.touch.trim().length > 0) {
      return 'touch'
    }
    if (d.verdict.trim().length > 0) {
      return 'people'
    }
    return ''
  }

  /** 统计/专题匹配用：优先 senseKey，否则从五感卡正文推断 */
  static resolveSenseKey(senseKey: string, body: string): string {
    if (senseKey.length > 0) {
      return senseKey
    }
    if (SenseCardService.looksLikeCard(body)) {
      return SenseCardService.inferSenseKey(SenseCardService.parse(body))
    }
    return ''
  }

  /** 专题进度：五感卡内对应栏位有内容即计入，不因「看见」优先推断而漏计「听见」 */
  static matchesThemeSense(themeSense: string, senseKey: string, body: string): boolean {
    if (themeSense.length === 0) {
      return true
    }
    if (SenseCardService.resolveSenseKey(senseKey, body) === themeSense) {
      return true
    }
    if (!SenseCardService.looksLikeCard(body)) {
      return senseKey.length === 0
    }
    const d = SenseCardService.parse(body)
    if (themeSense === 'light' && d.see.trim().length > 0) {
      return true
    }
    if (themeSense === 'sound' && d.hear.trim().length > 0) {
      return true
    }
    if (themeSense === 'scent' && d.scent.trim().length > 0) {
      return true
    }
    if (themeSense === 'touch' && d.touch.trim().length > 0) {
      return true
    }
    if (themeSense === 'people' && d.verdict.trim().length > 0) {
      return true
    }
    if (themeSense === 'color' || themeSense === 'space') {
      return senseKey.length === 0
    }
    return false
  }

  static defaultTitle(d: SenseCardDraft, dateKey: string): string {
    const v = d.verdict.trim()
    if (v.length > 0) {
      return v.length > 18 ? `${v.substring(0, 18)}…` : v
    }
    const s = d.see.trim()
    if (s.length > 0) {
      return s.length > 18 ? `${s.substring(0, 18)}…` : s
    }
    return `观察卡 · ${dateKey}`
  }

  private static pushBlock(parts: string[], mark: string, text: string): void {
    const t = text.trim()
    if (t.length === 0) {
      return
    }
    if (parts.length > 0) {
      parts.push('')
    }
    parts.push(mark)
    parts.push(t)
  }

  private static extract(body: string, mark: string, nextMarks: string[]): string {
    const start = body.indexOf(mark)
    if (start < 0) {
      return ''
    }
    let end = body.length
    for (const n of nextMarks) {
      const p = body.indexOf(n, start + mark.length)
      if (p >= 0 && p < end) {
        end = p
      }
    }
    return body.substring(start + mark.length, end).trim()
  }
}
