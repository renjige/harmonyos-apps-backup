import { Theme } from '../design-system/Theme'
import { InfoCategory, InfoItem } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct InfoGridCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(WanXiangMedia.coverResource(this.item.coverKey))
          .width('100%')
          .aspectRatio(4 / 5)
          .objectFit(ImageFit.Cover)

        Text(InfoCategory.labelOf(this.item.category))
          .fontSize(10)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(88,86,214,0.92)')
          .borderRadius(Theme.radius.pill)
          .margin(8)
      }
      .width('100%')
      .clip(true)

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.item.summary)
          .fontSize(11)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .lineHeight(16)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(this.item.source)
            .fontSize(10)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .maxLines(1)
            .layoutWeight(1)
          Text(`${this.item.readMinutes}′`)
            .fontSize(10)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .padding({ left: 10, right: 10, top: 10, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .shadow({ radius: 10, color: 'rgba(15,23,42,0.06)', offsetY: 3 })
    .onClick((): void => this.onTap())
  }
}
