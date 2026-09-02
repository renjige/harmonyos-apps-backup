import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeMedia } from '../../services/KnowledgeMedia'
import { KnowledgeTime } from '../../services/CategorySuggest'

@Component
export struct KnowledgeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = ''
  @Prop tags: string = ''
  @Prop coverKey: string = 'cover_other'
  @Prop updatedAt: number = 0
  @Prop favorited: boolean = false
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack() {
        Image(KnowledgeMedia.resource(this.coverKey))
          .width(84)
          .height(84)
          .objectFit(ImageFit.Cover)
      }
      .width(84)
      .height(84)
      .borderRadius(Theme.radius.sm)
      .clip(true)

      Column({ space: 4 }) {
        Text(this.category)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
          .maxLines(1)
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: Theme.space.s2 }) {
          Text(this.tags.length > 0 ? this.tags : KnowledgeTime.formatShort(this.updatedAt))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.favorited) {
            AppIcon({ name: 'bookmark', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
          }
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .constraintSize({ minWidth: 0 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .clip(true)
    .onClick((): void => { this.onOpen() })
  }
}
