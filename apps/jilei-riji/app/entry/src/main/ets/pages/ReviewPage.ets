import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { KeywordItem, MonthStats } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'
import { DiaryStatsService } from '../services/DiaryStatsService'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stats: MonthStats = new MonthStats()
  @State keywords: KeywordItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const now = new Date()
    this.stats = await DiaryStatsService.monthStats(now.getFullYear(), now.getMonth() + 1)
    this.keywords = await DiaryStatsService.keywords(12)
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text('智慧回顾')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')

        Column({ space: Theme.space.s4 }) {
          Text(DateHelper.monthLabel(this.stats.year, this.stats.month))
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          Row({ space: Theme.space.s4 }) {
            Column({ space: 4 }) {
              Text(`${this.stats.diaryDays}`)
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('本月记录天数')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            Column({ space: 4 }) {
              Text(`${this.stats.longestStreak}`)
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandAccent)
              Text('最长连续记录')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('高频词云')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            if (this.keywords.length === 0) {
              Text('写更多日记后，这里会出现你的高频词汇')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.keywords, (kw: KeywordItem) => {
                  Text(`${kw.word} · ${kw.count}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().brandDeep)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (kw: KeywordItem) => kw.word)
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
        .padding(Theme.space.s5)
        .linearGradient({
          angle: 180,
          colors: [[Theme.colors().brandPrimaryContainer, 0], [Theme.colors().surfaceCard, 0.6]]
        })
        .borderRadius(Theme.radius.xl)

        AppButton({
          label: '刷新回顾',
          variant: 'secondary',
          onTap: (): void => { void this.load() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
