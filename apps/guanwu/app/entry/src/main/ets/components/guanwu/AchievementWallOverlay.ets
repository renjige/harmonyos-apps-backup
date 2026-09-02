import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AchievementItem } from '../../models/ActivityModels'

@Component
export struct AchievementWallOverlay {
  @Prop items: AchievementItem[] = []
  onClose: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('成就墙')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (a: AchievementItem) => {
            Column({ space: 6 }) {
              Row() {
                Text(a.unlocked ? '已解锁' : '进行中')
                  .fontSize(Theme.type.caption)
                  .fontColor(a.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(a.unlocked ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              Text(a.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(a.description)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Progress({ value: a.progress, total: a.target, type: ProgressType.Linear })
                .width('100%')
                .color(Theme.colors().brandPrimary)
              Text(`${a.progress}/${a.target}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (a: AchievementItem) => a.id)
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
