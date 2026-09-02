import { Theme } from '../design-system/Theme'
import { EssayItem } from '../../models/EssayModels'
import { DawnMedia } from '../../services/DawnMedia'
import { EssayDateUtil } from '../../services/EssayDateUtil'

@Component
export struct EssayListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: EssayItem = new EssayItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Image(DawnMedia.cover(this.item.coverKey))
        .width('100%')
        .height(128)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Text(this.item.displayTitle())
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.item.content.length > 0) {
        Text(this.item.preview())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      Row({ space: 8 }) {
        Text(EssayDateUtil.cardTime(this.item.createdAt))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        if (this.item.weather.length > 0) {
          Text(this.item.weather)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        Blank()
        ForEach(this.item.tagList(), (tag: string) => {
          Text(`#${tag}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 12, color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(61,50,40,0.06)', offsetY: 2, offsetX: 0 })
    .onClick((): void => { this.onTap() })
  }
}
