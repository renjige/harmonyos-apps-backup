import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { HttpClient } from '../services/HttpClient'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CsMsgListPayload, CsMsgWire } from '../models/CommonSenseToolModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: CsMsgWire[] = []
  @State loading: boolean = false
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    const res = await HttpClient.get<CsMsgListPayload>('/messages')
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
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('消息中心')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      if (this.loadFailed) {
        AppError({
          message: '消息加载失败',
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        })
      } else if (this.items.length === 0 && !this.loading) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里' })
      } else {
        List() {
          ForEach(this.items, (m: CsMsgWire) => {
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
          }, (m: CsMsgWire) => m.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
