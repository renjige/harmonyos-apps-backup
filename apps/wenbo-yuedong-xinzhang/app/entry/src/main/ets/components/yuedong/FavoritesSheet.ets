import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { YdFavoriteRef } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct FavoritesSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: YdFavoriteRef[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await YdLocalStore.loadFavorites()
  }

  build() {
    DetailShell({
      title: '我的收藏',
      onClose: (): void => { YdDetailNav.closeFavorites() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    if (this.items.length === 0) {
      Column({ space: Theme.space.s4 }) {
        Image($r('app.media.empty_favorites'))
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        AppEmpty({
        title: '还没有收藏',
        description: '在任务、篇章或目标详情里点收藏，建立你的个人内容库',
        actionLabel: '去搜索',
          onAction: (): void => { YdDetailNav.openSearch() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
    } else {
      Scroll() {
        Column({ space: Theme.space.s2 }) {
          ForEach(this.items, (f: YdFavoriteRef) => {
            Row({ space: Theme.space.s3 }) {
              Text(f.typeLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
              Text(f.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
                .maxLines(2)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { YdDetailNav.openFromFavorite(f.entityType, f.entityId) })
          }, (f: YdFavoriteRef) => f.id)
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
    }
  }
}
