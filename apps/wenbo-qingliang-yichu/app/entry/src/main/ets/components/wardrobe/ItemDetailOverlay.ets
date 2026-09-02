import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeItemModel } from '../../models/WardrobeModels'
import { WardrobeMedia } from '../../services/WardrobeMedia'

@Component
export struct ItemDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: WardrobeItemModel = new WardrobeItemModel()
  onClose: () => void = () => {}
  onEdit: (item: WardrobeItemModel) => void = () => {}
  onDelete: (id: string) => void = () => {}
  onGenerateOutfitWithItem: (item: WardrobeItemModel) => void = () => {}

  @State showDeleteConfirm: boolean = false

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // Background mask
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceMask)
        .onClick(() => this.onClose())

      // Detail Sheet
      Column() {
        // Top Nav
        Row() {
          Row({ space: 4 }) {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            Text('衣物详情')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .onClick(() => this.onClose())

          Blank()

          Row({ space: 8 }) {
            Row() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            }
            .padding(8)
            .onClick(() => this.onClose())
          }
        }
        .width('100%')
        .margin({ bottom: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            // Visual Banner
            Column() {
              AppIcon({
                name: WardrobeMedia.getCategoryIcon(this.item.category),
                iconSize: 56,
                color: Theme.colors().brandPrimary
              })

              Text(this.item.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .margin({ top: Theme.space.s3 })

              Row({ space: 8 }) {
                Row({ space: 4 }) {
                  Circle({ width: 10, height: 10 })
                    .fill(this.item.colorHex || '#8FB8DE')
                  Text(this.item.color)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }

                Text('·')
                  .fontColor(Theme.colors().textTertiary)

                Text(this.item.category)
                  .fontSize(Theme.type.caption1)
                  .fontColor(Theme.colors().brandSecondary)
                  .fontWeight(FontWeight.Medium)

                Text('·')
                  .fontColor(Theme.colors().textTertiary)

                Text(`${this.item.season} · ${this.item.scene}`)
                  .fontSize(Theme.type.caption1)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .margin({ top: Theme.space.s2 })
            }
            .width('100%')
            .padding({ top: Theme.space.s6, bottom: Theme.space.s6 })
            .backgroundColor(Theme.isDark() ? '#1A2926' : '#EBF6F2')
            .borderRadius(Theme.radius.lg)
            .justifyContent(FlexAlign.Center)

            // Information details card
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('穿着记录')
                  .fontSize(Theme.type.subheadline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Blank()
                Text(this.item.wearCount > 0 ? `已记录 ${this.item.wearCount} 次` : '暂无穿着记录')
                  .fontSize(Theme.type.subheadline)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')

              if (this.item.lastWornAt && this.item.lastWornAt.length > 0) {
                Row() {
                  Text('最近穿着')
                    .fontSize(Theme.type.subheadline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Blank()
                  Text(this.item.lastWornAt)
                    .fontSize(Theme.type.subheadline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                }
                .width('100%')
              }

              if (this.item.remark && this.item.remark.length > 0) {
                Column({ space: 4 }) {
                  Text('备注说明')
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(this.item.remark)
                    .fontSize(Theme.type.subheadline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding({ top: 4 })
              }
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceElevated)
            .borderRadius(Theme.radius.md)

            // Smart Styling suggestion preview
            Column({ space: 6 }) {
              Row({ space: 6 }) {
                AppIcon({ name: 'sparkle', iconSize: 18, color: Theme.colors().brandPrimary })
                Text('搭配灵感建议')
                  .fontSize(Theme.type.callout)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')

              Text(`此单品适宜在 ${this.item.season} 进行 ${this.item.scene} 搭配。推荐与中性浅色、米白或大地色单品呼应，营造自然放松的秩序美感。`)
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(20)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.isDark() ? '#1D2A27' : '#F4FAF7')
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().brandSecondary + '33' })
          }
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        // Bottom Actions
        Column({ space: Theme.space.s2 }) {
          AppButton({
            label: '以该单品生成智慧穿搭',
            variant: 'primary',
            onTap: () => {
              this.onClose()
              this.onGenerateOutfitWithItem(this.item)
            }
          })

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '编辑单品',
              variant: 'secondary',
              onTap: () => {
                this.onClose()
                this.onEdit(this.item)
              }
            }).layoutWeight(1)

            AppButton({
              label: '删除单品',
              variant: 'danger',
              onTap: () => { this.showDeleteConfirm = true }
            }).layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s3 })
      }
      .width('100%')
      .constraintSize({ maxHeight: '80%' })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({
        topLeft: Theme.radius.xl,
        topRight: Theme.radius.xl
      })
      .padding(Theme.space.cardPadding)
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: -4 })

      // Delete confirmation modal
      if (this.showDeleteConfirm) {
        Column() {
          Column({ space: Theme.space.s3 }) {
            Text('确认删除该单品？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

            Text(`删除「${this.item.name}」后将无法恢复，相关穿搭中将不再推荐该单品。`)
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .textAlign(TextAlign.Center)
              .lineHeight(20)

            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: () => { this.showDeleteConfirm = false }
              }).layoutWeight(1)

              AppButton({
                label: '确认删除',
                variant: 'danger',
                onTap: () => {
                  this.showDeleteConfirm = false
                  this.onDelete(this.item.id)
                  this.onClose()
                }
              }).layoutWeight(1)
            }
            .width('100%')
            .margin({ top: Theme.space.s2 })
          }
          .width('88%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({ radius: 24, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.45)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
