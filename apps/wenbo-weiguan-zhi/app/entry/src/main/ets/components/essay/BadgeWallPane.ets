import { Theme } from '../design-system/Theme'
import { ObserveBadge } from '../../models/GrowthModels'
import { GrowthStore } from '../../services/GrowthStore'

@Component
export struct BadgeWallPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}

  @State badges: ObserveBadge[] = []
  @State unlockedCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const list = await GrowthStore.loadBadges()
    this.badges = list
    let n = 0
    for (const b of list) {
      if (b.unlocked()) {
        n++
      }
    }
    this.unlockedCount = n
  }

  build() {
    Column() {
      Row() {
        Text('观察徽章')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Text(`已点亮 ${this.unlockedCount} / ${this.badges.length}。条件全部来自你自己的观察，没有假进度。`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.badges, (item: ObserveBadge) => {
            Column({ space: 4 }) {
              Text(item.unlocked() ? `已点亮 · ${item.title}` : item.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(item.unlocked() ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(item.hint)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: item.unlocked() ? 1 : 0, color: '#C9A96E' })
          }, (item: ObserveBadge) => item.id)
          Blank().height(Theme.space.s8)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(40)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
