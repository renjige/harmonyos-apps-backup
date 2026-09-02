import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { SymbolHero } from '../design-system/SymbolVisual'

@Component
export struct FeaturedCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop authorName: string = ''
  @Prop likeCount: number = 0
  @Prop coverKey: string = 'cover_circle_1'
  @Prop cardWidth: string = '48%'
  onOpen: () => void = () => {}
  onLike: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      SymbolHero({
        category: '灵感',
        coverKey: this.coverKey,
        bannerHeight: 120,
        title: this.title,
        compact: true
      })
      .onClick((): void => { this.onOpen() })

      Text(this.authorName)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        Text(`${this.likeCount} 赞`)
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
          .layoutWeight(1)
        AppButton({
          label: '赞',
          variant: 'ghost',
          onTap: (): void => { this.onLike() }
        })
      }
      .width('100%')
    }
    .width(this.cardWidth)
  }
}
