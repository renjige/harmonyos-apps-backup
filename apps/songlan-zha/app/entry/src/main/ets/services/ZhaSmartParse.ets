export class ZhaSmartParse {
  static extractTags(text: string): string[] {
    const tags: string[] = []
    const dateTag = ZhaSmartParse.extractDateTag(text)
    if (dateTag.length > 0) {
      tags.push(dateTag)
    }
    const timeTag = ZhaSmartParse.extractTimeTag(text)
    if (timeTag.length > 0) {
      tags.push(timeTag)
    }
    const placeTag = ZhaSmartParse.extractPlaceTag(text)
    if (placeTag.length > 0) {
      tags.push(placeTag)
    }
    return tags
  }

  private static extractDateTag(text: string): string {
    const m1 = text.match(/(\d{4})[年\-\/](\d{1,2})[月\-\/](\d{1,2})/)
    if (m1 !== null) {
      return `日期 ${m1[1]}-${m1[2]}-${m1[3]}`
    }
    const m2 = text.match(/(\d{1,2})月(\d{1,2})日/)
    if (m2 !== null) {
      return `日期 ${m2[1]}月${m2[2]}日`
    }
    if (text.indexOf('明天') >= 0) {
      return '日期·明天'
    }
    if (text.indexOf('今天') >= 0) {
      return '日期·今天'
    }
    return ''
  }

  private static extractTimeTag(text: string): string {
    const m = text.match(/(\d{1,2})[:：](\d{2})/)
    if (m !== null) {
      return `时间 ${m[1]}:${m[2]}`
    }
    if (text.indexOf('上午') >= 0 || text.indexOf('下午') >= 0 || text.indexOf('晚上') >= 0) {
      return '时间·时段'
    }
    return ''
  }

  private static extractPlaceTag(text: string): string {
    const keys: string[] = ['在', '于', '到']
    for (const k of keys) {
      const idx = text.indexOf(k)
      if (idx >= 0 && idx + 1 < text.length) {
        const slice = text.substring(idx + 1, idx + 8).trim()
        if (slice.length >= 2) {
          return `地点·${slice.substring(0, 4)}`
        }
      }
    }
    return ''
  }
}
