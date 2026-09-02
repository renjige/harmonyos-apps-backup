import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WardrobeItemModel } from '../../models/WardrobeModels'
import { WardrobeMedia } from '../../services/WardrobeMedia'

@Component
export struct WardrobeItemCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: WardrobeItemModel = new WardrobeItemModel()
  onTap: (item: WardrobeItemModel) => void = () => {}

  build() {
    Column() {
      // Top visual cover area
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          AppIcon({
            name: WardrobeMedia.getCategoryIcon(this.item.category),
            iconSize: 42,
            color: Theme.colors().brandPrimary
          })
          .margin({ top: Theme.space.s4 })

          Text(this.item.category)
            .fontSize(Theme.type.caption1)
            .fontColor(Theme.colors().brandSecondary)
            .margin({ top: Theme.space.s2 })
        }
        .width('100%')
        .height(118)
        .backgroundColor(Theme.isDark() ? '#1A2926' : '#EBF6F2')
        .borderRadius({
          topLeft: Theme.radius.md,
          topRight: Theme.radius.md,
          bottomLeft: 6,
          bottomRight: 6
        })
        .justifyContent(FlexAlign.Center)

        // Color indicator pill in top right
        Row({ space: 4 }) {
          Circle({ width: 8, height: 8 })
            .fill(this.item.colorHex && this.item.colorHex.length > 0 ? this.item.colorHex : '#8FB8DE')
            .stroke(Theme.colors().surfaceCard)
            .strokeWidth(1)

          Text(this.item.color)
            .fontSize(Theme.type.caption2)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .margin({ top: 8, right: 8 })
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.06)', offsetY: 1 })
      }
      .width('100%')

      // Bottom info area
      Column({ space: 4 }) {
        Text(this.item.name)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(`${this.item.season} · ${this.item.scene}`)
            .fontSize(Theme.type.caption1)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          Blank()

          if (this.item.wearCount > 0) {
            Text(`穿过 ${this.item.wearCount} 次`)
              .fontSize(Theme.type.caption2)
              .fontColor(Theme.colors().brandSecondary)
          }
        }
        .width('100%')
      }
      .padding({ left: Theme.space.s3, right: Theme.space.s3, top: Theme.space.s3, bottom: Theme.space.s3 })
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({
      radius: 8,
      color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.04)',
      offsetY: 2
    })
    .onClick(() => this.onTap(this.item))
  }
}
