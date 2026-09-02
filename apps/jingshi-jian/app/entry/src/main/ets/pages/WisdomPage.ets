import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { WisdomQuote } from '../models/JianModels'
import { JianStore } from '../services/JianStore'
import { WisdomService } from '../services/WisdomService'

@Component
export struct WisdomPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State daily: WisdomQuote = new WisdomQuote()
  @State favorites: string[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.daily = await WisdomService.dailyQuote()
    this.favorites = await JianStore.favoriteQuoteIds()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async toggleFavorite(id: string): Promise<void> {
    const added = await JianStore.toggleFavoriteQuote(id)
    this.favorites = await JianStore.favoriteQuoteIds()
    this.showToast(added ? '已收藏笺语' : '已取消收藏')
  }

  private isFav(id: string): boolean {
    for (const f of this.favorites) {
      if (f === id) {
        return true
      }
    }
    return false
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text('智慧笺语')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          Column({ space: Theme.space.s3 }) {
            Text('今日陪伴')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text(this.daily.text)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
            Text(this.daily.hint)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            AppButton({
              label: this.isFav(this.daily.id) ? '已收藏' : '收藏此笺语',
              variant: 'secondary',
              onTap: (): void => { void this.toggleFavorite(this.daily.id) }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.xl)

          Column({ space: Theme.space.s3 }) {
            Text('清晨 · 日间 · 夜晚')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            ForEach(WisdomService.allForPeriod('morning'), (q: WisdomQuote) => {
              this.QuoteRow(q)
            }, (q: WisdomQuote) => q.id)
            ForEach(WisdomService.allForPeriod('day'), (q: WisdomQuote) => {
              this.QuoteRow(q)
            }, (q: WisdomQuote) => `d_${q.id}`)
            ForEach(WisdomService.allForPeriod('night'), (q: WisdomQuote) => {
              this.QuoteRow(q)
            }, (q: WisdomQuote) => `n_${q.id}`)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  QuoteRow(q: WisdomQuote) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(q.text)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(q.hint)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.isFav(q.id) ? '★' : '☆')
        .fontSize(18)
        .fontColor(Theme.colors().brandAccent)
        .onClick((): void => { void this.toggleFavorite(q.id) })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
