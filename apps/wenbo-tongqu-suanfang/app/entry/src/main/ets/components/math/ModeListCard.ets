import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CatalogItem } from '../../models/MathModels'
import { MathMedia } from '../../services/MathMedia'

@Component
export struct ModeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CatalogItem = new CatalogItem()
  @Prop locked: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s4 }) {
      Image(MathMedia.resource(this.item.coverKey))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Column({ space: Theme.space.s1 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item.summary.length > 0 ? this.item.summary : this.item.subtitle)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .width('100%')
        if (this.locked) {
          Text('先完成上一关才能开启')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 10, color: 'rgba(23,32,51,0.05)', offsetY: 2 })
    .opacity(this.locked ? 0.55 : 1)
    .onClick(() => {
      if (!this.locked) {
        this.onTap()
      }
    })
  }
}
