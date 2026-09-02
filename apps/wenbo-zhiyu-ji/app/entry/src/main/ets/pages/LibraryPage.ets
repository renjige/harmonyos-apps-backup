import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { QuoteListCard } from '../components/wisdom/QuoteListCard'
import { QuoteCategories } from '../models/QuoteCategories'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('libraryCategoryFilter') categoryFilter: string = ''
  @StorageLink('libraryAuthorFilter') authorFilter: string = ''
  @State allQuotes: WisdomItem[] = []
  @State visibleQuotes: WisdomItem[] = []
  @State page: number = 1
  @State keyword: string = ''
  @State categories: string[] = QuoteCategories.all()
  @State loading: boolean = false
  private readonly pageSize: number = 20

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.allQuotes = await WisdomHallBizService.loadAllQuotes()
    this.page = 1
    this.applyFilter()
    this.loading = false
  }

  private takeFirst(source: WisdomItem[], limit: number): WisdomItem[] {
    const out: WisdomItem[] = []
    let count = 0
    for (const item of source) {
      if (count >= limit) {
        break
      }
      out.push(item)
      count += 1
    }
    return out
  }

  private applyFilter(): void {
    const cat = this.categoryFilter.length > 0 ? this.categoryFilter : '全部'
    const filtered = WisdomHallBizService.filterQuotes(
      this.allQuotes, cat, this.keyword, this.authorFilter)
    const end = this.page * this.pageSize
    this.visibleQuotes = this.takeFirst(filtered, end)
  }

  private loadMore(): void {
    this.page += 1
    this.applyFilter()
  }

  private selectCategory(cat: string): void {
    this.categoryFilter = cat === '全部' ? '' : cat
    this.page = 1
    this.applyFilter()
  }

  private clearAuthor(): void {
    this.authorFilter = ''
    this.page = 1
    this.applyFilter()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Text('语录库')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { WisdomHallNav.openAuthorList() })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { WisdomHallNav.openQuoteSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.authorFilter.length > 0) {
        Row({ space: Theme.space.s2 }) {
          Text(`作者：${this.authorFilter}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .layoutWeight(1)
          Text('清除')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .onClick((): void => { this.clearAuthor() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      TextInput({ text: this.keyword, placeholder: '搜索正文或作者' })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .onChange((v: string) => {
          this.keyword = v
          this.page = 1
          this.applyFilter()
        })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.CategoryChip('全部')
          ForEach(this.categories, (cat: string) => {
            this.CategoryChip(cat)
          }, (cat: string) => cat)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Refresh({ refreshing: this.loading, offset: 64, friction: 100 }) {
        if (this.visibleQuotes.length === 0 && !this.loading) {
          AppEmpty({ title: '暂无语录', description: '切换分类或调整搜索词' })
            .layoutWeight(1)
        } else {
          List({ space: Theme.space.s4 }) {
            ForEach(this.visibleQuotes, (item: WisdomItem) => {
              ListItem() {
                QuoteListCard({
                  item: item,
                  onOpen: (): void => { WisdomHallNav.openDetail('quote', item.id) }
                })
              }
            }, (item: WisdomItem) => item.id)
            if (this.visibleQuotes.length >= this.page * this.pageSize) {
              ListItem() {
                Text('加载更多')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(Theme.space.s4)
                  .onClick((): void => { this.loadMore() })
              }
            }
          }
          .layoutWeight(1)
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s10
          })
        }
      }
      .layoutWeight(1)
      .onRefreshing((): void => { void this.reload() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  CategoryChip(cat: string) {
    Text(CategoryEmojiUtil.chipLabel(cat))
      .fontSize(Theme.type.caption)
      .fontColor((this.categoryFilter === cat || (cat === '全部' && this.categoryFilter.length === 0)) ?
        Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor((this.categoryFilter === cat || (cat === '全部' && this.categoryFilter.length === 0)) ?
        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectCategory(cat) })
  }
}
