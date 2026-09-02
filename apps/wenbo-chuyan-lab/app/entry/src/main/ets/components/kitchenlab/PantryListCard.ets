import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { PantryItem } from '../../models/KitchenLabModels'

@Component
export struct PantryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: PantryItem = new PantryItem()
  @Prop daysLeft: number = 999
  onTap: () => void = () => {}

  private expiryLabel(): string {
    if (this.item.expiryDate.length === 0) {
      return '未设保质期'
    }
    if (this.daysLeft < 0) {
      return '已过期'
    }
    if (this.daysLeft <= 3) {
      return `${this.daysLeft} 天内到期`
    }
    return this.item.expiryDate
  }

  private expiryColor(): string {
    if (this.daysLeft < 0) {
      return Theme.colors().danger
    }
    if (this.daysLeft <= 3) {
      return Theme.colors().warning
    }
    return Theme.colors().textSecondary
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
      }
      .width('100%')
      if (this.item.category.length > 0) {
        Text(this.item.category)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      }
      Text(`${this.item.quantity}${this.item.unit}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.expiryLabel())
        .fontSize(Theme.type.caption)
        .fontColor(this.expiryColor())
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
