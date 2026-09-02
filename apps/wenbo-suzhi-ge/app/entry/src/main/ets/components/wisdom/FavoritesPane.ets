import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { WisdomItem } from '../../models/WisdomHallModels'
import { SuzhiLocalStore } from '../../services/SuzhiLocalStore'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct FavoritesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('whRefresh') @Watch('onRefresh') whRefresh: number = 0
  @State items: WisdomItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await SuzhiLocalStore.loadFavorites()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { WisdomHallNav.closeFavorites() })
        Text('我的收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      if (this.items.length === 0) {
        AppEmpty({ title: '还没有收藏', description: '在智慧阁或文萃详情中可收藏内容' })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: WisdomItem) => {
            ListItem() {
              Row() {
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => {
                const kind = item.targetKind.length > 0 ? item.targetKind : 'read'
                WisdomHallNav.openDetail(kind, item.targetId)
              })
            }
          }, (item: WisdomItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
