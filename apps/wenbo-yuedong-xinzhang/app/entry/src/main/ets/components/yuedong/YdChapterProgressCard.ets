import { Theme } from '../design-system/Theme'
import { YdChapterItem } from '../../models/YdModels'

@Component
export struct YdChapterProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop chapter: YdChapterItem = new YdChapterItem()

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('篇章进度')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`第 ${this.chapter.elapsedDays()} / ${this.chapter.totalDays()} 天`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Progress({
        value: this.chapter.chapterProgressPercent(),
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 8 })

      Text(this.chapter.themeQuote())
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .lineHeight(20)
        .fontStyle(FontStyle.Italic)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
