import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { ArticleItem } from '../models/PavilionModels'
import { DailyItem } from '../models/PavilionModels'
import { PavilionBizService } from '../services/PavilionBizService'
import { PavilionDetailNav } from '../services/PavilionDetailNav'
import { PavilionStore } from '../services/PavilionStore'
import { ExploreAlbum, ExploreStore } from '../services/ExploreStore'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State articles: ArticleItem[] = []
  @State dailyRows: DailyItem[] = []
  @State albums: ExploreAlbum[] = []
  @State albumId: string = 'all'
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const all = await PavilionBizService.loadArticles()
    const days = await PavilionBizService.loadDaily()
    this.albums = ExploreStore.albumList()
    const ids = this.selectedIds()
    const arts: ArticleItem[] = []
    const dailies: DailyItem[] = []
    for (const id of ids) {
      if (id.indexOf('daily:') === 0) {
        const did = id.substring(6)
        for (const d of days) {
          if (d.id === did) {
            dailies.push(d)
          }
        }
      } else {
        for (const a of all) {
          if (a.id === id) {
            arts.push(a)
          }
        }
      }
    }
    this.articles = arts
    this.dailyRows = dailies
    this.loading = false
  }

  private selectedIds(): string[] {
    if (this.albumId === 'all') {
      return PavilionStore.favoriteIds()
    }
    for (const a of this.albums) {
      if (a.id === this.albumId) {
        return a.ids.length > 0 ? a.ids.split(',') : []
      }
    }
    return []
  }

  private selectAlbum(id: string): void {
    this.albumId = id
    void this.reload()
  }

  build() {
    Column() {
      Text('收藏夹')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      Text('收藏与夹子只存在本机，可按主题整理')
        .fontSize(13)
        .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Row({ space: 8 }) {
          Text('全部')
            .fontSize(13)
            .fontColor(this.albumId === 'all' ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.albumId === 'all' ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
            .borderRadius(8)
            .onClick((): void => { this.selectAlbum('all') })
          ForEach(this.albums, (a: ExploreAlbum) => {
            Text(a.title)
              .fontSize(13)
              .fontColor(this.albumId === a.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.albumId === a.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
              .borderRadius(8)
              .onClick((): void => { this.selectAlbum(a.id) })
          }, (a: ExploreAlbum) => a.id)
          Text('管理夹子')
            .fontSize(13)
            .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .onClick((): void => { PavilionDetailNav.openAlbums('all') })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.articles.length === 0 && this.dailyRows.length === 0 && !this.loading) {
        AppEmpty({
          title: '这一夹还是空的',
          description: '读到喜欢的一篇，点收藏后再收入夹子。新用户可见空分类：奇闻趣事、生活妙招、科普知识、文化故事。',
          actionLabel: '去首页看看',
          onAction: (): void => { PavilionDetailNav.switchTab(0) }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.dailyRows, (row: DailyItem) => {
              Row() {
                Text('每日一趣')
                  .fontSize(11)
                  .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                Text(row.title)
                  .fontSize(16)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .maxLines(1)
                  .layoutWeight(1)
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(12)
              .onClick((): void => { PavilionDetailNav.openDaily(row.id) })
            }, (row: DailyItem) => row.id)
            ForEach(this.articles, (row: ArticleItem) => {
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
    .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))
  }
}
