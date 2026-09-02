import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AtlasCatalog, AtlasItem } from '../data/AtlasCatalog'
import { UserDiscovery } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { DetailShell } from '../components/detail/DetailShell'

class SearchHit {
  kind: string = ''
  id: string = ''
  title: string = ''
  subtitle: string = ''
}

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State keyword: string = ''
  @State hits: SearchHit[] = []
  @State history: string[] = []

  aboutToAppear(): void {
    this.history = ExplorationStore.searchHistory()
  }

  private runSearch(): void {
    const key = this.keyword.trim()
    const list: SearchHit[] = []
    if (key.length === 0) {
      this.hits = list
      return
    }
    for (const item of AtlasCatalog.search(key)) {
      const h = new SearchHit()
      h.kind = 'atlas'
      h.id = item.id
      h.title = item.name
      h.subtitle = item.categoryLabel
      list.push(h)
    }
    for (const d of ExplorationStore.snapshot().discoveries) {
      if (d.title.includes(key) || d.description.includes(key)) {
        const h = new SearchHit()
        h.kind = 'record'
        h.id = d.id
        h.title = d.title
        h.subtitle = ExplorationStore.categoryLabel(d.category)
        list.push(h)
      }
    }
    this.hits = list
  }

  private onSearchChange(value: string): void {
    this.keyword = value
    this.runSearch()
  }

  private async submitSearch(): Promise<void> {
    if (this.keyword.trim().length === 0) return
    await ExplorationStore.pushSearchHistory(this.keyword.trim())
    await ExplorationStore.completeTask('task_search1')
    this.history = ExplorationStore.searchHistory()
  }

  private openHit(h: SearchHit): void {
    if (h.kind === 'atlas') {
      ExploreNav.closeSearch()
      ExploreNav.openAtlasDetail(h.id)
    } else {
      ExploreNav.closeSearch()
      ExploreNav.openRecordDetail(h.id)
    }
  }

  build() {
    DetailShell({
      title: '搜索探索',
      onClose: (): void => { ExploreNav.closeSearch() }
    }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          TextInput({ text: this.keyword, placeholder: '图鉴 / 我的记录 / 关键词' })
            .layoutWeight(1)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .onChange((v: string): void => { this.onSearchChange(v) })
            .onSubmit((): void => { void this.submitSearch() })
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        if (this.keyword.trim().length === 0 && this.history.length > 0) {
          Text('搜索历史')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.history, (h: string) => {
              Text(h)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  this.keyword = h
                  this.runSearch()
                })
            }, (h: string) => h)
          }
          .width('100%')
        }

        if (this.hits.length === 0 && this.keyword.trim().length > 0) {
          AppEmpty({ title: '未找到结果', description: '换个关键词试试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.hits, (h: SearchHit) => {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 4 }) {
                    Text(h.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${h.kind === 'atlas' ? '图鉴' : '记录'} · ${h.subtitle}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.openHit(h) })
              }, (h: SearchHit) => `${h.kind}_${h.id}`)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
      .height('100%')
    }
  }
}
