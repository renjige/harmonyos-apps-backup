import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AtlasCatalog, AtlasItem } from '../data/AtlasCatalog'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { SymbolCover } from '../components/design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { LayoutConstants } from '../components/design-system/LayoutConstants'

class CatFilter {
  key: string = 'all'
  label: string = '全部'
}

@Component
export struct AtlasPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('progressRev') @Watch('onRev') progressRev: number = 0
  @State source: string = 'official'
  @State filter: string = 'all'
  @State items: AtlasItem[] = []
  private filters: CatFilter[] = AtlasPage.buildFilters()

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private static buildFilters(): CatFilter[] {
    const list: CatFilter[] = []
    const all = new CatFilter()
    all.key = 'all'
    all.label = '全部'
    list.push(all)
    const defs: string[][] = [
      ['nature', '自然'], ['life', '生活'], ['science', '科学'], ['culture', '人文'], ['fun', '趣味']
    ]
    for (const d of defs) {
      const c = new CatFilter()
      c.key = d[0]
      c.label = d[1]
      list.push(c)
    }
    return list
  }

  private reload(): void {
    if (this.source === 'mine') {
      const mine = ExplorationStore.myKnownAtlasItems()
      if (this.filter === 'all') {
        this.items = mine
      } else {
        const filtered: AtlasItem[] = []
        for (const item of mine) {
          if (item.category === this.filter) filtered.push(item)
        }
        this.items = filtered
      }
      return
    }
    if (this.filter === 'all') {
      this.items = AtlasCatalog.all()
    } else {
      this.items = AtlasCatalog.byCategory(this.filter)
    }
  }

  private statusLabel(id: string): string {
    const note = ExplorationStore.getAtlasNote(id)
    if (note.status === 'known') return '已了解'
    if (note.status === 'exploring') return '待观察'
    if (ExplorationStore.isFavoriteAtlas(id)) return '已收藏'
    return ''
  }

  private headerTitle(): string {
    return this.source === 'mine' ? '我的图鉴' : '官方图鉴'
  }

  private headerSubtitle(): string {
    if (this.source === 'mine') {
      return `已了解 ${ExplorationStore.myKnownAtlasItems().length} 项`
    }
    return `${AtlasCatalog.all().length} 则身边事物`
  }

  build() {
    Column() {
      AppHeader({ title: this.headerTitle(), subtitle: this.headerSubtitle() })
      Row({ space: Theme.space.s2 }) {
        this.SourceTab('official', '官方图鉴')
        this.SourceTab('mine', '我的图鉴')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.filters, (f: CatFilter) => {
            Text(f.label)
              .fontSize(Theme.type.footnote)
              .fontColor(this.filter === f.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.filter === f.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.filter = f.key
                this.reload()
              })
          }, (f: CatFilter) => f.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.items.length === 0) {
        AppEmpty({
          title: this.source === 'mine' ? '我的图鉴还是空白' : '暂无条目',
          description: this.source === 'mine' ?
            '浏览官方图鉴并标记「已了解」，或新建探索记录' :
            '切换分类试试',
          actionLabel: this.source === 'mine' ? '开始探索' : '',
          onAction: (): void => {
            if (this.source === 'mine') {
              this.source = 'official'
              this.reload()
            }
          }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: AtlasItem) => {
              Row({ space: Theme.space.s4 }) {
                SymbolCover({
                  category: item.category,
                  coverKey: item.id,
                  tileSize: 80,
                  cornerRadius: Theme.radius.xl
                })
                Column({ space: 4 }) {
                  Row() {
                    Text(item.name)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                      .layoutWeight(1)
                    if (this.statusLabel(item.id).length > 0) {
                      Text(this.statusLabel(item.id))
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandAccent)
                    }
                  }
                  .width('100%')
                  Text(CategoryEmojiUtil.chipLabel(item.category))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { ExploreNav.openAtlasDetail(item.id) })
            }, (item: AtlasItem) => `${item.id}_${this.statusLabel(item.id)}_${this.progressRev}`)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10 + LayoutConstants.tabBarInset()
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  SourceTab(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.source === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.source === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => {
        this.source = key
        this.filter = 'all'
        this.reload()
      })
  }
}
