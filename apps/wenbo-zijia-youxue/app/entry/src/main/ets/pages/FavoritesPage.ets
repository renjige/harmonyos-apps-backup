import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { RecordItem } from '../models/RoadModels'
import { AuthService } from '../services/AuthService'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State items: RecordItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.items = await RoadBizService.loadFavorites()
    } else {
      this.items = []
    }
    this.loading = false
  }

  private openItem(item: RecordItem): void {
    if (item.targetKind === 'spot') {
      RoadDetailNav.openSpot(item.targetId)
      return
    }
    RoadDetailNav.openRoute(item.targetId)
  }

  build() {
    DetailShell({ title: '我的收藏', contentKey: `${this.refreshToken}`, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取收藏' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看收藏',
            description: '游客可以先逛路线，收藏需要账号',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '在路线详情里把想再走的留下来',
            actionLabel: '去发现',
            onAction: (): void => { RoadDetailNav.close() }
          })
        } else {
          ForEach(this.items, (item: RecordItem) => {
            Row() {
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(item.targetKind === 'spot' ? '景点' : '路线')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .height(64)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .onClick(() => this.openItem(item))
          }, (item: RecordItem) => item.id)
        }
      }
      .width('100%')
    }
  }
}
