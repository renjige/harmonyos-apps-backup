import { Theme } from '../design-system/Theme'
import { StatusTag } from './StatusTag'
import { InspectRecord, InspectMedia } from '../../models/InspectModels'
import { InspectLocalStore } from '../../services/InspectLocalStore'

@Component
export struct InspectListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InspectRecord = new InspectRecord()
  @Prop stamp: string = ''
  onTap: () => void = () => {}

  build() {
    Row() {
      Image(InspectMedia.cover(this.item.category))
        .width(52)
        .height(52)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .border({ width: 1, color: Theme.colors().strokeHairline })

      Column({ space: 4 }) {
        Text(this.item.materialName)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.item.spec.length > 0 ? this.item.spec : this.item.category}  ·  ${this.item.supplier.length > 0 ? this.item.supplier : this.item.category}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(InspectLocalStore.displayTime(this.item.updatedAt.length > 0 ? this.item.updatedAt : this.item.createdAt))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      StatusTag({ result: this.item.result, compact: true })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .opacity(this.stamp.length >= 0 ? 1 : 1)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
