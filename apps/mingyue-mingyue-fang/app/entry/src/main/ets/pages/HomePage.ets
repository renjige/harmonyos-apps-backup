import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { BookGridCard } from '../components/reading/BookGridCard'
import {
  BookItem,
  CreateBookRequest,
  FeaturedItem
} from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { ReadingMedia } from '../services/ReadingMedia'
import { AuthService } from '../services/AuthService'
import { SessionStore } from '../services/SessionStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

/** 智慧书架：今日明悟 + 两列网格 + 分类筛选 */
@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '明阅坊'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onBookChanged: () => void = () => {}
  @State featured: FeaturedItem[] = []
  @State wisdomIndex: number = 0
  @State books: BookItem[] = []
  @State loading: boolean = true
  @State filterStatus: string = 'all'
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formAuthor: string = ''
  @State formSummary: string = ''
  @State formTags: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @State refreshing: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private todayWisdomIndex(): number {
    const d = new Date()
    const day = d.getFullYear() * 1000 + d.getMonth() * 31 + d.getDate()
    if (this.featured.length === 0) {
      return 0
    }
    return day % this.featured.length
  }

  private async reload(): Promise<void> {
    this.refreshing = true
    if (this.books.length === 0) {
      this.loading = true
    }
    this.featured = await ReadingBizService.loadFeatured()
    this.wisdomIndex = this.todayWisdomIndex()
    const showcase = await ReadingBizService.loadBookShowcase()
    if (AuthService.isLoggedIn()) {
      this.books = this.visibleBooks(await ReadingBizService.loadBooks(this.currentUsername))
    } else {
      this.books = this.visibleBooks(showcase)
    }
    this.loading = false
    this.refreshing = false
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
    if (this.filterStatus === 'starred') {
      const out: BookItem[] = []
      for (const b of this.books) {
        for (const t of b.tags) {
          if (t === '精选' || t === '收藏') {
            out.push(b)
            break
          }
        }
      }
      return out
    }
    const out: BookItem[] = []
    for (const b of this.books) {
      if (b.readStatus === this.filterStatus) {
        out.push(b)
      }
    }
    return out
  }

  private statusLabel(status: string): string {
    if (status === 'reading') {
      return '在读'
    }
    if (status === 'finished') {
      return '已读完'
    }
    if (status === 'unread') {
      return '想读'
    }
    return ''
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
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
      this.closeForm()
      await this.reload()
      this.onBookChanged()
      this.showToast('已加入书架')
    } else {
      this.formError = '添加失败，请稍后重试'
    }
  }

  private async removeBook(item: BookItem): Promise<void> {
    await SessionStore.hideBook(item.id)
    await this.reload()
    this.onBookChanged()
    this.showToast('已从书架移除')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Stack({ alignContent: Alignment.Center }) {
                Column()
                  .width(36)
                  .height(36)
                  .linearGradient({
                    angle: 135,
                    colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
                  })
                  .borderRadius(10)
                AppIcon({ name: 'book', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
              }
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            Text(`${CategoryEmojiUtil.weekdayMark()} ${CategoryEmojiUtil.dailyHint()}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY
        })

        Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
            if (this.featured.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Text('今日明悟')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Scroll() {
                  Row({ space: Theme.space.s3 }) {
                    ForEach(this.featured, (item: FeaturedItem, index: number) => {
                      Stack({ alignContent: Alignment.BottomStart }) {
                        Image(ReadingMedia.coverMedia(item.coverKey))
                          .width(280)
                          .height(120)
                          .borderRadius(Theme.radius.xl)
                          .objectFit(ImageFit.Cover)
                        Column()
                          .width(280)
                          .height(120)
                          .linearGradient({
                            angle: 180,
                            colors: [['rgba(26,42,58,0.05)', 0], ['rgba(26,42,58,0.82)', 1]]
                          })
                          .borderRadius(Theme.radius.xl)
                        Column({ space: 6 }) {
                          Text(item.title)
                            .fontSize(Theme.type.subhead)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(Theme.colors().textOnInverse)
                            .maxLines(2)
                            .width('100%')
                          Text(item.summary)
                            .fontSize(Theme.type.caption)
                            .fontColor(Theme.colors().textOnInverse)
                            .maxLines(2)
                            .width('100%')
                        }
                        .padding(Theme.space.s4)
                        .width(280)
                      }
                      .onClick((): void => { ReadingDetailNav.openFeatured(item.id) })
                    }, (item: FeaturedItem) => item.id)
                  }
                  .padding({ right: Theme.space.pageX })
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
              .width('100%')
            }

            Scroll() {
              Row({ space: 8 }) {
                this.FilterChip('全部', 'all')
                this.FilterChip('正在阅读', 'reading')
                this.FilterChip('已读完', 'finished')
                this.FilterChip('收藏精选', 'starred')
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.loading) {
              AppLoading({ variant: 'skeleton' })
            } else if (this.filteredBooks().length === 0) {
              AppEmpty({
                title: '书架暂无内容',
                description: AuthService.isLoggedIn()
                  ? '点击右下角添加第一本书，或浏览今日明悟'
                  : '登录后可添加个人书籍；当前可浏览示例书目',
                actionLabel: '添加书籍',
                emojiMark: '📚',
                iconName: 'book',
                onAction: (): void => { this.openCreateForm() }
              })
            } else {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                ForEach(this.filteredBooks(), (item: BookItem) => {
                  Column() {
                    BookGridCard({
                      title: item.title,
                      author: item.author,
                      coverKey: item.coverKey,
                      progressLabel: item.userId.length > 0 ? `进度 ${item.progress}%` : '示例书目',
                      statusLabel: this.statusLabel(item.readStatus),
                      onTap: (): void => { ReadingDetailNav.openBook(item.id) },
                      onLongPress: (): void => {
                        if (item.userId.length > 0) {
                          void this.removeBook(item)
                        }
                      }
                    })
                  }
                  .width('48%')
                  .margin({ bottom: Theme.space.s3 })
                }, (item: BookItem) => item.id)
              }
              .width('100%')
            }
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
        .layoutWeight(1)
        .onRefreshing((): void => { void this.reload() })
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
        .shadow({ radius: 12, color: 'rgba(26,42,58,0.18)', offsetY: 4 })
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
  FilterChip(label: string, status: string) {
    Text(CategoryEmojiUtil.filterLabel(status, label))
      .fontSize(Theme.type.caption)
      .fontColor(this.filterStatus === status ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filterStatus === status ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .border({
        width: 1,
        color: this.filterStatus === status ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
      })
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
          TextInput({ text: this.formTitle, placeholder: '书名' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextInput({ text: this.formAuthor, placeholder: '作者（可选）' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formAuthor = v })
          TextArea({ text: this.formSummary, placeholder: '简介（可选）' })
            .width('100%')
            .height(100)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formSummary = v })
          TextInput({ text: this.formTags, placeholder: '标签，逗号分隔' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTags = v })
          AppButton({
            label: this.submitting ? '添加中…' : '加入书架',
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
