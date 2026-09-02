import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { FavoriteItem } from '../models/SolarModels'
import { SolarRecipesBizService } from '../services/SolarRecipesBizService'
import { SolarDetailNav } from '../services/SolarDetailNav'
import { SolarMedia } from '../services/SolarMedia'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: FavoriteItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await SolarRecipesBizService.loadFavorites()
    this.loading = false
  }

  build() {
    DetailShell({
      title: '我的收藏',
      contentKey: `${this.items.length}`,
      onClose: () => SolarDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.loading) {
          AppLoading({ label: '正在打开收藏' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '登录后在食谱详情里收藏喜欢的菜',
            emojiMark: '⭐',
            iconName: 'bookmark',
            actionLabel: '去食谱库',
            onAction: (): void => {
              SolarDetailNav.close()
              AppStorage.setOrCreate('switchTabIndex', 1)
            }
          })
        } else {
          ForEach(this.items, (f: FavoriteItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(SolarMedia.resource(f.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(f.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .width('100%')
                Text('🍲 已收藏食谱')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => SolarDetailNav.openRecipe(f.targetId))
          }, (f: FavoriteItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
