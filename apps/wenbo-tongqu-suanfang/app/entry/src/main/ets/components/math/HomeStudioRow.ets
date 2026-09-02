import { Theme } from '../design-system/Theme'

@Component
export struct HomeStudioRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onCustom: () => void = () => {}
  onPack: () => void = () => {}
  onCheckIn: () => void = () => {}
  onTimeline: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('学习工作台')
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.cell('家长出题', '自己写算式', () => this.onCustom())
        this.cell('我的题单', '组合题型', () => this.onPack())
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.cell('学习打卡', '记下今天', () => this.onCheckIn())
        this.cell('时间轴', '练习足迹', () => this.onTimeline())
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  cell(title: string, hint: string, tap: () => void) {
    Column({ space: Theme.space.s1 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .layoutWeight(1).padding(Theme.space.s4).alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(tap)
  }
}
