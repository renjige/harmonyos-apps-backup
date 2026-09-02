import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { QuoteCard } from '../models/ZhiweiModels'
import { QuoteCatalog } from '../services/QuoteCatalog'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct MarketPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRev') refreshToken: number = 0
  @State quotes: QuoteCard[] = []
  @State favOnly: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    if (this.favOnly) {
      const all = QuoteCatalog.all()
      const fav: QuoteCard[] = []
      for (const q of all) {
        if (ZhiweiStore.isFavorite(q.id)) {
          fav.push(q)
        }
      }
      this.quotes = fav
      return
    }
    this.quotes = QuoteCatalog.todayQuotes()
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text('灵感集市')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.favOnly ? '我的收藏' : '今日更新')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text(this.favOnly ? '看今日' : '我的收藏')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => {
            this.favOnly = !this.favOnly
            this.reload()
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(ZhiweiMedia.bannerQuotes())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.12)', 0], ['rgba(26,26,46,0.78)', 1]]
              })
            Text('精选智慧金句，收藏后可随时回看')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F5F7FA')
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .height(160)
          .borderRadius(Theme.radius.md)
          .clip(true)

          if (this.quotes.length === 0) {
            AppEmpty({
              title: '收藏还是空的',
              description: '先去今日金句里收藏一句喜欢的。',
              actionLabel: '看今日金句',
              onAction: (): void => {
                this.favOnly = false
                this.reload()
              }
            })
          } else {
            ForEach(this.quotes, (q: QuoteCard) => {
              this.QuoteRow(q)
            }, (q: QuoteCard) => q.id)
          }
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
    .id(`market_${this.themeEpoch}`)
  }

  @Builder
  QuoteRow(q: QuoteCard) {
    Row({ space: Theme.space.s3 }) {
      Image(ZhiweiMedia.coverOf(q.coverKey))
        .width(72)
        .height(72)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(q.text)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${q.author} · ${q.theme}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => ZhiweiNav.openQuote(q.id))
  }
}
