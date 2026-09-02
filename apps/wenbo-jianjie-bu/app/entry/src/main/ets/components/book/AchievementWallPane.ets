import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AchievementDef } from '../../models/GrowthModels'
import { GrowthStore } from '../../services/GrowthStore'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct AchievementWallPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State unlocked: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.unlocked = await GrowthStore.unlockedIds()
  }

  private isUnlocked(id: string): boolean {
    for (const x of this.unlocked) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  build() {
    Column() {
      DetailShell({ title: '成就墙', onClose: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text(`已解锁 ${this.unlocked.length} / ${AchievementDef.all().length}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(AchievementDef.all(), (d: AchievementDef) => {
            Row({ space: 12 }) {
              Column() {
                AppIcon({
                  name: this.isUnlocked(d.id) ? 'sparkle' : 'empty',
                  iconSize: Theme.icon.lg,
                  color: this.isUnlocked(d.id) ? Theme.colors().brandPrimary : Theme.colors().textSecondary
                })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              Column({ space: 4 }) {
                Text(d.name)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isUnlocked(d.id) ?
                    Theme.colors().textPrimary : Theme.colors().textSecondary)
                Text(d.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (d: AchievementDef) => d.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
