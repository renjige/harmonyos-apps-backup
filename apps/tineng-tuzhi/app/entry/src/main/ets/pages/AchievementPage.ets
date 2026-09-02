import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AchievementState, PersonalBest } from '../models/WorkoutModels'
import { AchievementService } from '../services/AchievementService'
import { StatsService } from '../services/StatsService'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State achievements: AchievementState[] = []
  @State unlockedCount: number = 0
  @State streak: number = 0
  @State bests: PersonalBest[] = []

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
    const totals = await StatsService.totals()
    this.streak = totals.streakDays
    this.bests = await StatsService.personalBests()
  }

  private iconFor(id: string): AppIconName {
    if (id === 'month25' || id === 'hours100' || id === 'streak7' || id === 'streak30') {
      return 'chart'
    }
    if (id === 'distance50') {
      return 'biz'
    }
    return 'check'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('运动成就')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s4 }) {
          Column({ space: 4 }) {
            Text(`${this.streak}`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text('连续运动天数')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column({ space: 4 }) {
            Text(`${this.unlockedCount}`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().success)
            Text(`/ ${this.achievements.length} 徽章已解锁`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

        Column({ space: Theme.space.s3 }) {
          Text('个人最佳')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.bests, (pb: PersonalBest) => {
            Row() {
              Text(pb.label)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text(`${pb.value} ${pb.unit}`)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
          }, (pb: PersonalBest) => pb.key)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

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
