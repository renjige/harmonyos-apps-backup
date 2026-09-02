import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { MonthMoodCell, MoodStatItem } from '../models/JianModels'
import { DateHelper } from '../services/DateHelper'
import { JianStatsService } from '../services/JianStatsService'
import { MoodCatalog } from '../services/MoodCatalog'

@Component
export struct MoodPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cells: MonthMoodCell[] = []
  @State moodStats: MoodStatItem[] = []
  @State streak: number = 0
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const now = new Date()
    this.cells = await JianStatsService.monthHeatmap(now.getFullYear(), now.getMonth() + 1)
    this.moodStats = await JianStatsService.moodDistribution()
    const ov = await JianStatsService.overview()
    this.streak = ov.streakDays
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('心情统计')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

        Row({ space: Theme.space.s4 }) {
          Column({ space: 4 }) {
            Text(`${this.streak}`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('连续记录天')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: 4 }) {
            Text(`${this.cells.filter((c: MonthMoodCell) => c.hasEntry).length}`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandAccent)
            Text('本月有笺天')
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
          Text(DateHelper.monthLabel(new Date().getFullYear(), new Date().getMonth() + 1))
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.cells, (cell: MonthMoodCell) => {
              Column() {
                Text(cell.dateKey.split('-')[2])
                  .fontSize(10)
                  .fontColor(cell.hasEntry ? Theme.colors().textPrimary : Theme.colors().textTertiary)
              }
              .width(36)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .margin({ right: 6, bottom: 6 })
              .backgroundColor(cell.hasEntry ?
                MoodCatalog.colorOf(cell.moodId) : Theme.colors().surfaceSubtle)
              .opacity(cell.hasEntry ? 0.55 : 0.35)
              .borderRadius(8)
            }, (cell: MonthMoodCell) => cell.dateKey)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s3 }) {
          Text('心情分布')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          if (this.moodStats.length === 0) {
            Text('写更多笺页并选择心情后，这里会呈现分布')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else {
            ForEach(this.moodStats, (item: MoodStatItem) => {
              Row({ space: Theme.space.s3 }) {
                Text(MoodCatalog.emojiOf(item.moodId))
                  .fontSize(16)
                Text(item.label)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width(48)
                Stack({ alignContent: Alignment.Start }) {
                  Row()
                    .width('100%')
                    .height(10)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                  Row()
                    .width(`${Math.min(item.count * 18, 100)}%`)
                    .height(10)
                    .backgroundColor(item.color)
                    .borderRadius(Theme.radius.pill)
                }
                .layoutWeight(1)
                .height(10)
                Text(`${item.count}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
            }, (item: MoodStatItem) => item.moodId)
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        AppButton({
          label: '刷新统计',
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
