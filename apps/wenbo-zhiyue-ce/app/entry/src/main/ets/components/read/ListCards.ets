import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FolioMedia } from '../../services/FolioMedia'

@Component
export struct ExcerptListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop quote: string = ''
  @Prop meta: string = ''
  @Prop favorite: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.favorite ? '收藏摘录' : '摘录')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
        Blank()
        if (this.favorite) {
          AppIcon({ name: 'heart', iconSize: 16, color: Theme.colors().brandAccent })
        }
      }
      .width('100%')
      Text(this.quote)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(24)
        .width('100%')
      Text(this.meta)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
        .width('100%')
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct FolioGridCard {
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = 'cover_folio_study'
  @Prop countLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(FolioMedia.cover(this.coverKey))
        .width('100%')
        .height(110)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
      Text(this.title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .width('100%')
      Text(this.countLabel.length > 0 ? this.countLabel : this.summary)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onTap() })
  }
}
