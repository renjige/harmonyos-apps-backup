import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { NoteListCard } from '../note/NoteListCard'
import { OverlayShell } from './OverlayShell'
import { BookLibraryItem, ReadingSession } from '../../models/StudyModels'
import { BookNote } from '../../models/BookNoteModels'
import { StudyStore } from '../../services/StudyStore'
import { NoteStore } from '../../services/NoteStore'
import { MediaUriUtil } from '../../utils/MediaUriUtil'

@Component
export struct BookLibraryDetailPane {
  @Prop bookId: string = ''
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @State book: BookLibraryItem = new BookLibraryItem()
  @State notes: BookNote[] = []
  @State sessions: ReadingSession[] = []
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onStartTimer: (bookId: string, title: string) => void = (_id: string, _t: string) => {}
  onAddExcerpt: (title: string) => void = (_t: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await StudyStore.findBook(this.bookId)
    if (found !== undefined) {
      this.book = found
    }
    const all = await NoteStore.loadAll()
    const out: BookNote[] = []
    for (const n of all) {
      if (n.bookName.trim() === this.book.title.trim()) {
        out.push(n)
      }
    }
    this.notes = out
    this.sessions = await StudyStore.sessionsForBook(this.bookId)
  }

  private sessionLabel(): string {
    let total = 0
    for (const s of this.sessions) {
      total += s.durationMinutes
    }
    return `${this.sessions.length} 场 · ${total} 分钟`
  }

  build() {
    OverlayShell({
      title: '书籍详情',
      showBack: true,
      onClose: (): void => { this.onClose() },
      onBack: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      if (this.book.coverImage.length > 0) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MediaUriUtil.imageSrc(this.book.coverImage))
            .width('100%')
            .height(160)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(80)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.65)', 1]]
            })
          Column({ space: 4 }) {
            Text(this.book.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            if (this.book.author.length > 0) {
              Text(this.book.author)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
          }
          .padding(12)
        }
        .width('100%')
      } else {
        Column({ space: 4 }) {
          Text(this.book.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          if (this.book.author.length > 0) {
            Text(this.book.author)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Row({ space: 8 }) {
        Text(this.book.statusLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
        Text(`${this.notes.length} 条摘录`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.sessionLabel())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')

      if (this.book.totalPages > 0) {
        Column({ space: 6 }) {
          Text(`阅读进度 ${this.book.currentPage}/${this.book.totalPages} 页 · ${this.book.progressPercent()}%`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row() {
            Column()
              .layoutWeight(this.book.progressPercent() <= 0 ? 1 : this.book.progressPercent())
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(4)
            Column()
              .layoutWeight(this.book.progressPercent() >= 100 ? 1 : (100 - this.book.progressPercent()))
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(4)
          }
          .width('100%')
        }
        .width('100%')
      }

      if (this.book.memo.length > 0) {
        Text(this.book.memo)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }

      Row({ space: 8 }) {
        AppButton({
          label: '添加摘录',
          variant: 'secondary',
          onTap: (): void => { this.onAddExcerpt(this.book.title) }
        })
          .layoutWeight(1)
        AppButton({
          label: '专注阅读',
          onTap: (): void => { this.onStartTimer(this.book.id, this.book.title) }
        })
          .layoutWeight(1)
      }
      .width('100%')

      AppButton({
        label: '编辑书籍',
        variant: 'secondary',
        onTap: (): void => { this.onEdit() }
      })

      Text('本书摘录')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      if (this.notes.length === 0) {
        AppEmpty({
          title: '还没有摘录',
          description: '阅读时随时添加金句与感悟',
          actionLabel: '添加摘录',
          onAction: (): void => { this.onAddExcerpt(this.book.title) }
        })
      } else {
        ForEach(this.notes, (n: BookNote) => {
          NoteListCard({
            item: n,
            onOpen: (): void => { this.onOpenDetail(n.id) }
          })
        }, (n: BookNote) => `${n.id}_${n.updatedAt}`)
      }
    }
    .width('100%')
  }
}
