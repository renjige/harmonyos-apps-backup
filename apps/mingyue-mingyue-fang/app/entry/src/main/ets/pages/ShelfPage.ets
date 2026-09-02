import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { BookItem, CreateBookRequest, CreateReadingLogRequest } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'
import { SessionStore } from '../services/SessionStore'

@Component
export struct ShelfPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onBookCreated: () => void = () => {}
  @State books: BookItem[] = []
  @State showcaseBooks: BookItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State filterStatus: string = 'all'
  @State formTitle: string = ''
  @State formAuthor: string = ''
  @State formSummary: string = ''
  @State formTags: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.books.length === 0 && this.showcaseBooks.length === 0) {
      this.loading = true
    }
    this.showcaseBooks = this.visibleBooks(await ReadingBizService.loadBookShowcase())
    if (AuthService.isLoggedIn()) {
      this.books = this.visibleBooks(await ReadingBizService.loadBooks(this.currentUsername))
    } else {
      this.books = this.showcaseBooks
    }
    this.loading = false
  }

  private visibleBooks(source: BookItem[]): BookItem[] {
    const out: BookItem[] = []
    for (const b of source) {
      if (!SessionStore.isBookHidden(b.id)) {
        out.push(b)
      }
    }
    return out
  }

  private filteredBooks(): BookItem[] {
    if (this.filterStatus === 'all') {
      return this.books
    }
    const out: BookItem[] = []
    for (const b of this.books) {
      if (b.readStatus === this.filterStatus) {
        out.push(b)
      }
    }
    return out
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async removeBook(item: BookItem): Promise<void> {
    await SessionStore.hideBook(item.id)
    const next: BookItem[] = []
    for (const b of this.books) {
      if (b.id !== item.id) {
        next.push(b)
      }
    }
    this.books = next
    void ReadingBizService.removeFromShelf(item.id)
    this.onBookCreated()
    this.showToast('已从书架移除')
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formAuthor = ''
    this.formSummary = ''
    this.formTags = ''
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async submitBook(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写书名'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateBookRequest()
    req.title = this.formTitle.trim()
    req.author = this.formAuthor.trim()
    req.summary = this.formSummary.trim()
    req.tags = this.parseTags(this.formTags)
    req.coverKey = 'book_default'
    req.userId = this.currentUsername
    const created = await ReadingBizService.createBook(req)
    this.submitting = false
    if (created !== undefined) {
      const logReq = new CreateReadingLogRequest()
      logReq.title = `开始阅读《${created.title}》`
      logReq.bookId = created.id
      logReq.readingMinutes = 0
      logReq.recordDate = new Date().toISOString().slice(0, 10)
      logReq.userId = this.currentUsername
      await ReadingBizService.createReadingLog(logReq)
      this.closeForm()
      await this.reload()
      this.onBookCreated()
    } else {
      this.formError = '添加失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '我的书架', subtitle: '管理书籍与阅读进度' })
        Row({ space: 8 }) {
          this.StatusChip('全部', 'all')
          this.StatusChip('在读', 'reading')
          this.StatusChip('已读', 'finished')
          this.StatusChip('想读', 'unread')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (this.loading) {
          AppLoading({ label: '加载书架…' }).layoutWeight(1)
        } else if (this.filteredBooks().length === 0) {
          Column() {
            AppEmpty({
              title: '书架还是空的',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮添加第一本书'
                : '登录后可添加并同步你的书架',
              actionLabel: '添加书籍',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.filteredBooks(), (item: BookItem) => {
                ReadingListCard({
                  title: item.title,
                  subtitle: item.author,
                  summary: item.summary,
                  coverKey: item.coverKey,
                  meta: item.userId.length > 0 ? `进度 ${item.progress}%` : '示例书目',
                  tags: item.tags,
                  showRemove: true,
                  onTap: (): void => { ReadingDetailNav.openBook(item.id) },
                  onRemove: (): void => { void this.removeBook(item) }
                })
              }, (item: BookItem) => item.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
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
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(45,90,74,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.BookFormOverlay()
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatusChip(label: string, status: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterStatus === status ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.filterStatus === status ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.filterStatus = status })
  }

  @Builder
  BookFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('添加书籍')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('书名')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '输入书名…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('作者')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formAuthor, placeholder: '作者（可选）' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formAuthor = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('简介')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formSummary, placeholder: '一句话简介…' })
              .width('100%')
              .height(100)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formSummary = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('分类标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '文学, 哲学, 历史' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '添加中…' : '添加到书架',
            disabled: this.submitting,
            onTap: (): void => { void this.submitBook() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
