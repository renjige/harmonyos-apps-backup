import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { DiaryEntry, KeywordItem, MonthStats, MoodOption, WeekSummary } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'
import { DiaryStatsService } from '../services/DiaryStatsService'

@Component
export struct StatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State year: number = 2026
  @State month: number = 8
  @State stats: MonthStats = new MonthStats()
  @State keywords: KeywordItem[] = []
  @State weekSummary: WeekSummary = new WeekSummary()
  @State onThisDay: DiaryEntry[] = []

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await DiaryStatsService.monthStats(this.year, this.month)
    this.keywords = await DiaryStatsService.keywords(12)
    this.weekSummary = await DiaryStatsService.weekSummary()
    this.onThisDay = await DiaryStatsService.onThisDay()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('智慧回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({ label: '本月天数', value: `${this.stats.diaryDays}天` })
            .layoutWeight(1)
          AppStatCard({ label: '总字数', value: `${this.stats.totalWords}字` })
            .layoutWeight(1)
        }
        .width('100%')

        AppStatCard({ label: '连续记录', value: `${this.stats.longestStreak}天` })

        Column({ space: Theme.space.s3 }) {
          Text('每周回顾')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.weekSummary.summaryText)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(22)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s3 }) {
          Text('心情分布')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          ForEach(MoodOption.all(), (m: MoodOption) => {
            Row() {
              Text(`${m.tag} ${m.label}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width(88)
              Stack({ alignContent: Alignment.Start }) {
                Row()
                  .width('100%')
                  .height(8)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                Row()
                  .width(`${Math.min(100, this.moodCount(m.key) * 18)}%`)
                  .height(8)
                  .backgroundColor(m.color)
                  .borderRadius(Theme.radius.pill)
              }
              .layoutWeight(1)
              .height(8)
              Text(`${this.moodCount(m.key)}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width(24)
                .textAlign(TextAlign.End)
            }
            .width('100%')
          }, (m: MoodOption) => m.key)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s3 }) {
          Text('关键词云')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.keywords, (k: KeywordItem) => {
              Text(k.word)
                .fontSize(12 + Math.min(k.count, 6) * 2)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .margin({ right: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (k: KeywordItem) => k.word)
          }
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        if (this.onThisDay.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('那年今日')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            ForEach(this.onThisDay, (e: DiaryEntry) => {
              Text(`${e.dateKey} · ${e.previewLine()}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }, (e: DiaryEntry) => e.id)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Auto)
  }

  private moodCount(key: string): number {
    return this.stats.moodCounts.get(key) ?? 0
  }
}
