import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FormSheetHeader } from '../components/design-system/FormSheetHeader'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { FavoriteRecord } from '../models/JujiaModels'
import { FavoriteService } from '../services/FavoriteService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State filter: string = 'all'
  @State items: FavoriteRecord[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenItem: (fav: FavoriteRecord) => void = (_f: FavoriteRecord) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.items = FavoriteService.list(this.filter)
  }

  build() {
    Column() {
      FormSheetHeader({ title: '我的收藏', onClose: () => this.onClose() })
      Scroll() {
        Row({ space: 8 }) {
          ChoiceChip({ label: '全部', active: this.filter === 'all', onPick: () => { this.filter = 'all'; this.reload() } })
          ChoiceChip({ label: '计划', active: this.filter === 'task', onPick: () => { this.filter = 'task'; this.reload() } })
          ChoiceChip({ label: '物品', active: this.filter === 'item', onPick: () => { this.filter = 'item'; this.reload() } })
          ChoiceChip({ label: '备忘', active: this.filter === 'memo', onPick: () => { this.filter = 'memo'; this.reload() } })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      Scroll() {
        Column({ space: 8 }) {
          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有收藏',
              description: '在计划、物品或备忘详情页点收藏，常用内容会集中在这里。',
              actionLabel: '',
              onAction: () => {}
            })
          } else {
            ForEach(this.items, (fav: FavoriteRecord) => {
              Row({ space: 10 }) {
                AppIcon({ name: 'ai', iconSize: 18, color: Theme.colors().brandPrimary })
                Column({ space: 2 }) {
                  Text(fav.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(fav.targetType)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick(() => this.onOpenItem(fav))
            }, (fav: FavoriteRecord) => fav.id)
          }
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
