import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SymbolCover } from '../components/design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { QuoteCategories } from '../models/QuoteCategories'
import { WisdomItem } from '../models/WisdomHallModels'
import { FavoriteLocalService } from '../services/FavoriteLocalService'
import { ReadTodayService } from '../services/ReadTodayService'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { WisdomMedia } from '../services/WisdomMedia'
import { ReadListCard } from '../components/wisdom/ReadListCard'
import { LunarHintUtil } from '../utils/LunarHintUtil'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '文墨集'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State todayQuote: WisdomItem = new WisdomItem()
  @State hasQuote: boolean = false
  @State readToday: boolean = false
  @State favorited: boolean = false
  @State toastText: string = ''
  @State categories: string[] = QuoteCategories.all()
  @State reads: WisdomItem[] = []
  @State refreshing: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.refreshing = true
    const quote = await WisdomHallBizService.loadQuotesToday()
    if (quote !== undefined) {
      this.todayQuote = quote
      this.hasQuote = true
      this.favorited = await FavoriteLocalService.isFavorited(quote.id)
    } else {
      this.hasQuote = false
    }
    this.readToday = await ReadTodayService.isReadToday()
    this.reads = await WisdomHallBizService.loadReads()
    this.refreshing = false
  }

  private async toggleFavorite(): Promise<void> {
    if (!this.hasQuote) {
      return
    }
    if (this.favorited) {
      await FavoriteLocalService.remove(this.todayQuote.id)
      this.favorited = false
      this.showToast('已取消收藏')
    } else {
      await FavoriteLocalService.add(this.todayQuote)
      this.favorited = true
      this.showToast('已加入收藏')
    }
    WisdomHallBizService.bumpRefresh()
  }

  private shareQuote(): void {
    if (!this.hasQuote) {
      return
    }
    const author = this.todayQuote.authorName.length > 0 ? `—— ${this.todayQuote.authorName}` : ''
    const text = `「${this.todayQuote.title}」\n${author}\n\n来自「${this.appName}」`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('语录已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  private openQuoteDetail(): void {
    if (!this.hasQuote) {
      return
    }
    void ReadTodayService.markReadToday()
    this.readToday = true
    WisdomHallNav.openDetail('quote', this.todayQuote.id)
  }

  build() {
    Stack() {
      Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(WisdomMedia.resource('hero_today'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Column()
                .width('100%')
                .height(160)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0.05)', 0], ['rgba(26,26,46,0.72)', 1]]
                })
                .borderRadius(Theme.radius.md)
              Column({ space: 4 }) {
                Text(this.appName)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textOnInverse)
                Text(`${LunarHintUtil.todayLabel()} · ${LunarHintUtil.lunarHint()}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textOnInverse)
              }
              .padding(Theme.space.s4)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              SymbolCover({
                category: this.hasQuote && (this.todayQuote.category ?? '').length > 0 ?
                  this.todayQuote.category : '经史子集',
                coverKey: this.hasQuote && (this.todayQuote.coverKey ?? '').length > 0 ?
                  this.todayQuote.coverKey : 'cover_wisdom_ink',
                tileSize: 48,
                cornerRadius: 12
              })
              Column({ space: 4 }) {
                Text('今日文摘')
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text(`${CategoryEmojiUtil.weekdayMark()} 文以载道，墨韵生辉`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Column() {
                AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { WisdomHallNav.openQuoteSearch() })
            }
            .width('100%')

            Text('每日文摘')
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.hasQuote) {
              Column({ space: Theme.space.s4 }) {
                Text(`「${this.todayQuote.title}」`)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .lineHeight(40)
                Text(this.todayQuote.authorName.length > 0 ? `—— ${this.todayQuote.authorName}` : '')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .textAlign(TextAlign.End)
                if ((this.todayQuote.category ?? '').length > 0) {
                  Text(CategoryEmojiUtil.chipLabel(this.todayQuote.category))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }
                Row({ space: Theme.space.s4 }) {
                  Row({ space: 6 }) {
                    AppIcon({
                      name: 'heart',
                      iconSize: Theme.icon.md,
                      color: this.favorited ? Theme.colors().danger : Theme.colors().brandPrimary
                    })
                    Text(this.favorited ? '已收藏' : '收藏')
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Center)
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.toggleFavorite() })
                  Row({ space: 6 }) {
                    AppIcon({ name: 'arrow_up', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                    Text('分享')
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Center)
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.shareQuote() })
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s6)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .shadow({ radius: 8, color: 'rgba(26,42,58,0.08)', offsetY: 2 })
              .onClick((): void => { this.openQuoteDetail() })
            } else {
              AppEmpty({ title: '暂无今日语录', description: '下拉刷新重试' })
            }

            Row({ space: 6 }) {
              AppIcon({
                name: 'check',
                iconSize: Theme.icon.sm,
                color: this.readToday ? Theme.colors().success : Theme.colors().textTertiary
              })
              Text(this.readToday ? '今日已阅' : '点击卡片标记已阅')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            Row() {
              Text('分类导航')
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('按作者')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { WisdomHallNav.openAuthorList() })
            }
            .width('100%')

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.categories, (cat: string) => {
                  Text(CategoryEmojiUtil.chipLabel(cat))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { WisdomHallNav.openLibraryCategory(cat) })
                }, (cat: string) => cat)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Row() {
              Text('精选荐读')
                .fontSize(Theme.type.subtitleL)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandSecondary)
                .onClick((): void => {
                  AppStorage.setOrCreate('mainTabIndex', 0)
                  WisdomHallNav.openLibraryCategory('')
                })
            }
            .width('100%')

            if (this.reads.length === 0) {
              AppEmpty({ title: '暂无荐读', description: '下拉刷新重试' })
            } else {
              ForEach(this.reads.slice(0, 4), (item: WisdomItem) => {
                ReadListCard({
                  title: item.title,
                  summary: (item.summary ?? '').length > 0 ? item.summary : (item.description ?? ''),
                  category: (item.category ?? '').length > 0 ? item.category : '经史子集',
                  readMinutes: item.readMinutes > 0 ? item.readMinutes : 5,
                  coverKey: (item.coverKey ?? '').length > 0 ? item.coverKey : 'cover_reading',
                  onOpen: (): void => { WisdomHallNav.openDetail('read', item.id) }
                })
              }, (item: WisdomItem) => item.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .onRefreshing((): void => { void this.reload() })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
