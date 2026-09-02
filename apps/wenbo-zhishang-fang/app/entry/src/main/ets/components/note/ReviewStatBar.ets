import { Theme } from '../design-system/Theme'

/** 统计数字直连 AppStorage，避免隐藏 Tab / @Builder 不刷新 */
@Component
export struct ReviewStatBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('statTotalNotes') totalNotes: number = 0
  @StorageLink('statBookCount') bookCount: number = 0
  @StorageLink('statFavoriteCount') favoriteCount: number = 0

  build() {
    Row({ space: 8 }) {
      Column({ space: 4 }) {
        Text(`${this.totalNotes}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('总书摘')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Text(`${this.bookCount}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('已读书籍')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Text(`${this.favoriteCount}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('收藏')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
  }
}
