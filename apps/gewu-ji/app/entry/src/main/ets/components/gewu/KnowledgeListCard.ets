import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeObject } from '../../models/KnowledgeModels'
import { GewuMedia } from '../../services/GewuMedia'

@Component
export struct KnowledgeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: KnowledgeObject = new KnowledgeObject()
  @Prop readBadge: string = ''
  @Prop showChevron: boolean = true
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(GewuMedia.coverResource(this.item.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)

      Column({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s2 }) {
          Text(this.item.category)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.xs)
          if (this.item.atlasKind.length > 0) {
            Text(this.item.atlasKind)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          if (this.readBadge.length > 0) {
            Text('已读')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().success)
          }
        }
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .lineHeight(18)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.showChevron) {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 8, color: 'rgba(26,58,92,0.06)', offsetY: 2 })
    .onClick((): void => { this.onTap() })
  }
}
