import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { GearMedia } from '../../services/GearMedia'

@Component
export struct GearListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop brand: string = ''
  @Prop weightText: string = ''
  @Prop coverKey: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(GearMedia.resource(this.coverKey))
        .width('100%')
        .height(110)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
      Text(this.title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(this.brand.length > 0 ? this.brand : '未填品牌')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
        .width('100%')
      Row() {
        Text(this.weightText)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Blank()
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
    }
    .width('100%')
    .padding(10)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(() => this.onTap())
  }
}
