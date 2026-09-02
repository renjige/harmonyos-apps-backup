import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeOutfitModel } from '../../models/WardrobeModels'

@Component
export struct OutfitCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop outfit: WardrobeOutfitModel = new WardrobeOutfitModel()
  onRefresh: () => void = () => {}
  onToggleSave: (outfit: WardrobeOutfitModel) => void = () => {}
  onLogToday: (outfit: WardrobeOutfitModel) => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      // Header with Title & Tags
      Row() {
        Column({ space: 4 }) {
          Text(this.outfit.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          Row({ space: 6 }) {
            Text(`${this.outfit.weather}天适用`)
              .fontSize(Theme.type.caption2)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
              .borderRadius(Theme.radius.xs)

            Text(this.outfit.style)
              .fontSize(Theme.type.caption2)
              .fontColor(Theme.colors().brandSecondary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.isDark() ? '#1D2A27' : '#E8F5F1')
              .borderRadius(Theme.radius.xs)

            Text(this.outfit.scene)
              .fontSize(Theme.type.caption2)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.isDark() ? '#22302D' : '#F2F6F4')
              .borderRadius(Theme.radius.xs)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // Save favorite button
        Row() {
          AppIcon({
            name: this.outfit.isSaved ? 'star' : 'star',
            iconSize: 22,
            color: this.outfit.isSaved ? '#E5A93C' : Theme.colors().textTertiary
          })
        }
        .padding(8)
        .backgroundColor(this.outfit.isSaved ? (Theme.isDark() ? '#3D311A' : '#FEF3C7') : 'transparent')
        .borderRadius(Theme.radius.pill)
        .onClick(() => this.onToggleSave(this.outfit))
      }
      .width('100%')

      // Outfit Items Breakdown Grid
      Column({ space: Theme.space.s2 }) {
        if (this.outfit.dressName && this.outfit.dressName.length > 0) {
          // Dress mode
          this.ItemRow('连衣裙', this.outfit.dressName, 'star')
        } else {
          if (this.outfit.topName && this.outfit.topName.length > 0) {
            this.ItemRow('上装', this.outfit.topName, 'hanger')
          }
          if (this.outfit.bottomName && this.outfit.bottomName.length > 0) {
            this.ItemRow('下装', this.outfit.bottomName, 'wardrobe')
          }
        }

        if (this.outfit.shoesName && this.outfit.shoesName.length > 0) {
          this.ItemRow('鞋履', this.outfit.shoesName, 'wardrobe')
        }

        if (this.outfit.accessoryName && this.outfit.accessoryName.length > 0) {
          this.ItemRow('配饰/外搭', this.outfit.accessoryName, 'sparkle')
        }
      }
      .width('100%')
      .padding(Theme.space.s3)
      .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
      .borderRadius(Theme.radius.md)

      // Styling Tips box
      if (this.outfit.tips && this.outfit.tips.length > 0) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            AppIcon({ name: 'sparkle', iconSize: 14, color: Theme.colors().brandPrimary })
            Text('搭配点拨')
              .fontSize(Theme.type.caption1)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }

          Text(this.outfit.tips)
            .fontSize(Theme.type.caption1)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(18)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.isDark() ? '#1D2A27' : '#EFF7F4')
        .borderRadius(Theme.radius.sm)
      }

      // Actions
      Row({ space: Theme.space.s3 }) {
        AppButton({
          label: '换一套',
          variant: 'secondary',
          onTap: () => this.onRefresh()
        }).layoutWeight(1)

        AppButton({
          label: '记录为今日穿搭',
          variant: 'primary',
          onTap: () => this.onLogToday(this.outfit)
        }).layoutWeight(1.3)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({
      radius: 16,
      color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(10,37,64,0.06)',
      offsetY: 2
    })
  }

  @Builder
  private ItemRow(categoryLabel: string, itemName: string, iconName: string) {
    Row({ space: 10 }) {
      AppIcon({
        name: iconName === 'hanger' ? 'hanger' : (iconName === 'star' ? 'star' : (iconName === 'sparkle' ? 'sparkle' : 'wardrobe')),
        iconSize: 18,
        color: Theme.colors().brandPrimary
      })

      Text(categoryLabel)
        .fontSize(Theme.type.caption1)
        .fontColor(Theme.colors().brandSecondary)
        .width(64)

      Text(itemName)
        .fontSize(Theme.type.callout)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }
}
