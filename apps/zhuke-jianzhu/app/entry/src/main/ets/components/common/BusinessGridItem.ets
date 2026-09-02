import { Theme } from '../design-system/Theme'
import { BusinessItem } from '../../models/ZhukeModels'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct BusinessGridItem {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: BusinessItem = new BusinessItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'biz', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Text(this.item.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Center)

      Text(this.item.summary)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onTap())
  }
}
