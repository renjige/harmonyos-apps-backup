import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MessageItem } from '../models/BrochureModels'
import { BrochureBizService } from '../services/BrochureBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = true
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await BrochureBizService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        AppHeader({ title: '消息中心', subtitle: '招生政策与提醒' }).layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知与政策提醒将显示在这里' })
      } else {
        List() {
          ForEach(this.items, (m: MessageItem) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (m: MessageItem) => m.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
