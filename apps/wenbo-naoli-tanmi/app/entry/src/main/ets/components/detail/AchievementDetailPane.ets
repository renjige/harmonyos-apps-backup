import { Theme } from '../design-system/Theme'
import { DetailShell } from './DetailShell'
import { BrainMedia } from '../../services/BrainMedia'
import { BrainNav } from '../../services/BrainNav'
import { BrainBizService } from '../../services/BrainBizService'
import { BrainProgress } from '../../services/BrainProgress'
import { AchieveItem } from '../../models/BrainModels'
import { AppEmpty } from '../design-system/AppEmpty'

@Component
export struct AchievementDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('brainEntityId') entityId: string = ''
  @State item: AchieveItem = new AchieveItem()
  @State ready: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await BrainBizService.resolveAchieve(this.entityId)
    if (row !== undefined) {
      this.item = row
    }
    this.ready = true
  }

  build() {
    Column() {
      DetailShell({ title: '成就', onBack: () => BrainNav.close() })
      if (!this.ready) {
        Text('加载中').fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).padding(20)
      } else if (this.item.id.length === 0) {
        AppEmpty({ title: '未找到成就', description: '请返回重试', actionLabel: '返回', onAction: () => BrainNav.close() })
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Image(BrainMedia.cover(this.item.coverKey))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Text(this.item.title)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding({ left: 16, right: 16 })
            Text(this.item.subtitle)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ left: 16, right: 16 })
            Column({ space: 6 }) {
              Text(BrainProgress.hasBadge(this.item.id) ? '已点亮' : '尚未点亮')
                .fontSize(14)
                .fontColor(Theme.colors().brandAccent)
              Text(this.item.summary)
                .fontSize(16)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            Text(this.item.body)
              .fontSize(16)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
              .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
            Text('去训练')
              .width('90%')
              .height(48)
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontColor(Theme.colors().brandOnPrimary)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(14)
              .onClick(() => {
                BrainNav.close()
                AppStorage.setOrCreate('mainTab', 0)
              })
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
