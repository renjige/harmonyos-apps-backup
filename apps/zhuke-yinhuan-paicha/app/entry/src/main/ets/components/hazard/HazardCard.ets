import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { HazardItem } from '../../models/HazardModels'
import { HazardMedia } from '../../services/HazardMedia'

@Component
export struct HazardCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: HazardItem = new HazardItem()
  onTap: (item: HazardItem) => void = (_i: HazardItem) => {}

  build() {
    Row({ space: 12 }) {
      Image(HazardMedia.cover(this.item.coverKey))
        .width(72)
        .height(72)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.item.location.length > 0 ? this.item.location : '位置待补充'} · ${this.item.category}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`发现时间：${this.item.foundLabel()}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 8 }) {
          Text(this.item.riskLabel())
            .fontSize(11)
            .fontColor(this.item.riskColor())
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(`${this.item.riskColor()}22`)
            .borderRadius(8)
          Text(this.item.statusLabel())
            .fontSize(11)
            .fontColor(this.item.statusColor())
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(`${this.item.statusColor()}22`)
            .borderRadius(8)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 8, color: 'rgba(22,50,79,0.06)', offsetY: 2, offsetX: 0 })
    .onClick(() => this.onTap(this.item))
  }
}
