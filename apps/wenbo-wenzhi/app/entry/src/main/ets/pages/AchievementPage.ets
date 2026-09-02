import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AchievementItem } from '../models/GrowthModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @State items: AchievementItem[] = []
  @State unlocked: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    GrowthStore.evaluateAchievements()
    this.items = GrowthStore.achievementAll()
    this.unlocked = GrowthStore.achievementUnlockedCount()
  }

  build() {
    Column() {
      AppNavBar({ title: '成就墙', onBack: (): void => { AskNav.closeLearn() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(`已解锁 ${this.unlocked} / ${this.items.length}`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.items, (a: AchievementItem) => {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(a.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(a.unlocked ?
                    Theme.colors().textPrimary : Theme.colors().textTertiary)
                Text(a.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text(a.unlocked ? '已达成' : '未解锁')
                .fontSize(Theme.type.caption)
                .fontColor(a.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .opacity(a.unlocked ? 1 : 0.72)
          }, (a: AchievementItem) => a.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
