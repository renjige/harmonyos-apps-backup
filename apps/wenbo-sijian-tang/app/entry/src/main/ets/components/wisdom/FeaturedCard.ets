import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WisdomMedia } from '../../services/WisdomMedia'

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
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(WisdomMedia.resource(this.coverKey))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,46,0)', 0.2], ['rgba(26,26,46,0.72)', 1]]
          })
        Text(this.title)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F5F0E8')
          .maxLines(2)
          .padding({ left: 8, right: 8, bottom: 8 })
      }
      .width('100%')
      .borderRadius(Theme.radius.md)
      .clip(true)
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
