import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { InfoCategory, InfoItem } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct InfoRowCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(WanXiangMedia.coverResource(this.item.coverKey))
        .width(88)
        .height(110)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)

      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(InfoCategory.labelOf(this.item.category))
            .fontSize(10)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.xs)
          Text(`${this.item.readMinutes} 分钟阅读`)
            .fontSize(10)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }

        Text(this.item.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.item.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .lineHeight(18)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.item.source)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textPrimary })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => this.onTap())
  }
}

@Component
export struct InfoMiniCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Image(WanXiangMedia.coverResource(this.item.coverKey))
        .width(148)
        .height(100)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .width(148)
        Text(this.item.source)
          .fontSize(10)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .padding(10)
      .alignItems(HorizontalAlign.Start)
    }
    .width(148)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .onClick((): void => this.onTap())
  }
}
