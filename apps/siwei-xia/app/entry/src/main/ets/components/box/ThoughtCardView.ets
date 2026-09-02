import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { BoxMedia } from '../../services/BoxMedia'

@Component
export struct ThoughtCardView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop previewText: string = ''
  @Prop tagsLabel: string = ''
  @Prop shelfLabel: string = ''
  @Prop timeLabel: string = ''
  @Prop imagePath: string = ''
  @Prop linked: boolean = false
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.imagePath.length > 0 && ImagePathUtil.isReadable(this.imagePath)) {
        Image(ImagePathUtil.toDisplayUri(this.imagePath))
          .width(80)
          .height(80)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
      } else {
        Image(BoxMedia.resource('cover_cards'))
          .width(80)
          .height(80)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
      }
      Column({ space: 4 }) {
        Text(this.previewText)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          if (this.shelfLabel.length > 0) {
            Text(this.shelfLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          if (this.linked) {
            Text('已加工')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          Text(this.tagsLabel.length > 0 ? this.tagsLabel : '未分类')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().labelOnContainer)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        Text(this.timeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onOpen() })
  }
}
