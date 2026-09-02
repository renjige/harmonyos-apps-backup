import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { DailyKnowItem, QuoteCard } from '../models/ZhiweiModels'
import { DailyKnowCatalog } from '../services/DailyKnowCatalog'
import { QuoteCatalog } from '../services/QuoteCatalog'
import { ZhiweiMedia } from '../services/ZhiweiMedia'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct ExplorePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRev') refreshToken: number = 0
  @State daily: DailyKnowItem = new DailyKnowItem()
  @State dailyRead: boolean = false
  @State quotes: QuoteCard[] = []
  @State catalog: DailyKnowItem[] = []
  @State favOnly: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.daily = DailyKnowCatalog.today()
    this.dailyRead = ZhiweiStore.isDailyRead(this.daily.id)
    this.catalog = DailyKnowCatalog.all()
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

  private previewCatalog(): DailyKnowItem[] {
    const out: DailyKnowItem[] = []
    let i = 0
    for (const row of this.catalog) {
      if (i >= 8) {
        break
      }
      out.push(row)
      i += 1
    }
    return out
  }

  build() {
    Column() {
      Text('探索')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image(ZhiweiMedia.coverOf(this.daily.coverKey))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.08)', 0], ['rgba(26,26,46,0.78)', 1]]
              })
            Column({ space: 6 }) {
              Text('每日一知')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F7FA')
                .width('100%')
              Text(this.daily.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
              Text(this.dailyRead ? '今日已读 ✓' : '点击阅读并打卡')
                .fontSize(Theme.type.caption)
                .fontColor('#E2E8F0')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 14, right: 14, bottom: 14 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(160)
          .borderRadius(Theme.radius.md)
          .clip(true)
          .onClick(() => ZhiweiNav.openDaily())

          Text(`知识目录 · 共 ${this.catalog.length} 篇`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Text('查看全部文库 →')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
            .width('100%')
            .onClick(() => ZhiweiNav.openKnowledgeCatalog())
          ForEach(this.previewCatalog(), (row: DailyKnowItem) => {
            Row({ space: 10 }) {
              Column({ space: 2 }) {
                Text(row.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(CategoryEmojiUtil.chipLabel(row.category))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colorOf(this.themeEpoch).textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onClick(() => ZhiweiNav.openDaily(row.id))
          }, (row: DailyKnowItem) => row.id)

          Row() {
            Text('灵感金句')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            Blank()
            Text(this.favOnly ? '看今日' : '我的收藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              .onClick(() => {
                this.favOnly = !this.favOnly
                this.reload()
              })
          }
          .width('100%')

          if (this.quotes.length === 0) {
            AppEmpty({
              title: this.favOnly ? '还没有收藏金句' : '今日金句加载中',
              description: '点进金句可收藏，并一键收进知识库。'
            })
          } else {
            ForEach(this.quotes, (q: QuoteCard) => {
              Column({ space: 8 }) {
                Text(`「${q.text}」`)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                  .width('100%')
                  .lineHeight(22)
                Text(`— ${q.author}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => ZhiweiNav.openQuote(q.id))
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
  }
}
