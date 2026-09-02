import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { FavoriteEntry, ShoppingList, ShoppingMemoNote } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingLocalStore } from '../../services/ShoppingLocalStore'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct FavoritesOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State favorites: FavoriteEntry[] = []
  @State starred: ShoppingList[] = []
  @State memos: ShoppingMemoNote[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onOpenItem: (itemId: string, listId: string) => void = () => {}
  onOpenMemo: (id: string) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.favorites = GrowthService.favorites()
    this.starred = ShoppingService.starredLists()
    this.memos = GrowthService.starredMemos()
  }

  private itemFavorites(): FavoriteEntry[] {
    const out: FavoriteEntry[] = []
    for (const fav of this.favorites) {
      if (fav.refType === 'item' || fav.refType === 'list') {
        out.push(fav)
      }
    }
    return out
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('收藏中心')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 16 }) {
          if (this.starred.length > 0) {
            Text('清单方案')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.starred, (row: ShoppingList) => {
              this.RowItem(row.title, row.kind, (): void => { this.onOpenList(row.id) })
            }, (row: ShoppingList) => `star_${row.id}`)
          }

          if (this.itemFavorites().length > 0) {
            Text('常购物品与方案')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.itemFavorites(), (fav: FavoriteEntry) => {
              this.RowItem(fav.title, fav.subtitle, (): void => {
                if (fav.refType === 'list') {
                  this.onOpenList(fav.refId)
                  return
                }
                for (const it of ShoppingLocalStore.items()) {
                  if (it.id === fav.refId) {
                    this.onOpenItem(it.id, it.listId)
                    return
                  }
                }
              })
            }, (fav: FavoriteEntry) => `${fav.refType}_${fav.refId}`)
          }

          if (this.memos.length > 0) {
            Text('备忘要点')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.memos, (memo: ShoppingMemoNote) => {
              this.RowItem(memo.title, '重要备忘', (): void => { this.onOpenMemo(memo.id) })
            }, (memo: ShoppingMemoNote) => memo.id)
          }

          if (this.starred.length === 0 && this.favorites.length === 0 && this.memos.length === 0) {
            AppEmpty({
              title: '还没有收藏',
              description: '收藏清单、物品或标记重要备忘，会按分组显示在这里'
            })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }

  @Builder
  RowItem(title: string, sub: string, action: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => action())
  }
}
