import { Theme } from '../design-system/Theme'
import { GuideItem } from '../../models/EscapeModels'
import { EscapeMedia } from '../../services/EscapeMedia'

@Component
export struct GuideCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: GuideItem = new GuideItem()
  onTap: () => void = () => {}

  build() {
    Column() {
      Image(EscapeMedia.resource(this.item.coverKey))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.lg, topRight: Theme.radius.lg })
      Column({ space: 6 }) {
        Text(this.item.kindLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item.title)
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        Text(`${this.item.publishedAt} · ${this.item.readMinutes} 分钟`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(14)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Theme.colors().surfaceGlass)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .clip(true)
    .onClick(() => this.onTap())
  }
}
