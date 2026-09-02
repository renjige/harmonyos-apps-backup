import { Theme } from '../design-system/Theme'

@Component
export struct HomeStatStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todayStars: number = 0
  @Prop totalStars: number = 0
  @Prop done: number = 0
  @Prop todayAcc: number = 0

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日表现')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.cell('今日星星', `${this.todayStars}`)
        this.cell('累计星星', `${this.totalStars}`)
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.cell('今日正确率', this.done > 0 ? `${this.todayAcc}%` : '—')
        this.cell('今日已练', `${this.done} 题`)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  cell(label: string, value: string) {
    Column({ space: Theme.space.s1 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
