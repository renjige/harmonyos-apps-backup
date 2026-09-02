export class SensitiveFilter {
  static lastHit: string = ''

  static blocked(): string[] {
    const words: string[] = []
    words.push('代开发票')
    words.push('枪支弹药')
    words.push('毒品交易')
    words.push('色情服务')
    words.push('赌博平台')
    words.push('博彩返利')
    words.push('洗钱通道')
    words.push('窃听设备')
    words.push('制毒配方')
    words.push('爆炸装置')
    return words
  }

  static scan(text: string): string {
    SensitiveFilter.lastHit = ''
    const src = text.toLowerCase()
    const list = SensitiveFilter.blocked()
    for (const w of list) {
      if (src.indexOf(w) >= 0) {
        SensitiveFilter.lastHit = w
        return w
      }
    }
    return ''
  }
}
