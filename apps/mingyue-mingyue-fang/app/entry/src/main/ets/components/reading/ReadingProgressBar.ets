import { Theme } from '../design-system/Theme'

/** 进度条独立组件：用 @Prop 驱动，避免详情 Builder 快照导致不刷新 */
@Component
export struct ReadingProgressBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop percent: number = 0
  @Prop caption: string = ''

  private barWidth(): string {
    const n = this.percent
    if (n <= 0) {
      return '0%'
    }
    if (n >= 100) {
      return '100%'
    }
    return `${n}%`
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      if (this.caption.length > 0) {
        Text(this.caption)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      }
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        Row()
          .width(this.barWidth())
          .height(8)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
    }
    .width('100%')
  }
}
