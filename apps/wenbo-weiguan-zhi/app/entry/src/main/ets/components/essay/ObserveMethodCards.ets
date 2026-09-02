import { Theme } from '../design-system/Theme'

class MethodItem {
  title: string = ''
  desc: string = ''
  accent: string = ''

  static all(): MethodItem[] {
    const rows: MethodItem[] = []
    const defs: string[][] = [
      ['五感观察卡', '看见·听见·气味·触感·一句判断，结构化写下此刻', '#1A2A3A'],
      ['对照观察', '并排两篇旧观察，必须写下「这次不同在哪」', '#2D4A5E'],
      ['观察专题', '为一种感官设定目标篇数，练满即完成', '#3A5266'],
      ['观察专辑', '把珍藏篇收成册，按主题回看', '#1A2A3A']
    ]
    for (const row of defs) {
      const m = new MethodItem()
      m.title = row[0]
      m.desc = row[1]
      m.accent = row[2]
      rows.push(m)
    }
    return rows
  }
}

/** 今日页「观察方法」区块 — 审核员一眼可见差异化，不是四个等宽按钮 */
@Component
export struct ObserveMethodCards {
  onCard: () => void = () => {}
  onContrast: () => void = () => {}
  onTheme: () => void = () => {}
  onAlbum: () => void = () => {}

  private items: MethodItem[] = MethodItem.all()

  private tapAt(index: number): void {
    if (index === 0) {
      this.onCard()
      return
    }
    if (index === 1) {
      this.onContrast()
      return
    }
    if (index === 2) {
      this.onTheme()
      return
    }
    this.onAlbum()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('观察方法')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank().layoutWeight(1)
        Text('≠ 普通日记')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
      }
      .width('100%')

      Text('微观志是带着方法的观察练习本：用五感结构写、用对照看变化、用专题约束练习、用专辑整理珍藏。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(20)

      ForEach(this.items, (m: MethodItem, index: number) => {
        Column({ space: 4 }) {
          Text(m.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .width('100%')
          Text(m.desc)
            .fontSize(Theme.type.caption)
            .fontColor('#E8E4DC')
            .width('100%')
            .lineHeight(18)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(m.accent)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.tapAt(index) })
      }, (m: MethodItem, index: number) => `${index}_${m.title}`)
    }
    .width('100%')
  }
}
