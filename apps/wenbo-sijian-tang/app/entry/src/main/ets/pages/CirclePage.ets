import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FeaturedCard } from '../components/wisdom/FeaturedCard'
import { TagChips } from '../components/wisdom/TagChips'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { WisdomMedia } from '../services/WisdomMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct CirclePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State featured: WisdomItem[] = []
  @State filtered: WisdomItem[] = []
  @State friends: WisdomItem[] = []
  @State tagOptions: string[] = ['全部']
  @State filterTag: string = '全部'
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.featured = await WisdomHallBizService.loadFeatured()
    this.friends = await WisdomHallBizService.loadFriends()
    const tags = await WisdomHallBizService.loadTags()
    const opts: string[] = ['全部']
    for (const t of tags) {
      opts.push(t.title)
    }
    this.tagOptions = opts
    this.applyFilter()
  }

  private applyFilter(): void {
    if (this.filterTag === '全部') {
      this.filtered = this.featured
      return
    }
    const next: WisdomItem[] = []
    for (const item of this.featured) {
      if (item.tags.indexOf(this.filterTag) >= 0 || item.category === this.filterTag) {
        next.push(item)
      }
    }
    this.filtered = next
  }

  private async likeItem(id: string): Promise<void> {
    if (!AuthService.requireAuth('like_featured')) {
      this.onRequireAuth()
      return
    }
    await WisdomHallBizService.likeFeatured(id)
    void this.reload()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('思友圈')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Text('推荐思友')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX })

        Scroll() {
          Row({ space: Theme.space.s3 }) {
            ForEach(this.friends, (f: WisdomItem) => {
              Column({ space: 4 }) {
                Image(WisdomMedia.resource(f.coverKey))
                  .width(56)
                  .height(56)
                  .borderRadius(Theme.radius.pill)
                  .objectFit(ImageFit.Cover)
                Text(f.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
              }
              .width(72)
            }, (f: WisdomItem) => f.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Text('精选思考')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX })

        TagChips({
          selected: this.filterTag,
          options: this.tagOptions,
          onSelect: (name: string): void => {
            this.filterTag = name
            this.applyFilter()
          }
        })
        .padding({ left: Theme.space.pageX })

        if (this.filtered.length === 0) {
          AppEmpty({ title: '暂无精选', description: '' })
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        } else {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.filtered, (item: WisdomItem) => {
              FeaturedCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                authorName: item.authorName,
                likeCount: item.likeCount,
                coverKey: item.coverKey,
                cardWidth: '48%',
                onOpen: (): void => { WisdomHallNav.openDetail('featured', item.id) },
                onLike: (): void => { void this.likeItem(item.id) }
              })
              .margin({ bottom: Theme.space.s3 })
            }, (item: WisdomItem) => item.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column().height(Theme.space.s10).width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
