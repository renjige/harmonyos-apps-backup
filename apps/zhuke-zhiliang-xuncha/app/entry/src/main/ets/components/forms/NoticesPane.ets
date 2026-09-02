import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { NoticeItem } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'

@Component
export struct NoticesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('qualityTick') tick: number = 0
  onClose: () => void = () => {}

  private list(): NoticeItem[] {
    const _keep = this.tick
    return QualityService.notices()
  }

  build() {
    Column() {
      Row() {
        Text('通知')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.list().length === 0) {
        AppEmpty({ title: '暂无通知', description: '机构提醒会显示在这里' })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.list(), (n: NoticeItem) => {
              Column({ space: 6 }) {
                Text(n.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(n.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
            }, (n: NoticeItem) => n.id)
          }
          .padding({ left: 20, right: 20, bottom: 24 })
        }
        .layoutWeight(1)
      }

      Column() {
        AppButton({ label: '关闭', variant: 'secondary', onTap: () => this.onClose() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
