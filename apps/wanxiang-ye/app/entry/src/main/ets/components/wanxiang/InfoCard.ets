import { Theme } from '../design-system/Theme'
import { InfoItem } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct InfoCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Image(WanXiangMedia.coverResource(this.item.coverKey))
        .width('100%')
        .aspectRatio(4 / 5)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)

      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.item.summary)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.item.source)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Blank()
        Text(this.item.publishedAt)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
    .onClick((): void => this.onTap())
  }
}
