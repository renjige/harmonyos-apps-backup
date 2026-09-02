import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AppEmpty } from '../design-system/AppEmpty'
import { EntryListCard } from './EntryListCard'
import { InsightEntry } from '../../models/InsightModels'
import { WorkbenchService } from '../../services/WorkbenchService'

@Component
export struct FavoritesHubPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  @State items: InsightEntry[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await WorkbenchService.favoritesBundle()
    this.loaded = true
  }

  build() {
    Column() {
      DetailShell({ title: '收藏中心', onClose: (): void => { this.onClose() } })
      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '还没有收藏',
          description: '星标、置顶、金句与待验收判断会集中在这里',
          actionLabel: '',
          onAction: (): void => {}
        })
          .layoutWeight(1)
      } else {
        List({ space: 10 }) {
          ForEach(this.items, (n: InsightEntry) => {
            ListItem() {
              EntryListCard({
                item: n,
                highlight: '',
                starredFlag: n.starred,
                stamp: n.updatedAt,
                onOpen: (): void => { this.onOpen(n.id) }
              })
            }
          }, (n: InsightEntry) => `fav_${n.id}_${n.updatedAt}`)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
