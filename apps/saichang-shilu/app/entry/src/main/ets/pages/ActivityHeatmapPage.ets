import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { HeatDay, StreakInfo } from '../models/SportExtra'
import { AnalyticsService } from '../services/AnalyticsService'

@Component
export struct ActivityHeatmapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State heat: HeatDay[] = []
  @State streak: StreakInfo = new StreakInfo()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.heat = await AnalyticsService.activityHeat()
    this.streak = await AnalyticsService.streak()
  }

  private cellColor(count: number): string {
    if (count >= 3) {
      return Theme.colors().brandPrimary
    }
    if (count === 2) {
      return 'rgba(11,107,203,0.72)'
    }
    if (count === 1) {
      return 'rgba(11,107,203,0.38)'
    }
    return Theme.colors().surfaceSubtle
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('活跃热力图')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.streak.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.lg)

            Text('近 90 天记录密度（赛事 + 瞬间 + 笔记）')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.heat, (h: HeatDay) => {
                Column()
                  .width(14)
                  .height(14)
                  .margin({ right: 3, bottom: 3 })
                  .backgroundColor(this.cellColor(h.count))
                  .borderRadius(3)
              }, (h: HeatDay) => h.dateKey)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.LegendDot('无', Theme.colors().surfaceSubtle)
              this.LegendDot('1', 'rgba(11,107,203,0.38)')
              this.LegendDot('2', 'rgba(11,107,203,0.72)')
              this.LegendDot('3+', Theme.colors().brandPrimary)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('连续记录激励')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`当前连续 ${this.streak.currentWeeks} 周有记录 · 历史最长 ${this.streak.longestWeeks} 周`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text('每周至少记录 1 条赛事或瞬间，保持你的观赛记忆不断档。')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  LegendDot(label: string, color: string) {
    Row({ space: 4 }) {
      Column()
        .width(12)
        .height(12)
        .backgroundColor(color)
        .borderRadius(2)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
  }
}
