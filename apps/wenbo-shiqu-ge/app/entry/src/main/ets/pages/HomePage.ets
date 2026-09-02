import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ContentCard } from '../components/ContentCard'
import { ArticleItem, CollectionItem } from '../models/PavilionModels'
import { PavilionBizService } from '../services/PavilionBizService'
import { PavilionDetailNav } from '../services/PavilionDetailNav'
import { PavilionMedia } from '../services/PavilionMedia'
import { ExploreToolsBar } from '../components/ExploreToolsBar'

class CatChip {
  id: string = 'all'
  label: string = '全部'
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop appName: string = '识趣阁'
  @Prop tagline: string = '发现生活中有趣的知识与智慧'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State articles: ArticleItem[] = []
  @State shown: ArticleItem[] = []
  @State collections: CollectionItem[] = []
  @State cat: string = 'all'
  @State loading: boolean = true
  private chips: CatChip[] = HomePage.buildChips()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static buildChips(): CatChip[] {
    const ids: string[] = ['all', 'fun', 'life', 'history', 'nature', 'art', 'science']
    const labels: string[] = ['全部', '趣味知识', '生活技巧', '历史文化', '自然探索', '艺术欣赏', '科普百科']
    const list: CatChip[] = []
    for (let i = 0; i < ids.length; i++) {
      const c = new CatChip()
      c.id = ids[i]
      c.label = labels[i]
      list.push(c)
    }
    return list
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      this.articles = await PavilionBizService.loadArticles()
      this.collections = await PavilionBizService.loadCollections()
      this.applyFilter()
    } catch {
      this.articles = []
      this.shown = []
    }
    this.loading = false
  }

  private applyFilter(): void {
    this.shown = PavilionBizService.filterByCategory(this.articles, this.cat)
  }

  private selectCat(id: string): void {
    this.cat = id
    this.applyFilter()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text(this.appName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
          Text(this.tagline)
            .fontSize(13)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.brandInk(this.themeEpoch, this.darkModeOn) })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { PavilionDetailNav.openSearch() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_bg'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [['rgba(61,52,44,0)', 0.2], ['rgba(61,52,44,0.78)', 1]]
              })
            Column({ space: 6 }) {
              Text('今日开卷')
                .fontSize(13)
                .fontColor('#F7F4F0')
              Text('把兴趣变成每天可完成的探索')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F7F4F0')
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .height(200)
          .borderRadius(12)
          .clip(true)

          Image($r('app.media.banner_01'))
            .width('100%')
            .height(112)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

          this.CollectionRow()
          ExploreToolsBar()

          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.chips, (chip: CatChip) => {
                Text(chip.label)
                  .fontSize(13)
                  .fontColor(this.cat === chip.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.cat === chip.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                  .borderRadius(8)
                  .onClick((): void => { this.selectCat(chip.id) })
              }, (chip: CatChip) => chip.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.shown.length === 0 && !this.loading) {
            AppEmpty({
              title: '这一类暂时还没有趣知',
              description: PavilionBizService.lastHint.length > 0 ? PavilionBizService.lastHint : '换个分类，或点击重新加载。',
              actionLabel: '重新加载',
              onAction: (): void => { void this.reload() }
            })
          } else {
            ForEach(this.shown, (row: ArticleItem) => {
              ContentCard({
                articleId: row.id,
                title: row.title,
                summary: row.summary,
                coverKey: row.coverKey,
                category: row.category,
                kind: row.kind,
                onOpen: (): void => { PavilionDetailNav.openArticle(row.id) }
              })
            }, (row: ArticleItem) => row.id)
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
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))
  }

  @Builder
  CollectionRow() {
    if (this.collections.length > 0) {
      Column({ space: 8 }) {
        Row() {
          Text('专题合集')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
          Blank()
          Text('全部')
            .fontSize(13)
            .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
            .onClick((): void => { PavilionDetailNav.openCollections() })
        }
        .width('100%')
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.collections, (col: CollectionItem) => {
              Column({ space: 6 }) {
                Image(PavilionMedia.resource(col.coverKey))
                  .width(148)
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(10)
                Text(col.title)
                  .fontSize(13)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .maxLines(1)
                  .width(148)
              }
              .onClick((): void => { PavilionDetailNav.openCollection(col.id) })
            }, (col: CollectionItem) => col.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
  }
}
