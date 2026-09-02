import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { MsgListPayload, MsgWire } from '../models/WisdomHallModels'
import { HttpClient } from '../services/HttpClient'
import { WisdomHallNav } from '../services/WisdomHallNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgWire[] = []
  @State loading: boolean = false
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      this.items = res.data.list
    } else {
      this.items = []
      this.loadFailed = true
    }
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { WisdomHallNav.closeMessages() })
        Column({ space: 2 }) {
          Text('消息中心')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('机构通知与活动提醒')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Refresh({ refreshing: this.loading, offset: 64, friction: 100 }) {
        if (this.loadFailed) {
          AppError({
            message: '消息加载失败',
            retryLabel: '重试',
            onRetry: (): void => { void this.reload() }
          })
            .layoutWeight(1)
        } else if (this.items.length === 0 && !this.loading) {
          AppEmpty({
            title: '暂无消息',
            description: '机构通知将显示在这里'
          })
            .layoutWeight(1)
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.items, (m: MsgWire) => {
              ListItem() {
                AppCard({ title: m.title }) {
                  Text(m.body)
                    .fontSize(Theme.type.callout)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .lineHeight(22)
                }
              }
            }, (m: MsgWire) => m.id)
          }
          .layoutWeight(1)
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
          .edgeEffect(EdgeEffect.Spring)
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
