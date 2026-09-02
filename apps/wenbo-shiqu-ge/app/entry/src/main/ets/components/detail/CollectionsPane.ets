import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { ContentCard } from '../ContentCard'
import { DetailShell } from './DetailShell'
import { ArticleItem, CollectionItem } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionMedia } from '../../services/PavilionMedia'

@Component
export struct CollectionsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop collectionId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State list: CollectionItem[] = []
  @State articles: ArticleItem[] = []
  @State current: CollectionItem = new CollectionItem()
  @State detail: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.list = await PavilionBizService.loadCollections()
    const all = await PavilionBizService.loadArticles()
    if (this.collectionId.length > 0 && this.collectionId !== 'all') {
      const found = PavilionBizService.findCollection(this.collectionId)
      if (found !== undefined) {
        this.current = found
        this.articles = PavilionBizService.articlesOfCollection(found, all)
        this.detail = true
        return
      }
    }
    this.detail = false
  }

  build() {
    DetailShell({
      title: this.detail ? this.current.title : '专题合集',
      onClose: (): void => { PavilionDetailNav.close() }
    }) {
      if (this.detail) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Image(PavilionMedia.resource(this.current.coverKey))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
            Text(this.current.summary)
              .fontSize(14)
              .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
              .width('100%')
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
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else if (this.list.length === 0) {
        AppEmpty({
          title: '专题还没加载出来',
          description: '请检查网络后重试。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.list, (col: CollectionItem) => {
              Row({ space: 12 }) {
                Image(PavilionMedia.resource(col.coverKey))
                  .width(96)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text(col.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                    .width('100%')
                  Text(col.summary)
                    .fontSize(12)
                    .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(12)
              .onClick((): void => { PavilionDetailNav.openCollection(col.id) })
            }, (col: CollectionItem) => col.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
