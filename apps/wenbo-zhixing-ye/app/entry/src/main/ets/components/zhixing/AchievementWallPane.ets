import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppIcon } from '../design-system/AppIcon'
import { AchievementItem } from '../../models/ZhixingModels'
import { AchievementService } from '../../services/AchievementService'

@Component
export struct AchievementWallPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State items: AchievementItem[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await AchievementService.listWithProgress()
  }

  build() {
    Column() {
      AppNavBar({ title: '成就墙', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.items, (a: AchievementItem) => {
            Row({ space: 12 }) {
              Column() {
                AppIcon({
                  name: a.unlocked ? 'check' : 'empty',
                  iconSize: 22,
                  color: a.unlocked ? Theme.colors().brandAccent : Theme.colors().textTertiary
                })
              }
              .width(40)
              .justifyContent(FlexAlign.Center)
              Column({ space: 4 }) {
                Text(a.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(a.desc)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Progress({
                  value: a.progress > a.target ? a.target : a.progress,
                  total: a.target,
                  type: ProgressType.Linear
                })
                  .width('100%')
                  .color(Theme.colors().brandPrimary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (a: AchievementItem) => a.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
