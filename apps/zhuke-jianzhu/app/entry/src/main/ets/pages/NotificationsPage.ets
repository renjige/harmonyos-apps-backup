import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { UserPrefsService } from '../services/UserPrefsService'
import { AppNotification } from '../models/ZhukeModels'
import { AppEmpty } from '../components/design-system/AppEmpty'

@Component
export struct NotificationsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: AppNotification[] = []
  onBack: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = UserPrefsService.notifications()
  }

  build() {
    Column() {
      AppNavBar({ title: '消息通知', onBack: () => this.onBack() })

      if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '系统通知将在此显示' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (n: AppNotification) => {
              Row() {
                Column({ space: Theme.space.s1 }) {
                  Row() {
                    Text(n.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(n.read ? FontWeight.Normal : FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .layoutWeight(1)
                    if (!n.read) {
                      Circle({ width: 8, height: 8 })
                        .fill(Theme.colors().danger)
                    }
                  }
                  .width('100%')
                  Text(n.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(n.createdAt)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(VerticalAlign.Center)
              .onClick(() => this.onOpenDetail(n.id))
            }, (n: AppNotification) => n.id)

            AppButton({
              label: '全部标为已读',
              variant: 'secondary',
              onTap: () => {
                UserPrefsService.markAllRead()
                this.reload()
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
