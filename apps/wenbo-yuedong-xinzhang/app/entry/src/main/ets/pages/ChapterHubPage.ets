import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { YdChapterItem } from '../models/YdModels'
import { YdLocalStore } from '../services/YdLocalStore'
import { YdDetailNav } from '../services/YdDetailNav'

enum ChapterFilter {
  All = 0,
  Active = 1,
  Closed = 2
}

@Component
export struct ChapterHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State chapters: YdChapterItem[] = []
  @State filter: ChapterFilter = ChapterFilter.All
  @State themeFilter: string = 'all'
  @State sortNew: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    let list = await YdLocalStore.loadAllChapters()
    if (this.filter === ChapterFilter.Active) {
      const next: YdChapterItem[] = []
      for (const c of list) {
        if (!c.closed) {
          next.push(c)
        }
      }
      list = next
    } else if (this.filter === ChapterFilter.Closed) {
      const next: YdChapterItem[] = []
      for (const c of list) {
        if (c.closed) {
          next.push(c)
        }
      }
      list = next
    }
    if (this.themeFilter !== 'all') {
      const next: YdChapterItem[] = []
      for (const c of list) {
        if (c.theme === this.themeFilter) {
          next.push(c)
        }
      }
      list = next
    }
    list.sort((a, b) => this.sortNew ? b.createdAt - a.createdAt : a.remainDays() - b.remainDays())
    this.chapters = list
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.banner_chapter_hub'))
          .width('100%')
          .height(112)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(112)
          .linearGradient({
            angle: 180,
            colors: [['rgba(10,37,64,0.08)', 0], ['rgba(10,37,64,0.85)', 1]]
          })
        Row() {
          Column({ space: 4 }) {
            Text('篇章中心')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('人生篇章档案 · 可筛选 · 可收官回顾')
              .fontSize(Theme.type.bodyS)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: '#FFFFFF' })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.18)')
          .borderRadius(20)
          .onClick(() => YdDetailNav.openSearch())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
      }

      Row({ space: Theme.space.s2 }) {
        this.StatusChip('全部', ChapterFilter.All)
        this.StatusChip('进行中', ChapterFilter.Active)
        this.StatusChip('已收官', ChapterFilter.Closed)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.ThemeChip('全部主题', 'all')
          this.ThemeChip('职场', 'career')
          this.ThemeChip('备考', 'exam')
          this.ThemeChip('节律', 'health')
          this.ThemeChip('阅读', 'reading')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Row() {
        Text(this.sortNew ? '按最近排序' : '按剩余天数')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => {
            this.sortNew = !this.sortNew
            void this.reload()
          })
        Blank()
        Text('开新章')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => YdDetailNav.openChapterCreate())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2, bottom: Theme.space.s2 })

      if (this.chapters.length === 0) {
        AppEmpty({
          title: '还没有匹配的篇章',
          description: '开启一章，把接下来几天过成可收官的人生段落',
          actionLabel: '开启新章',
          onAction: (): void => { YdDetailNav.openChapterCreate() }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.chapters, (c: YdChapterItem) => {
              this.ChapterCard(c)
            }, (c: YdChapterItem) => c.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  StatusChip(label: string, value: ChapterFilter) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.filter === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.filter === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filter = value
        void this.reload()
      })
  }

  @Builder
  ThemeChip(label: string, theme: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeFilter === theme ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.themeFilter === theme ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.themeFilter = theme
        void this.reload()
      })
  }

  @Builder
  ChapterCard(c: YdChapterItem) {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(c.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .maxLines(2)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
      Text(`${c.themeLabel()} · ${c.closed ? '已收官' : `剩余 ${c.remainDays()} 天`}`)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
      Progress({ value: c.chapterProgressPercent(), total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 6 })
      if (c.closed && c.recap.length > 0) {
        Text(c.recap.length > 56 ? `${c.recap.substring(0, 56)}…` : c.recap)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => YdDetailNav.openChapterDetail(c.id))
  }
}
