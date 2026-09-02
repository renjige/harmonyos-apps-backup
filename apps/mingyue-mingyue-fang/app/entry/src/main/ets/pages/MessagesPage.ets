import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MessageItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = true
  @State refreshing: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.refreshing = true
    if (this.items.length === 0) {
      this.loading = true
    }
    this.items = await ReadingBizService.loadMessages()
    this.loading = false
    this.refreshing = false
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
        Text('消息中心')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
        if (this.loading) {
          AppLoading({ label: '读取通知…' }).layoutWeight(1)
        } else if (this.items.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无机构通知',
              description: '阅读提醒与活动通知将显示在这里',
              actionLabel: '刷新',
              onAction: (): void => { void this.reload() }
            })
          }
          .layoutWeight(1)
        } else {
          List() {
            ForEach(this.items, (m: MessageItem) => {
              ListItem() {
                AppCard({ title: m.title }) {
                  Text(m.body)
                    .fontSize(Theme.type.callout)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  if (m.createdAt.length > 0) {
                    Text(m.createdAt.slice(0, 10))
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .margin({ top: 8 })
                      .width('100%')
                  }
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
        }
      }
      .layoutWeight(1)
      .onRefreshing((): void => { void this.reload() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
