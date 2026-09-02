import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AchievementState, MonthReport } from '../models/VitalityModels'
import { AchievementService, StatsService } from '../services/StatsService'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onTapAchievement: (id: string) => void = () => {}
  @State achievements: AchievementState[] = []
  @State unlockedCount: number = 0
  @State monthReport: MonthReport | undefined = undefined

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await AchievementService.evaluateAndUnlock()
    this.achievements = await AchievementService.allStates()
    this.unlockedCount = 0
    for (const a of this.achievements) {
      if (a.unlocked) {
        this.unlockedCount++
      }
    }
    this.monthReport = await StatsService.lastMonthReport()
  }

  private iconFor(id: string): AppIconName {
    if (id === 'first') {
      return 'check'
    }
    if (id === 'month25') {
      return 'chart'
    }
    return 'ai'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('活力成就')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s2 }) {
          Text(`${this.unlockedCount}`)
            .fontSize(Theme.type.displayS)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(`/ ${this.achievements.length} 已解锁`)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

        if (this.monthReport !== undefined) {
          Column({ space: Theme.space.s2 }) {
            Text('上月活力摘要')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.monthReport.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        GridRow({ columns: 2, gutter: Theme.space.s3 }) {
          ForEach(this.achievements, (a: AchievementState) => {
            GridCol() {
              Column({ space: Theme.space.s2 }) {
                Column() {
                  if (a.unlocked) {
                    AppIcon({
                      name: this.iconFor(a.id),
                      iconSize: Theme.icon.lg,
                      color: Theme.colors().brandPrimary
                    })
                  } else {
                    Text('???')
                      .fontSize(Theme.type.title3)
                      .fontColor(Theme.colors().textTertiary)
                  }
                }
                .width(56)
                .height(56)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(a.unlocked ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)

                Text(a.unlocked ? a.title : '???')
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(a.unlocked ? Theme.colors().textPrimary : Theme.colors().textTertiary)

                Text(a.description)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .textAlign(TextAlign.Center)
                  .maxLines(2)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .alignItems(HorizontalAlign.Center)
              .onClick((): void => { this.onTapAchievement(a.id) })
            }
          }, (a: AchievementState) => a.id)
        }
        .width('100%')

        Row().height(this.bottomInset)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
