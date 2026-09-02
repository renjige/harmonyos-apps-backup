import { Theme } from '../design-system/Theme'

@Component
export struct WeekCompareCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop thisMinutes: number = 0
  @Prop lastMinutes: number = 0
  @Prop thisDays: number = 0

  private deltaText(): string {
    const delta = this.thisMinutes - this.lastMinutes
    if (delta > 0) {
      return `比上周多 ${delta} 分钟`
    }
    if (delta < 0) {
      return `比上周少 ${0 - delta} 分钟`
    }
    return '时长与上周持平'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('本周对照上周')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column({ space: 2 }) {
          Text(`${this.thisMinutes}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('本周分钟')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        Column({ space: 2 }) {
          Text(`${this.lastMinutes}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('上周分钟')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        Column({ space: 2 }) {
          Text(`${this.thisDays}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('本周天数')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      Text(this.deltaText())
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
    }
    .width('100%')
  }
}
