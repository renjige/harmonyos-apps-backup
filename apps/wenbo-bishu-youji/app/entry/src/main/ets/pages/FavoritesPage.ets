import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { FavoriteItem } from '../models/EscapeModels'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'
import { EscapeMedia } from '../services/EscapeMedia'
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
    this.items = await EscapeBizService.loadFavorites()
    this.loading = false
  }

  private openItem(f: FavoriteItem): void {
    if (f.kind === 'guide') {
      EscapeDetailNav.openGuide(f.targetId)
      return
    }
    EscapeDetailNav.openDest(f.targetId)
  }

  private kindLabel(f: FavoriteItem): string {
    if (f.kind === 'guide') {
      return '攻略 / 精选'
    }
    return '避暑目的地'
  }

  build() {
    DetailShell({ title: '我的收藏', onClose: () => EscapeDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '打开收藏夹' })
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后才能收藏',
            description: '游客可以先逛目的地与攻略。'
          })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '在详情页把想再去的地方留下来。'
          })
        } else {
          ForEach(this.items, (f: FavoriteItem) => {
            Row({ space: 12 }) {
              if (f.coverKey.length > 0) {
                Image(EscapeMedia.resource(f.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
              }
              Column({ space: 4 }) {
                Text(f.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                  .width('100%')
                Text(this.kindLabel(f))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceGlass)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.openItem(f))
          }, (f: FavoriteItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
