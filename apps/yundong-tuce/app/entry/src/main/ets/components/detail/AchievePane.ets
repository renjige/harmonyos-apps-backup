import { Theme } from '../design-system/Theme'
import { AchieveItem } from '../../models/TuceModels'
import { TuceEngine } from '../../services/TuceEngine'

@Component
export struct AchievePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: AchieveItem[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await TuceEngine.achievements()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text('成就按你的真实打卡与收藏解锁，新用户为空。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        ForEach(this.items, (it: AchieveItem) => {
          Row() {
            Text(it.title)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(it.unlocked ? '已点亮' : '未解锁')
              .fontSize(Theme.type.caption)
              .fontColor(it.unlocked ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (it: AchieveItem) => it.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
