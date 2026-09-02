import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { JournalHeroImage } from '../journal/JournalHeroImage'

@Component
export struct TodayHeroCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop coverKey: string = 'hero_morning_coffee'
  @Prop moodLabel: string = ''
  @Prop diaryTitle: string = ''
  @Prop hasToday: boolean = false
  onWriteToday: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      JournalHeroImage({
        coverKey: this.coverKey,
        fallbackKey: 'hero_morning_coffee',
        heroHeight: 180
      })
      Column()
        .width('100%')
        .height(180)
        .linearGradient({
          angle: 180,
          colors: [['rgba(166,123,91,0.08)', 0], ['rgba(61,58,54,0.78)', 1]]
        })
        .borderRadius(Theme.radius.xl)
      Column({ space: Theme.space.s3 }) {
        Text('今日工作台')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textOnInverse)
        Text(`心情 · ${this.moodLabel}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textOnInverse)
        if (this.diaryTitle.length > 0) {
          Text(this.diaryTitle)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnInverse)
            .maxLines(2)
        }
        AppButton({
          label: this.hasToday ? '继续创作' : '场景创作',
          onTap: (): void => { this.onWriteToday() }
        })
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
