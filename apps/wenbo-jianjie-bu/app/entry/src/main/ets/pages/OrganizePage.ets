import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsightEntry, InsightNotebook, InsightTagCount, MonthGroup } from '../models/InsightModels'
import { OrganizeFilterPane } from '../components/book/OrganizeFilterPane'
import { InsightStore } from '../services/InsightStore'
import { InsightMedia } from '../services/InsightMedia'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpen: (id: string) => void = (_id: string) => {}
  @State viewIndex: number = 0
  @State tags: InsightTagCount[] = []
  @State books: InsightNotebook[] = []
  @State months: MonthGroup[] = []
  @State filterTitle: string = ''
  @State filtered: InsightEntry[] = []
  @State bookCounts: string[] = []
  @State newBookName: string = ''
  @State bookToast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.tags = await InsightStore.tagCloud()
    this.books = await InsightStore.loadNotebooks()
    this.months = await InsightStore.monthGroups()
    const counts: string[] = []
    for (const b of this.books) {
      const items = await InsightStore.byNotebook(b.id)
      counts.push(`${items.length}`)
    }
    this.bookCounts = counts
  }

  private async openTag(name: string): Promise<void> {
    this.filterTitle = `标签 · ${name}`
    this.filtered = await InsightStore.byTag(name)
  }

  private async openBook(id: string, name: string): Promise<void> {
    this.filterTitle = `笔记本 · ${name}`
    this.filtered = await InsightStore.byNotebook(id)
  }

  private async openMonth(key: string, label: string): Promise<void> {
    this.filterTitle = label
    this.filtered = await InsightStore.byMonth(key)
  }

  private async createBook(): Promise<void> {
    const ok = await InsightStore.addNotebook(this.newBookName)
    if (!ok) {
      this.bookToast = InsightStore.lastError
      setTimeout((): void => { this.bookToast = '' }, 2200)
      return
    }
    this.newBookName = ''
    this.bookToast = '笔记本已创建'
    setTimeout((): void => { this.bookToast = '' }, 1800)
    await this.reload()
  }

  private countFor(index: number): string {
    let i = 0
    for (const c of this.bookCounts) {
      if (i === index) {
        return c
      }
      i++
    }
    return '0'
  }

  build() {
    Column() {
      Text('整理')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Stack() {
        Image($r('app.media.banner_organize'))
          .width('100%')
          .height(96)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Column()
          .width('100%')
          .height(96)
          .borderRadius(Theme.radius.md)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,20,58,0.1)', 0], ['rgba(26,20,58,0.7)', 1]]
          })
        Text('按标签、笔记本或月份回看')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 16, bottom: 14 })
      }
      .width('100%')
      .height(96)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .clip(true)

      Row({ space: 8 }) {
        this.Seg('标签云', 0, 'tag')
        this.Seg('笔记本', 1, 'book')
        this.Seg('时间轴', 2, 'calendar')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.filterTitle.length > 0) {
        OrganizeFilterPane({
          title: this.filterTitle,
          items: this.filtered,
          bottomInset: this.bottomInset,
          onBack: (): void => {
            this.filterTitle = ''
            this.filtered = []
          },
          onOpen: (id: string) => { this.onOpen(id) }
        })
          .layoutWeight(1)
      } else if (this.viewIndex === 0) {
        this.TagView()
      } else if (this.viewIndex === 1) {
        this.BookView()
      } else {
        this.MonthView()
      }
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Seg(label: string, index: number, icon: string) {
    Row({ space: 4 }) {
      AppIcon({
        name: icon === 'book' ? 'book' : (icon === 'calendar' ? 'calendar' : 'tag'),
        iconSize: Theme.icon.sm,
        color: this.viewIndex === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
      })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.viewIndex === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height(36)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.viewIndex === index ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
    .onClick((): void => {
      this.viewIndex = index
      this.filterTitle = ''
      this.filtered = []
    })
  }

  @Builder
  TagView() {
    if (this.tags.length === 0) {
      AppEmpty({
        title: '还没有标签',
        description: '保存见解时加上标签，这里会生成标签云'
      })
        .layoutWeight(1)
    } else {
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (t: InsightTagCount) => {
            Text(`${CategoryEmojiUtil.chipLabel(t.name)}  ${t.count}`)
              .fontSize(12 + Math.min(t.count, 8))
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { void this.openTag(t.name) })
          }, (t: InsightTagCount) => t.name)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: this.bottomInset + 16
        })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  BookView() {
    Column() {
      Row({ space: 8 }) {
        TextInput({ text: this.newBookName, placeholder: '新建笔记本名称' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .onChange((v: string) => { this.newBookName = v })
        Text('创建')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { void this.createBook() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      if (this.bookToast.length > 0) {
        Text(this.bookToast)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: Theme.space.pageX })
      }
      List() {
      ForEach(this.books, (b: InsightNotebook, index: number) => {
        ListItem() {
          Row({ space: 12 }) {
            Column() {
              AppIcon({
                name: InsightMedia.notebookIcon(b.id),
                iconSize: Theme.icon.lg,
                color: Theme.colors().brandOnPrimary
              })
            }
            .width(48)
            .height(48)
            .borderRadius(Theme.radius.sm)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            Column({ space: 4 }) {
              Text(`${CategoryEmojiUtil.markForNotebook(b.id)} ${b.name}`)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${this.countFor(index)} 条见解`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { void this.openBook(b.id, b.name) })
        }
        .margin({ bottom: 10 })
      }, (b: InsightNotebook) => b.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset
      })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  MonthView() {
    if (this.months.length === 0) {
      AppEmpty({
        title: '时间轴是空的',
        description: '写下第一条见解后，会按月份聚合'
      })
        .layoutWeight(1)
    } else {
      List() {
        ForEach(this.months, (m: MonthGroup) => {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text(m.label)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(`${m.count} 条`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { void this.openMonth(m.monthKey, m.label) })
          }
          .margin({ bottom: 10 })
        }, (m: MonthGroup) => m.monthKey)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset
      })
      .scrollBar(BarState.Off)
    }
  }
}
