import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AchievementBadge } from '../models/LifeGrowthModels'
import { LifeGrowthService } from '../services/LifeGrowthService'
import { LifeHubNav } from '../services/LifeHubNav'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeHubVersion') @Watch('onVer') lifeHubVersion: number = 0
  @StorageLink('diaryDataVersion') @Watch('onVer') diaryDataVersion: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State badges: AchievementBadge[] = []
  @State unlocked: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onVer(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.badges = await LifeGrowthService.loadBadges(this.currentUsername)
    let n = 0
    for (const b of this.badges) {
      if (b.unlocked) {
        n += 1
      }
    }
    this.unlocked = n
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { LifeHubNav.backOrClose() })
        Column({ space: 2 }) {
          Text('成就墙')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`已点亮 ${this.unlocked} / ${this.badges.length}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('徽章来自你真实写下的笺语、心情、打卡与计划，不会预置假进度。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.badges, (b: AchievementBadge) => {
            Row({ space: Theme.space.s3 }) {
              AppIcon({
                name: b.unlocked ? 'ai' : 'empty',
                iconSize: Theme.icon.md,
                color: b.unlocked ? Theme.colors().brandAccent : Theme.colors().textTertiary
              })
              Column({ space: 4 }) {
                Text(b.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(b.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                Text(b.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                Text(b.detail)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .opacity(b.unlocked ? 1 : 0.72)
          }, (b: AchievementBadge) => `${b.id}_${b.unlocked}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
