import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { BookLibraryItem, LibraryShelfSnapshot } from '../models/StudyModels'
import { StudyStore } from '../services/StudyStore'
import { NoteStore } from '../services/NoteStore'
import { MediaUriUtil } from '../utils/MediaUriUtil'
import { BookNote } from '../models/BookNoteModels'

@Component
export struct BookShelfPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @Prop @Watch('onActiveChange') active: boolean = false
  @State books: BookLibraryItem[] = []
  @State snap: LibraryShelfSnapshot = new LibraryShelfSnapshot()
  @State filter: string = 'all'
  @State noteTotal: number = 0
  private cachedNotes: BookNote[] = []
  onOpenBook: (id: string) => void = (_id: string) => {}
  onCreateBook: () => void = () => {}
  onOpenTimer: () => void = () => {}
  onOpenDiagnosis: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  onActiveChange(): void {
    if (this.active) {
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.books = await StudyStore.loadBooks()
    this.snap = await StudyStore.libraryShelfSnapshot()
    this.cachedNotes = await NoteStore.loadAll()
    this.noteTotal = this.cachedNotes.length
  }

  private filteredBooks(): BookLibraryItem[] {
    if (this.filter === 'all') {
      return this.books
    }
    const out: BookLibraryItem[] = []
    for (const b of this.books) {
      if (b.status === this.filter) {
        out.push(b)
      }
    }
    return out
  }

  private excerptCount(title: string): number {
    return StudyStore.noteCountForBook(title, this.cachedNotes)
  }

  build() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('我的书架')
            .fontSize(Theme.type.titleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(`${this.snap.totalBooks} 本 · ${this.noteTotal} 条摘录 · ${this.snap.totalSessionMinutes} 分钟专注阅读`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Row() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onCreateBook() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: 8 }) {
        this.FilterChip('全部', 'all')
        this.FilterChip('在读', 'reading')
        this.FilterChip('已读完', 'finished')
        this.FilterChip('想读', 'wish')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      Row({ space: 8 }) {
        this.QuickAction('专注阅读', 'clock', (): void => { this.onOpenTimer() })
        this.QuickAction('阅读诊断', 'sparkle', (): void => { this.onOpenDiagnosis() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.filteredBooks().length === 0) {
        AppEmpty({
          title: '书架还是空的',
          description: '添加书籍后，可追踪阅读进度、专注时长与摘录汇总',
          actionLabel: '添加第一本书',
          onAction: (): void => { this.onCreateBook() }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Grid() {
            ForEach(this.filteredBooks(), (b: BookLibraryItem) => {
              GridItem() {
                this.BookCard(b)
              }
            }, (b: BookLibraryItem) => `${b.id}_${b.updatedAt}`)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
  FilterChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.filter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.filter = key })
  }

  @Builder
  QuickAction(label: string, icon: 'clock' | 'sparkle', tap: () => void) {
    Row({ space: 6 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { tap() })
  }

  @Builder
  BookCard(b: BookLibraryItem) {
    Column({ space: 6 }) {
      if (b.coverImage.length > 0) {
        Image(MediaUriUtil.imageSrc(b.coverImage))
          .width('100%')
          .height(100)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
      } else {
        Column() {
          AppIcon({ name: 'book', iconSize: 32, color: Theme.colors().brandPrimary })
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(8)
      }
      Text(b.title)
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(2)
        .width('100%')
      if (b.author.length > 0) {
        Text(b.author)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(1)
          .width('100%')
      }
      Row() {
        Text(b.statusLabel())
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().brandPrimary)
        Text(`${this.excerptCount(b.title)} 条摘录`)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textSecondary)
        Blank()
        if (b.totalPages > 0) {
          Text(`${b.progressPercent()}%`)
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(12)
    .onClick((): void => { this.onOpenBook(b.id) })
  }
}
