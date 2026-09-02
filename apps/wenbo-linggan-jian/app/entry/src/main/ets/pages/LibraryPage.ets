import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/slip/InspirationListCard'
import { NoteItem } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipBizService } from '../services/SlipBizService'
import { SlipNav } from '../services/SlipNav'
import { SlipDateUtil } from '../services/SlipDateUtil'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State keyword: string = ''
  @State filter: string = '全部'
  @State timeFilter: string = '全部时间'
  @State favOnly: boolean = false
  @State grid: boolean = true
  @State items: NoteItem[] = []
  @State filters: string[] = ['全部']
  @State timeFilters: string[] = ['全部时间', '今天', '本周', '本月']
  @StorageLink('openLibrarySearch') wantSearch: boolean = false
  @StorageLink('openLibraryFav') wantFav: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const tags = await SlipBizService.loadTags()
    const next: string[] = ['全部']
    for (const t of tags) {
      next.push(t)
    }
    next.push('收藏')
    this.filters = next
    if (this.wantFav) {
      this.filter = '收藏'
      this.favOnly = true
      AppStorage.setOrCreate('openLibraryFav', false)
    }
    if (this.wantSearch) {
      AppStorage.setOrCreate('openLibrarySearch', false)
    }
    this.apply()
  }

  private apply(): void {
    let list = SlipStore.sorted()
    if (this.favOnly || this.filter === '收藏') {
      const fav: NoteItem[] = []
      for (const n of list) {
        if (n.favorited) {
          fav.push(n)
        }
      }
      list = fav
    } else if (this.filter !== '全部') {
      const tagged: NoteItem[] = []
      for (const n of list) {
        let hit = false
        for (const t of n.tagList()) {
          if (t === this.filter) {
            hit = true
          }
        }
        if (hit) {
          tagged.push(n)
        }
      }
      list = tagged
    }
    if (this.timeFilter === '今天') {
      const today = SlipDateUtil.todayIso()
      const timed: NoteItem[] = []
      for (const n of list) {
        if (n.noteDate === today) {
          timed.push(n)
        }
      }
      list = timed
    } else if (this.timeFilter === '本周') {
      const timed: NoteItem[] = []
      for (const n of list) {
        if (SlipDateUtil.inLastDays(n.noteDate, 6)) {
          timed.push(n)
        }
      }
      list = timed
    } else if (this.timeFilter === '本月') {
      const timed: NoteItem[] = []
      for (const n of list) {
        if (SlipDateUtil.sameMonth(n.noteDate)) {
          timed.push(n)
        }
      }
      list = timed
    }
    const kw = this.keyword.trim()
    if (kw.length > 0) {
      const hit: NoteItem[] = []
      for (const n of list) {
        if (n.title.indexOf(kw) >= 0 || n.body.indexOf(kw) >= 0 || n.tagsCsv.indexOf(kw) >= 0) {
          hit.push(n)
        }
      }
      list = hit
    }
    this.items = list
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('我的灵感')
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Column() {
        TextInput({ text: this.keyword, placeholder: '搜索灵感' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onChange((v: string) => {
            this.keyword = v
            this.apply()
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.filters, (f: string) => {
            Text(f)
              .fontSize(Theme.type.caption)
              .fontColor(this.filter === f ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.filter === f ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.filter = f
                this.favOnly = f === '收藏'
                this.apply()
              })
          }, (f: string) => f)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.timeFilters, (f: string) => {
            Text(f)
              .fontSize(Theme.type.caption)
              .fontColor(this.timeFilter === f ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(Theme.radius.pill)
              .border({
                width: 1,
                color: this.timeFilter === f ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
              })
              .onClick((): void => {
                this.timeFilter = f
                this.apply()
              })
          }, (f: string) => `t-${f}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row() {
        Text(`${this.items.length} 条`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Blank()
        Column() {
          AppIcon({
            name: this.grid ? 'biz' : 'chart',
            iconSize: Theme.icon.md,
            color: Theme.colors().textPrimary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.grid = !this.grid })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.items.length === 0) {
        AppEmpty({
          title: this.favOnly ? '还没有收藏' : '这里还很安静',
          description: this.favOnly ? '把值得再次遇见的灵感留在这里。' : '记录第一条灵感吧。',
          actionLabel: '记录灵感',
          onAction: (): void => { SlipNav.openWrite('') }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (n: NoteItem) => {
            ListItem() {
              InspirationListCard({
                item: n,
                compact: !this.grid,
                onTap: (): void => { SlipNav.openDetail(n.id) }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (n: NoteItem) => n.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
