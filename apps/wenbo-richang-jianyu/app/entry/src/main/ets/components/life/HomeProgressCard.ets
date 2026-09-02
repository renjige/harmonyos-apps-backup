import { Theme } from '../design-system/Theme'

@Component
export struct HomeProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop percent: number = 0
  @Prop hint: string = ''
  @Prop moodLabel: string = ''
  @Prop activityHint: string = ''
  onContinue: () => void = () => {}

  private barWidth(): string {
    if (this.percent <= 0) {
      return '4%'
    }
    if (this.percent >= 100) {
      return '100%'
    }
    return `${this.percent}%`
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日进度')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${this.percent}%`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Column() {
        Row() {
          Column()
            .width(this.barWidth())
            .height(8)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height(8)
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)

      Text(this.hint)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(`心情 ${this.moodLabel} · ${this.activityHint}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      Text('继续完成')
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
        .onClick((): void => { this.onContinue() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
