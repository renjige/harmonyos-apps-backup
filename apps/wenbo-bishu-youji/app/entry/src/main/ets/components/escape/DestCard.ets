import { Theme } from '../design-system/Theme'
import { DestItem } from '../../models/EscapeModels'
import { EscapeMedia } from '../../services/EscapeMedia'

@Component
export struct DestCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: DestItem = new DestItem()
  onTap: () => void = () => {}

  private stars(): string {
    if (this.item.score >= 5) {
      return '推荐指数 5/5'
    }
    if (this.item.score >= 4) {
      return '推荐指数 4/5'
    }
    return '推荐指数 3/5'
  }

  build() {
    Column() {
      Image(EscapeMedia.resource(this.item.coverKey))
        .width('100%')
        .height(118)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.tempLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(`${this.item.altitude} · ${this.stars()}`)
          .fontSize(Theme.type.captionM)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.item.tags.length > 0) {
          Text(this.item.tags[0])
            .fontSize(Theme.type.captionM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
      }
      .padding(10)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Theme.colors().surfaceGlass)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .clip(true)
    .onClick(() => this.onTap())
  }
}
