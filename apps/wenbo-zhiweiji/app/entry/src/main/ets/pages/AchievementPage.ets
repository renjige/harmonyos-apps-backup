import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AchievementItem } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct AchievementPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State items: AchievementItem[] = []
  @State unlocked: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ZhiweiStore.achievements()
    let u = 0
    for (const a of this.items) {
      if (a.unlocked) {
        u += 1
      }
    }
    this.unlocked = u
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeAchievement())
        Text('成就墙')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text(`已解锁 ${this.unlocked} / ${this.items.length}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (a: AchievementItem) => {
            Row({ space: 12 }) {
              Column() {
                Text(a.unlocked ? '🏅' : '🔒')
                  .fontSize(22)
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              Column({ space: 4 }) {
                Text(a.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(a.unlocked ?
                    Theme.colorOf(this.themeEpoch).textPrimary : Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                Text(a.desc)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
                if (a.unlocked && a.unlockedAt > 0) {
                  Text(`解锁于 ${ZhiweiStore.displayTime(a.unlockedAt)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                    .width('100%')
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .opacity(a.unlocked ? 1 : 0.72)
          }, (a: AchievementItem) => a.id)
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
