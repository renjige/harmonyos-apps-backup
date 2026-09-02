import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { BookStudioSheet } from '../reading/BookStudioSheet'
import { BookItem, CreateBookRequest, PatchBookRequest } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'
import { SessionStore } from '../../services/SessionStore'
import { ReadingProgressBar } from '../reading/ReadingProgressBar'

@Component
export struct BookDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onProgressUpdated: () => void = () => {}
  @State item: BookItem | undefined = undefined
  @State loading: boolean = true
  @State updating: boolean = false
  @State viewProgress: number = 0
  @State viewStatus: string = 'reading'
  @State viewCurrentPage: number = 0
  @State toastText: string = ''
  @State studioMode: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private isOwned(): boolean {
    return this.item !== undefined && this.item.userId.length > 0
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private readStatusLabel(status: string): string {
    if (status === 'finished') {
      return '已读完'
    }
    if (status === 'unread') {
      return '想读'
    }
    return '在读'
  }

  private applyLocalProgress(next: number, status: string, currentPage: number = -1): void {
    this.viewProgress = next
    this.viewStatus = status
    if (this.item !== undefined) {
      this.item.progress = next
      this.item.readStatus = status
      let pages = currentPage
      if (pages < 0 && this.item.pageCount > 0) {
        pages = Math.round(this.item.pageCount * next / 100)
      }
      if (pages >= 0) {
        this.item.currentPage = pages
        this.viewCurrentPage = pages
      }
    }
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findBook(this.itemId)
    if (this.item !== undefined) {
      this.viewProgress = this.item.progress
      this.viewStatus = this.item.readStatus
      this.viewCurrentPage = this.item.currentPage
    }
    this.loading = false
  }

  private openStudio(mode: string): void {
    if (mode !== 'delete' && !AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    this.studioMode = mode
  }

  private async handleUpdateProgress(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.updating || this.item === undefined) {
      return
    }
    if (!this.isOwned()) {
      this.showToast('请先添加到自己的书架')
      return
    }
    const prevProgress = this.viewProgress
    const prevStatus = this.viewStatus
    const nextProgress = prevProgress >= 100 ? 100 : prevProgress + 10
    const nextStatus = nextProgress >= 100 ? 'finished' : 'reading'
    this.applyLocalProgress(nextProgress, nextStatus)
    this.updating = true
    const req = new PatchBookRequest()
    req.progress = nextProgress
    req.readStatus = nextStatus
    try {
      const updated = await ReadingBizService.patchBook(this.item.id, req)
      if (updated !== undefined) {
        this.applyLocalProgress(
          updated.progress,
          updated.readStatus.length > 0 ? updated.readStatus : nextStatus,
          updated.currentPage
        )
        this.onProgressUpdated()
        this.showToast(`阅读进度已更新至 ${this.viewProgress}%`)
      } else {
        this.applyLocalProgress(prevProgress, prevStatus)
        const msg = ReadingBizService.lastError
        this.showToast(msg.length > 0 ? msg : '更新失败，请稍后重试')
      }
    } catch {
      this.applyLocalProgress(prevProgress, prevStatus)
      this.showToast('更新失败，请稍后重试')
    }
    this.updating = false
  }

  private async handleSetStatus(status: string): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined || !this.isOwned()) {
      this.showToast('请先添加到自己的书架')
      return
    }
    const req = new PatchBookRequest()
    req.readStatus = status
    if (status === 'finished') {
      req.progress = 100
    }
    const updated = await ReadingBizService.patchBook(this.item.id, req)
    if (updated !== undefined) {
      this.applyLocalProgress(status === 'finished' ? 100 : this.viewProgress, status)
      this.onProgressUpdated()
      this.showToast(`已标记为${this.readStatusLabel(status)}`)
    } else {
      this.showToast('状态更新失败')
    }
  }

  private async handleAddToShelf(): Promise<void> {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateBookRequest()
    req.title = this.item.title
    req.author = this.item.author
    req.summary = this.item.summary
    req.coverKey = this.item.coverKey
    req.tags = this.item.tags
    req.category = this.item.category
    req.pageCount = this.item.pageCount
    req.currentPage = this.item.currentPage
    req.readStatus = 'reading'
    const created = await ReadingBizService.createBook(req)
    if (created !== undefined) {
      await SessionStore.hideBook(this.item.id)
      void ReadingBizService.removeFromShelf(this.item.id)
      this.onProgressUpdated()
      this.showToast('已添加到我的书架')
    } else {
      this.showToast('添加失败，请稍后重试')
    }
  }

  private async handleRemove(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await SessionStore.hideBook(this.item.id)
    const ok = await ReadingBizService.removeFromShelf(this.item.id)
    this.studioMode = ''
    this.onProgressUpdated()
    ReadingDetailNav.close()
    if (ok) {
      this.showToast('已从书架移除')
    }
  }

  private handleStudioDone(kind: string): void {
    this.studioMode = ''
    if (kind === 'delete') {
      void this.handleRemove()
      return
    }
    this.onProgressUpdated()
    if (kind === 'session') {
      this.showToast('已记录本次阅读时长')
    } else if (kind === 'note') {
      this.showToast('笔记已保存')
    } else if (kind === 'pages') {
      void this.loadItem()
      this.showToast('阅读页数已更新')
    } else if (kind === 'review') {
      this.showToast('书评已发布')
    } else if (kind === 'inspiration') {
      this.showToast('灵感已收藏')
    } else {
      this.showToast('札语已收藏')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载书籍…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '书籍不存在', description: '可能已被删除或网络异常' })
      } else if (this.studioMode.length > 0) {
        BookStudioSheet({
          mode: this.studioMode,
          bookId: this.item.id,
          bookTitle: this.item.title,
          initialPageCount: this.item.pageCount,
          initialCurrentPage: this.item.currentPage,
          onClose: (): void => { this.studioMode = '' },
          onDone: (kind: string): void => { this.handleStudioDone(kind) },
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
      } else {
        DetailShell({
          title: '书籍详情',
          revision: this.viewProgress,
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
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
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      this.BookBody(this.item)
    }
  }

  @Builder
  StatusChip(label: string, status: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.viewStatus === status ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.viewStatus === status ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.handleSetStatus(status) })
  }

  @Builder
  BookBody(book: BookItem) {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ReadingMedia.coverMedia(book.coverKey))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column()
          .width('100%')
          .height(220)
          .linearGradient({
            angle: 180,
            colors: Theme.heroScrimStops()
          })
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column({ space: 4 }) {
          Text(this.readStatusLabel(this.viewStatus))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.heroSubtitleColor())
          Text(book.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.heroTitleColor())
          if (book.author.length > 0) {
            Text(book.author)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.heroSubtitleColor())
          }
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        ReadingProgressBar({
          percent: this.viewProgress,
          caption: book.pageCount > 0 ?
            `${this.viewCurrentPage}/${book.pageCount} 页 · ${this.viewProgress}%` :
            `进度 ${this.viewProgress}%`
        })
        if (book.category.length > 0) {
          Text(book.category)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        Row({ space: 8 }) {
          this.StatusChip('想读', 'unread')
          this.StatusChip('在读', 'reading')
          this.StatusChip('已读', 'finished')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (book.tags.length > 0) {
        Row({ space: 8 }) {
          ForEach(book.tags, (tag: string) => {
            Text(tag)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.tagForeground())
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Theme.tagBackground())
              .border({
                width: Theme.isDark() ? 1 : 0,
                color: Theme.colors().strokeStrong
              })
              .borderRadius(Theme.radius.pill)
          }, (tag: string) => tag)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column() {
        AppCard({ title: '简介', variant: 'plain' }) {
          Text(book.description.length > 0 ? book.description : book.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        if (this.isOwned()) {
          AppButton({
            label: this.updating ? '正在更新…' : '更新阅读进度 +10%',
            onTap: (): void => { void this.handleUpdateProgress() }
          })
          AppButton({
            label: '更新阅读页数',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('pages') }
          })
          AppButton({
            label: '记录本次阅读',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('session') }
          })
          AppButton({
            label: '写一条笔记',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('note') }
          })
          AppButton({
            label: '摘录金句',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('quote') }
          })
          AppButton({
            label: '写书评',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('review') }
          })
          AppButton({
            label: '收藏灵感',
            variant: 'secondary',
            onTap: (): void => { this.openStudio('inspiration') }
          })
          AppButton({
            label: '从书架移除',
            variant: 'ghost',
            onTap: (): void => { this.openStudio('delete') }
          })
        } else {
          AppButton({
            label: '添加到我的书架',
            onTap: (): void => { void this.handleAddToShelf() }
          })
          AppButton({
            label: '从书架移除',
            variant: 'ghost',
            onTap: (): void => { this.openStudio('delete') }
          })
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
