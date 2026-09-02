import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { UserPrefsService } from '../services/UserPrefsService'
import { AppNotification } from '../models/ZhukeModels'

@Component
export struct NotificationDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop notificationId: string = ''
  @State item: AppNotification = new AppNotification()
  onBack: () => void = () => {}

  aboutToAppear(): void {
    const found = UserPrefsService.notificationById(this.notificationId)
    if (found !== null) {
      this.item = found
      UserPrefsService.markRead(found.id)
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '消息详情', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Text(this.item.createdAt)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          AppCard({ title: '通知内容' }) {
            Text(this.item.fullBody.length > 0 ? this.item.fullBody : this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(26)
          }
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
