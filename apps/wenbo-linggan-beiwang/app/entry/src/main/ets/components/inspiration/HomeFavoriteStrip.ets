import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { InspirationItem } from '../../models/InspirationModels'
import { InspirationMedia } from '../../services/InspirationMedia'
import { FavoriteSync } from '../../services/FavoriteSync'
import { AuthService } from '../../services/AuthService'

@Component
export struct HomeFavoriteStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: InspirationItem[] = []
  onOpenAll: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onOpenItem: (item: InspirationItem) => void = (_i: InspirationItem) => {}
  onUnfavorite: (id: string) => void = (_id: string) => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('收藏内容')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        if (this.items.length > 0) {
          Text('查看全部')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { this.onOpenAll() })
        }
      }
      .width('100%')

      if (this.items.length === 0) {
        AppEmpty({
          title: AuthService.isLoggedIn() ? '暂无收藏' : '登录后查看收藏',
          description: '在详情页收藏或取消，空间这里会立刻更新',
          actionLabel: AuthService.isLoggedIn() ? '' : '去登录',
          onAction: (): void => { this.onRequireAuth() }
        })
      } else {
        Scroll() {
          Row({ space: Theme.space.s3 }) {
            ForEach(this.items.slice(0, 6), (item: InspirationItem) => {
              Column({ space: 8 }) {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(InspirationMedia.coverMedia(item.coverKey))
                    .width(120)
                    .height(88)
                    .borderRadius(Theme.radius.lg)
                    .objectFit(ImageFit.Cover)
                    .onClick((): void => { this.onOpenItem(item) })
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textOnInverse })
                  }
                  .width(28)
                  .height(28)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('rgba(51,65,85,0.72)')
                  .borderRadius(Theme.radius.pill)
                  .margin({ top: 4, right: 4 })
                  .onClick((): void => { this.onUnfavorite(item.id) })
                }
                .width(120)
                Text(item.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(2)
                  .width(120)
                Text(FavoriteSync.parseSourceKey(item.content).length > 0 ? '已关联内容' : '文字收藏')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width(120)
              }
            }, (item: InspirationItem) => item.id)
          }
          .padding({ right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
    .width('100%')
  }
}
