import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { TreasureEmpty } from '../components/treasure/TreasureEmpty'
import { TreasureListCard } from '../components/treasure/TreasureListCard'
import { CategoryItem, TreasureItem } from '../models/TreasureModels'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct ArchivePage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('treasureDomainKey') @Watch('onDomainJump') domainKey: string = ''
  @State items: TreasureItem[] = []
  @State categories: CategoryItem[] = []
  @State filterId: string = ''
  @State listFilter: string = '全部'
  @State domainBanner: string = ''
  @State activeDomain: string = ''

  aboutToAppear(): void {
    this.consumePendingDomain()
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  onDomainJump(): void {
    this.consumePendingDomain()
  }

  private consumePendingDomain(): void {
    if (this.domainKey.length === 0) {
      return
    }
    this.activeDomain = this.domainKey
    AppStorage.setOrCreate('treasureDomainKey', '')
    this.applyDomainBanner()
    this.applyFilter()
  }

  private applyDomainBanner(): void {
    for (const d of TreasureStore.domainBuckets()) {
      if (d.key === this.activeDomain) {
        this.domainBanner = d.label
        return
      }
    }
    this.domainBanner = ''
  }

  private reload(): void {
    this.categories = TreasureStore.categories()
    if (this.activeDomain.length > 0) {
      this.applyDomainBanner()
    }
    this.applyFilter()
  }

  private applyFilter(): void {
    let base: TreasureItem[] = []
    if (this.activeDomain.length > 0) {
      base = TreasureStore.itemsByDomain(this.activeDomain)
    } else {
      base = TreasureStore.filteredItems(this.filterId)
    }
    if (this.filterId.length > 0 && this.activeDomain.length > 0) {
      const filtered: TreasureItem[] = []
      for (const item of base) {
        if (item.categoryId === this.filterId) {
          filtered.push(item)
        }
      }
      base = filtered
    }
    if (this.listFilter !== '全部') {
      const next: TreasureItem[] = []
      for (const item of base) {
        if (item.listStatus === this.listFilter || item.archiveStatus === this.listFilter) {
          next.push(item)
        }
      }
      base = next
    }
    this.items = base
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('珍藏档案').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).layoutWeight(1)
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => TreasureNav.openSearch())
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .borderRadius(Theme.radius.pill)
        .backgroundColor(Theme.colors().brandPrimary)
        .justifyContent(FlexAlign.Center)
        .onClick(() => TreasureNav.openEditor(''))
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.domainBanner.length > 0) {
        Text(`收藏领域 · ${this.domainBanner}`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: Theme.space.pageX })
      }

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(['全部', '待整理', '已完成', '重点珍藏', '想寻找'], (f: string) => {
            Text(f)
              .fontSize(Theme.type.caption)
              .fontColor(this.listFilter === f ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.listFilter === f ? Theme.colors().brandDeep : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.listFilter = f; this.applyFilter() })
          }, (f: string) => f)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.CatChip('全部', '')
          ForEach(this.categories, (c: CategoryItem) => { this.CatChip(c.name, c.id) }, (c: CategoryItem) => c.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      if (this.items.length === 0) {
        TreasureEmpty({ onAction: (): void => { TreasureNav.openEditor('') } }).layoutWeight(1)
      } else {
        Scroll() {
          GridRow({ columns: 2, gutter: Theme.space.s3 }) {
            ForEach(this.items, (item: TreasureItem) => {
              GridCol({ span: 1 }) {
                TreasureListCard({ item: item, onTap: (): void => { TreasureNav.openDetail(item.id) } })
              }
            }, (item: TreasureItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  CatChip(label: string, id: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterId === id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filterId === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.filterId = id; this.applyFilter() })
  }
}
