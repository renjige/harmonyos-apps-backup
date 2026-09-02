import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoMaterial } from '../../models/RenoModels'

@Component
export struct MaterialRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoMaterial = new RenoMaterial()
  onOpen: (item: RenoMaterial) => void = (_i: RenoMaterial) => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        AppIcon({ name: 'biz', iconSize: 18, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .borderRadius(12)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .justifyContent(FlexAlign.Center)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .width('100%')
        Text(`${this.item.spec.length > 0 ? this.item.spec : '规格待填'} · ${this.item.room.length > 0 ? this.item.room : '房间待填'}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(RenoDates.materialLabel(this.item.status))
        .fontSize(Theme.type.caption)
        .fontColor(this.item.status === 'pending' ? Theme.colors().warning : Theme.colors().brandPrimary)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onOpen(this.item))
  }
}
