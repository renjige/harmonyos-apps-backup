import { Theme } from '../design-system/Theme'
import { PickupItem } from '../../models/ShiyiModels'
import { PickupKinds } from '../../services/MoodCatalog'

@Component
export struct PickupCardView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: PickupItem = new PickupItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(PickupKinds.labelOf(this.item.kind))
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(this.item.text)
        .fontSize(Theme.type.subtitleM)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s5)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .margin({ bottom: Theme.space.s4 })
    .onClick(() => this.onTap())
  }
}
