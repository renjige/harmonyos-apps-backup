import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { HomeStudioGrid } from '../components/reading/HomeStudioGrid'
import { UniquePlayCards } from '../components/reading/UniquePlayCards'
import { BookItem, BooklistItem, FeaturedItem, QuoteItem, ReadingLogItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { ReadingMedia } from '../services/ReadingMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '读书札语'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onAddBook: () => void = () => {}
  onOpenCheckin: () => void = () => {}
  onOpenNotes: () => void = () => {}
  onOpenQuotes: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenInspirations: () => void = () => {}
  onOpenBooklists: () => void = () => {}
  onOpenMonthly: () => void = () => {}
  onOpenReport: () => void = () => {}
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenStudioPlay: () => void = () => {}
  onOpenBookAsk: () => void = () => {}
  @State featured: FeaturedItem[] = []
  @State currentBooks: BookItem[] = []
  @State booklists: BooklistItem[] = []
  @State recentQuotes: QuoteItem[] = []
  @State weekMinutes: number = 0
  @State streakDays: number = 0
  @State checkedToday: boolean = false
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，翻开今日书页'
    }
    if (hour < 17) {
      return '午安，静享阅读时光'
    }
    return '晚安，把思考收进札语'
  }

  private async reload(): Promise<void> {
    this.featured = await ReadingBizService.loadFeatured()
    this.booklists = await ReadingBizService.loadBooklists()
    if (AuthService.isLoggedIn()) {
      const books = await ReadingBizService.loadBooks(this.currentUsername)
      const reading: BookItem[] = []
      for (const b of books) {
        if (b.readStatus === 'reading' && b.userId.length > 0) {
          reading.push(b)
        }
      }
      this.currentBooks = reading
      this.recentQuotes = (await ReadingBizService.loadQuotes(this.currentUsername, '')).slice(0, 3)
      const logs = await ReadingBizService.loadReadingLogs(this.currentUsername, '')
      this.weekMinutes = this.sumWeekMinutes(logs)
      const feed = await ReadingBizService.loadCheckinFeed()
      this.streakDays = feed.streakDays
      this.checkedToday = feed.checkedToday
    } else {
      this.currentBooks = []
      this.recentQuotes = []
      this.weekMinutes = 0
      this.streakDays = 0
      this.checkedToday = false
    }
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row({ space: 12 }) {
          Image($r('app.media.app_icon'))
            .width(44)
            .height(44)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.greeting())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        UniquePlayCards({
          onOpenLamp: (): void => { this.onOpenLamp() },
          onOpenDialogue: (): void => { this.onOpenDialogue() },
          onOpenBookAsk: (): void => { this.onOpenBookAsk() },
          onOpenStudioPlay: (): void => { this.onOpenStudioPlay() }
        })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_reading_desk'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(168)
            .linearGradient({
              angle: 180,
              colors: [['rgba(45,90,74,0.1)', 0], ['rgba(45,90,74,0.82)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Column({ space: 6 }) {
            Text('灯下共读 · 对读札')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textOnInverse)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
            Text('问书三札 · 十二项书房管理')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
              .maxLines(2)
              .lineHeight(18)
              .width('100%')
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          HomeStudioGrid({
            streakDays: this.streakDays,
            checkedToday: this.checkedToday,
            weekMinutes: this.weekMinutes,
            onOpenCheckin: (): void => { this.onOpenCheckin() },
            onOpenNotes: (): void => { this.onOpenNotes() },
            onOpenQuotes: (): void => { this.onOpenQuotes() },
            onOpenReviews: (): void => { this.onOpenReviews() },
            onOpenInspirations: (): void => { this.onOpenInspirations() },
            onOpenBooklists: (): void => { this.onOpenBooklists() },
            onOpenMonthly: (): void => { this.onOpenMonthly() },
            onOpenReport: (): void => { this.onOpenReport() },
            onOpenLamp: (): void => { this.onOpenLamp() },
            onOpenDialogue: (): void => { this.onOpenDialogue() },
            onOpenStudioPlay: (): void => { this.onOpenStudioPlay() },
            onOpenBookAsk: (): void => { this.onOpenBookAsk() }
          })

          if (this.currentBooks.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('最近在读')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.currentBooks.slice(0, 3), (item: BookItem) => {
                ReadingListCard({
                  title: item.title,
                  subtitle: item.author,
                  summary: item.summary,
                  coverKey: item.coverKey,
                  meta: item.pageCount > 0 ?
                    `${item.currentPage}/${item.pageCount} 页 · ${item.progress}%` :
                    `进度 ${item.progress}%`,
                  tags: item.category.length > 0 ? [item.category] : item.tags,
                  onTap: (): void => { ReadingDetailNav.openBook(item.id) }
                })
              }, (item: BookItem) => item.id)
            }
            .width('100%')
          } else {
            AppEmpty({
              title: '还没有在读书籍',
              description: '添加一本书，开始记录进度、笔记与打卡',
              actionLabel: '添加书籍',
              onAction: (): void => { this.onAddBook() }
            })
          }

          if (this.booklists.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('专题书单')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  ForEach(this.booklists, (item: BooklistItem) => {
                    Column({ space: 8 }) {
                      Image(ReadingMedia.coverMedia(item.coverKey))
                        .width(148)
                        .height(100)
                        .borderRadius(Theme.radius.lg)
                        .objectFit(ImageFit.Cover)
                      Text(item.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                        .width(148)
                    }
                    .onClick((): void => { ReadingDetailNav.openBooklist(item.id) })
                  }, (item: BooklistItem) => item.id)
                }
                .padding({ right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            Text('精选札语')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.recentQuotes.length > 0) {
              ForEach(this.recentQuotes, (item: QuoteItem) => {
                ReadingListCard({
                  title: item.title,
                  subtitle: item.source,
                  summary: item.content,
                  coverKey: 'hero_reading_desk',
                  showCover: false,
                  compact: true,
                  onTap: (): void => { ReadingDetailNav.openQuote(item.id) }
                })
              }, (item: QuoteItem) => item.id)
            } else {
              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  ForEach(this.featured, (item: FeaturedItem) => {
                    Column({ space: 8 }) {
                      Image(ReadingMedia.coverMedia(item.coverKey))
                        .width(140)
                        .height(100)
                        .borderRadius(Theme.radius.lg)
                        .objectFit(ImageFit.Cover)
                      Text(item.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                        .width(140)
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
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  private sumWeekMinutes(logs: ReadingLogItem[]): number {
    const cutoff = new Date()
    cutoff.setDate(cutoff.getDate() - 6)
    const cutoffIso = cutoff.toISOString().slice(0, 10)
    let total = 0
    for (const log of logs) {
      if (log.recordDate >= cutoffIso) {
        total += log.readingMinutes
      }
    }
    return total
  }
}
