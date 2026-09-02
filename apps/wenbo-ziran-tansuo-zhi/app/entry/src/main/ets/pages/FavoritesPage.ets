import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { FavoriteItem } from '../models/NqModels'
import { NqBizService } from '../services/NqBizService'
import { NqDetailNav } from '../services/NqDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: FavoriteItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    this.items = await NqBizService.loadFavorites()
    this.loading = false
  }

  private openItem(f: FavoriteItem): void {
    if (f.targetKind === 'wiki') {
      NqDetailNav.openWiki(f.targetId)
      return
    }
    if (f.targetKind === 'tip') {
      NqDetailNav.openTip(f.targetId)
      return
    }
    NqDetailNav.openSpot(f.targetId)
  }

  private async remove(f: FavoriteItem): Promise<void> {
    await NqBizService.removeFavorite(f.id)
    await this.reload()
  }

  build() {
    DetailShell({ title: '我的收藏', onClose: () => NqDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '打开收藏' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后可同步收藏',
            description: '游客可以先浏览发现与百科内容。'
          })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '在探索点详情里收藏感兴趣的内容。'
          })
        } else {
          ForEach(this.items, (f: FavoriteItem) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(f.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(f.kindLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              .onClick(() => this.openItem(f))
              Text('移除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .onClick(() => { void this.remove(f) })
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (f: FavoriteItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
