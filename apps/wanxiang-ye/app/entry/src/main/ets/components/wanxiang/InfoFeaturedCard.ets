import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { InfoCategory, InfoItem } from '../../models/InfoModels'
import { WanXiangMedia } from '../../services/WanXiangMedia'

@Component
export struct InfoFeaturedCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(WanXiangMedia.coverResource(this.item.coverKey))
          .width(128)
          .height(168)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)

        Text(`${InfoCategory.emojiOf(this.item.category)} ${InfoCategory.labelOf(this.item.category)}`)
          .fontSize(10)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,122,255,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin(8)
      }

      Column({ space: Theme.space.s2 }) {
        Text('头条推荐')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)

        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.item.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(3)
          .lineHeight(18)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.item.source)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Blank()
          Text(`${this.item.readMinutes} 分钟 · ${this.item.publishedAt}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')

        Row({ space: 4 }) {
          Text('阅读全文')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().brandPrimary })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(168)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({ radius: 16, color: 'rgba(0,122,255,0.08)', offsetY: 6 })
    .onClick((): void => this.onTap())
  }
}
