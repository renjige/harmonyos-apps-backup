import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppCard } from '../components/design-system/AppCard'
import { MessageRow, MessagesService } from '../services/MessagesService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop asOverlay: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onClose: () => void = () => {}
  @State items: MessageRow[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await MessagesService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      if (this.asOverlay) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('返回')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
      }
      AppHeader({ title: '机构通知', subtitle: '计划提醒 · 创作鼓励 · 成长提示' })
      if (this.loading) {
        AppLoading({ label: '加载通知…' }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无通知',
          description: '机构广播与功能提醒将显示在这里'
        }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (m: MessageRow) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (m: MessageRow) => m.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
