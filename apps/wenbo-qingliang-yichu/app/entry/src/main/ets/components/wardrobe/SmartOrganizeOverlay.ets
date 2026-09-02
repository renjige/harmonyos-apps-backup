import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeItemModel } from '../../models/WardrobeModels'
import { WardrobeLocalStore } from '../../services/WardrobeLocalStore'
import { WardrobeMedia, PresetColor } from '../../services/WardrobeMedia'

@Component
export struct SmartOrganizeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSelectItem: (item: WardrobeItemModel) => void = () => {}

  @State organizeMode: string = '季节' // 季节 / 类型 / 颜色 / 闲置整理
  @State selectedSubFilter: string = '全部'
  @State allItems: WardrobeItemModel[] = []

  aboutToAppear(): void {
    this.allItems = WardrobeLocalStore.getItems('全部')
  }

  private filteredItems(): WardrobeItemModel[] {
    if (this.organizeMode === '闲置整理') {
      // Filter items not worn or worn <= 1 times
      return this.allItems.filter((x) => x.wearCount <= 1)
    }
    if (this.organizeMode === '季节') {
      if (this.selectedSubFilter === '全部') return this.allItems
      return this.allItems.filter((x) => x.season.includes(this.selectedSubFilter) || x.season === '四季')
    }
    if (this.organizeMode === '类型') {
      if (this.selectedSubFilter === '全部') return this.allItems
      return this.allItems.filter((x) => x.category === this.selectedSubFilter)
    }
    if (this.organizeMode === '颜色') {
      if (this.selectedSubFilter === '全部') return this.allItems
      return this.allItems.filter((x) => x.color === this.selectedSubFilter)
    }
    return this.allItems
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // Background mask
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceMask)
        .onClick(() => this.onClose())

      // Sheet
      Column() {
        // Header
        Row() {
          Column() {
            Row({ space: 6 }) {
              AppIcon({ name: 'sparkle', iconSize: 20, color: Theme.colors().brandPrimary })
              Text('智慧整理与衣橱透视')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            Text('按多维度分类透视衣橱，定期整理，保持清爽有序')
              .fontSize(Theme.type.caption1)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .padding(8)
          .onClick(() => this.onClose())
        }
        .width('100%')
        .margin({ bottom: Theme.space.s4 })

        // Dimension Tabs
        Row({ space: 8 }) {
          ForEach(['季节', '类型', '颜色', '闲置整理'], (dim: string) => {
            Text(dim)
              .fontSize(Theme.type.subheadline)
              .fontWeight(this.organizeMode === dim ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.organizeMode === dim ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.organizeMode === dim ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.organizeMode = dim
                this.selectedSubFilter = '全部'
              })
          }, (dim: string) => dim)
        }
        .width('100%')
        .margin({ bottom: Theme.space.s3 })

        // Subfilter row
        if (this.organizeMode === '季节') {
          Row({ space: 6 }) {
            ForEach(['全部', '春季', '夏季', '秋季', '冬季'], (s: string) => {
              Text(s)
                .fontSize(Theme.type.caption1)
                .fontColor(this.selectedSubFilter === s ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                .fontWeight(this.selectedSubFilter === s ? FontWeight.Bold : FontWeight.Normal)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.selectedSubFilter === s ? (Theme.isDark() ? '#1C332D' : '#DDF2EB') : 'transparent')
                .borderRadius(Theme.radius.xs)
                .onClick(() => { this.selectedSubFilter = s })
            }, (s: string) => s)
          }
          .width('100%')
          .margin({ bottom: Theme.space.s3 })
        } else if (this.organizeMode === '类型') {
          Row({ space: 6 }) {
            ForEach(['全部', '上装', '下装', '连衣裙', '外套', '鞋履', '配饰'], (c: string) => {
              Text(c)
                .fontSize(Theme.type.caption1)
                .fontColor(this.selectedSubFilter === c ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                .fontWeight(this.selectedSubFilter === c ? FontWeight.Bold : FontWeight.Normal)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.selectedSubFilter === c ? (Theme.isDark() ? '#1C332D' : '#DDF2EB') : 'transparent')
                .borderRadius(Theme.radius.xs)
                .onClick(() => { this.selectedSubFilter = c })
            }, (c: string) => c)
          }
          .width('100%')
          .margin({ bottom: Theme.space.s3 })
        } else if (this.organizeMode === '闲置整理') {
          Row({ space: 6 }) {
            AppIcon({ name: 'alert', iconSize: 14, color: Theme.colors().semanticWarning })
            Text('以下单品记录穿着 ≤1 次，可考虑当季换洗或出清')
              .fontSize(Theme.type.caption2)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.isDark() ? '#2B261A' : '#FEF3C7')
          .borderRadius(Theme.radius.xs)
          .margin({ bottom: Theme.space.s3 })
        }

        // List of items in current perspective
        Scroll() {
          Column({ space: 8 }) {
            if (this.filteredItems().length === 0) {
              Column({ space: 6 }) {
                Text('没有匹配的单品')
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .padding(Theme.space.s6)
            } else {
              ForEach(this.filteredItems(), (item: WardrobeItemModel) => {
                Row({ space: 10 }) {
                  Circle({ width: 12, height: 12 })
                    .fill(item.colorHex || '#8FB8DE')

                  Column({ space: 2 }) {
                    Text(item.name)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

                    Text(`${item.category} · ${item.season} · ${item.scene}`)
                      .fontSize(Theme.type.caption1)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(item.wearCount > 0 ? `穿过 ${item.wearCount} 次` : '从未记录')
                    .fontSize(Theme.type.caption2)
                    .fontColor(item.wearCount > 0 ? Theme.colors().brandSecondary : Theme.colors().textTertiary)

                  AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().textTertiary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.isDark() ? '#1D2A27' : '#F7FAF8')
                .borderRadius(Theme.radius.md)
                .onClick(() => {
                  this.onClose()
                  this.onSelectItem(item)
                })
              }, (item: WardrobeItemModel) => item.id)
            }
          }
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        // Summary Bar
        Row() {
          Text(`当前视图共 ${this.filteredItems().length} 件单品`)
            .fontSize(Theme.type.caption1)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          Blank()

          AppButton({
            label: '完成整理',
            variant: 'primary',
            onTap: () => this.onClose()
          })
          .width(110)
        }
        .width('100%')
        .padding({ top: Theme.space.s3 })
      }
      .width('100%')
      .constraintSize({ maxHeight: '82%' })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({
        topLeft: Theme.radius.xl,
        topRight: Theme.radius.xl
      })
      .padding(Theme.space.cardPadding)
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: -4 })
    }
    .width('100%')
    .height('100%')
  }
}
