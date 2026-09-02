import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { FavoriteItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'
import { DrinkMedia } from '../services/DrinkMedia'

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
    this.items = await DrinkBizService.loadFavorites()
    this.loading = false
  }

  build() {
    DetailShell({
      title: '我的收藏',
      contentKey: `${this.items.length}`,
      onClose: () => DrinkDetailNav.close()
    }) {
      Column() {
        if (this.loading) {
          AppLoading({ label: '正在打开收藏' })
        } else if (this.items.length === 0) {
          AppEmpty({ title: '还没有收藏', description: '登录后在详情里收藏喜欢的杯子' })
        } else {
          ForEach(this.items, (f: FavoriteItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(DrinkMedia.resource(f.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Text(f.title)
                .fontSize(Theme.type.subtitleS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => DrinkDetailNav.openDrink(f.targetId))
          }, (f: FavoriteItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
