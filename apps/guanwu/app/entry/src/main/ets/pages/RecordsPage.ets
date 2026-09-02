import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { RecordTimelineCard } from '../components/guanwu/RecordTimelineCard'
import { ObserveGalleryOverlay } from '../components/guanwu/ObserveGalleryOverlay'
import { CalendarDayOverlay } from '../components/guanwu/CalendarDayOverlay'
import { KindOption, ObserveRecord } from '../models/ObserveModels'
import { ObserveStore } from '../services/ObserveStore'
import { ObserveGalleryUtil, GalleryCell } from '../services/ObserveGalleryUtil'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { DateHelper } from '../services/DateHelper'
import { CategoryOption } from '../models/ObserveCatalog'

@Component
export struct RecordsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenRecord: (id: string) => void = () => {}
  onOpenEditor: () => void = () => {}
  onOpenAtlas: () => void = () => {}
  @State filterKind: string = 'all'
  @State filterCat: string = 'all'
  @State keyword: string = ''
  @State items: ObserveRecord[] = []
  @State totalCount: number = 0
  @State moodCount: number = 0
  @State sceneCount: number = 0
  @State thoughtCount: number = 0
  @State envCount: number = 0
  @State weekDays: string[] = []
  @State weekCounts: number[] = []
  @State weekDateKeys: string[] = []
  @State showGallery: boolean = false
  @State showCalendarDay: boolean = false
  @State calendarDayLabel: string = ''
  @State calendarDayItems: ObserveRecord[] = []
  @State galleryCells: GalleryCell[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    let list = await ObserveStore.loadAll()
    this.totalCount = list.length
    this.moodCount = 0
    this.sceneCount = 0
    this.thoughtCount = 0
    this.envCount = 0
    for (const n of list) {
      if (n.kind === 'mood') {
        this.moodCount++
      } else if (n.kind === 'scene') {
        this.sceneCount++
      } else if (n.kind === 'thought') {
        this.thoughtCount++
      } else if (n.kind === 'environment') {
        this.envCount++
      }
    }
    if (this.filterKind !== 'all') {
      list = await ObserveStore.filterByKind(this.filterKind)
    }
    if (this.filterCat === 'fav') {
      const favs = await ObserveStore.filterFavorites()
      const ids = new Set<string>()
      for (const f of favs) {
        ids.add(f.id)
      }
      const onlyFav: ObserveRecord[] = []
      for (const n of list) {
        if (ids.has(n.id)) {
          onlyFav.push(n)
        }
      }
      list = onlyFav
    } else if (this.filterCat !== 'all') {
      const next: ObserveRecord[] = []
      for (const n of list) {
        if (n.categoryKey === this.filterCat) {
          next.push(n)
        }
      }
      list = next
    }
    if (this.keyword.trim().length > 0) {
      const q = this.keyword.trim()
      const filtered: ObserveRecord[] = []
      for (const n of list) {
        if (n.content.indexOf(q) >= 0 || n.itemName.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0 ||
          n.kindLabel().indexOf(q) >= 0) {
          filtered.push(n)
        }
      }
      list = filtered
    }
    this.items = list
    const days: string[] = []
    const counts: number[] = []
    const keys: string[] = []
    for (let i = 6; i >= 0; i--) {
      const d = new Date()
      d.setDate(d.getDate() - i)
      const key = DateHelper.keyFromDate(d)
      keys.push(key)
      days.push(DateHelper.displayDate(key).substring(5))
      const dayNotes = await ObserveStore.notesForDate(key)
      counts.push(dayNotes.length)
    }
    this.weekDays = days
    this.weekCounts = counts
    this.weekDateKeys = keys
    const allForGallery = await ObserveStore.loadAll()
    this.galleryCells = ObserveGalleryUtil.buildCells(allForGallery)
  }

  private recordListKey(item: ObserveRecord): string {
    const imgs = item.imagePaths.join('|')
    return `${item.id}-${item.updatedAt}-${imgs}`
  }

  private openGallery(): void {
    this.showGallery = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeGallery(): void {
    this.showGallery = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async openCalendarDay(idx: number): Promise<void> {
    if (idx < 0 || idx >= this.weekDateKeys.length) {
      return
    }
    const key = this.weekDateKeys[idx]
    this.calendarDayLabel = DateHelper.displayDate(key)
    this.calendarDayItems = await ObserveStore.notesForDate(key)
    this.showCalendarDay = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeCalendarDay(): void {
    this.showCalendarDay = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  @Builder
  FilterChip(kind: string, label: string) {
    Text(CategoryEmojiUtil.chipLabel(kind, label))
      .fontSize(Theme.type.bodyS)
      .fontColor(this.filterKind === kind ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filterKind === kind ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filterKind = kind
        void this.reload()
      })
  }

  @Builder
  CatChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.filterCat === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filterCat === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filterCat = key
        void this.reload()
      })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          TextInput({ text: this.keyword, placeholder: '搜索观察内容…' })
            .layoutWeight(1)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onChange((v: string): void => {
              this.keyword = v
              void this.reload()
            })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

        Column({ space: Theme.space.s2 }) {
          Text('近 7 日观察日历')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.weekDays, (label: string, idx: number) => {
              Column({ space: 4 }) {
                Text(label)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                Text(`${this.weekCounts[idx]}`)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.weekCounts[idx] > 0 ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s2)
              .backgroundColor(this.weekCounts[idx] > 0 ?
                Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { void this.openCalendarDay(idx) })
            }, (label: string, idx: number) => `wk-${idx}`)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })

        Row({ space: Theme.space.s2 }) {
          Text('观物图集')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${this.galleryCells.length} 张`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Text('查看')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => this.openGallery())
          Text('图鉴')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .margin({ left: 12 })
            .onClick((): void => this.onOpenAtlas())
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.FilterChip('all', '全部')
            ForEach(KindOption.all(), (k: KindOption) => {
              this.FilterChip(k.key, k.label)
            }, (k: KindOption) => k.key)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .width('100%')

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.CatChip('all', '全部分类')
            this.CatChip('fav', '我的收藏')
            ForEach(CategoryOption.all(), (c: CategoryOption) => {
              this.CatChip(c.key, c.label)
            }, (c: CategoryOption) => c.key)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          Column() { AppStatCard({ label: '总计', value: `${this.totalCount}` }) }.layoutWeight(1)
          Column() { AppStatCard({ label: '心情', value: `${this.moodCount}` }) }.layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s3 })

        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有观察记录',
            description: '点击右下角按钮，记下第一条观物笔记',
            actionLabel: '立即记录',
            onAction: (): void => this.onOpenEditor()
          })
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: ObserveRecord) => {
              ListItem() {
                RecordTimelineCard({
                  record: item,
                  onTap: (): void => this.onOpenRecord(item.id)
                })
              }
            }, (item: ObserveRecord) => this.recordListKey(item))
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s3, bottom: this.bottomInset + 72 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: 28, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .shadow({ radius: 16, color: 'rgba(91,106,191,0.35)', offsetY: 6 })
      .margin({ right: Theme.space.s5, bottom: this.bottomInset + 12 })
      .onClick((): void => this.onOpenEditor())

      if (this.showGallery) {
        ObserveGalleryOverlay({
          cells: this.galleryCells,
          onClose: (): void => this.closeGallery(),
          onOpenRecord: (id: string): void => {
            this.closeGallery()
            this.onOpenRecord(id)
          }
        })
      }

      if (this.showCalendarDay) {
        CalendarDayOverlay({
          dateLabel: this.calendarDayLabel,
          items: this.calendarDayItems,
          onClose: (): void => this.closeCalendarDay(),
          onOpenRecord: (id: string): void => {
            this.closeCalendarDay()
            this.onOpenRecord(id)
          },
          onCreate: (): void => {
            this.closeCalendarDay()
            this.onOpenEditor()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
