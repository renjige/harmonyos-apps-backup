import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { WardrobeItemModel, WardrobeSummaryModel } from '../models/WardrobeModels'
import { WardrobeLocalStore } from '../services/WardrobeLocalStore'
import { WardrobeBizService } from '../services/WardrobeBizService'
import { WardrobeMedia } from '../services/WardrobeMedia'
import { WardrobeItemCard } from '../components/wardrobe/WardrobeItemCard'
import { AddItemDialog } from '../components/wardrobe/AddItemDialog'
import { ItemDetailOverlay } from '../components/wardrobe/ItemDetailOverlay'
import { SmartOrganizeOverlay } from '../components/wardrobe/SmartOrganizeOverlay'

@Component
export struct WardrobePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '清凉衣橱'
  @Prop tagline: string = '整理衣物，也整理每天的心情'
  onOpenMessages: () => void = () => {}
  onNavigateToOutfitWithItem?: (item: WardrobeItemModel) => void

  @State currentCategory: string = '全部'
  @State items: WardrobeItemModel[] = []
  @State summary: WardrobeSummaryModel = new WardrobeSummaryModel()
  @State isRefreshing: boolean = false

  // Modals state
  @State showAddDialog: boolean = false
  @State isEditMode: boolean = false
  @State selectedItem?: WardrobeItemModel = undefined
  @State showDetailOverlay: boolean = false
  @State showOrganizeOverlay: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.loadData()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2500)
  }

  private loadData(): void {
    this.isRefreshing = true
    this.items = WardrobeLocalStore.getItems(this.currentCategory)
    this.summary = WardrobeLocalStore.getSummary()
    this.isRefreshing = false
  }

  private handleSelectCategory(cat: string): void {
    this.currentCategory = cat
    this.items = WardrobeLocalStore.getItems(cat)
  }

  private handleSaveItem(item: WardrobeItemModel): void {
    if (this.isEditMode) {
      void WardrobeBizService.updateItem(item)
      this.showToast('已保存修改')
    } else {
      void WardrobeBizService.addItem(item)
      this.showToast('添加成功')
    }
    this.showAddDialog = false
    this.selectedItem = undefined
    this.loadData()
  }

  private handleDeleteItem(id: string): void {
    void WardrobeBizService.deleteItem(id)
    this.selectedItem = undefined
    this.showDetailOverlay = false
    this.showToast('已删除单品')
    this.loadData()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          // 1. Top Header Area
          Row() {
            Column({ space: 2 }) {
              Text(this.appName)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Text(this.tagline)
                .fontSize(Theme.type.caption1)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Row({ space: 8 }) {
              // Smart Organize Button
              Row({ space: 4 }) {
                AppIcon({ name: 'sparkle', iconSize: 16, color: Theme.colors().brandPrimary })
                Text('智慧整理')
                  .fontSize(Theme.type.caption1)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.isDark() ? '#1C332D' : '#DDF2EB')
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.showOrganizeOverlay = true })

              // Messages notification icon
              Row() {
                AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
              }
              .padding(8)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.onOpenMessages())
            }
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          // 2. Wardrobe Overview Data Card
          Column({ space: Theme.space.s3 }) {
            Row() {
              Column({ space: 2 }) {
                Text('我的衣橱')
                  .fontSize(Theme.type.caption1)
                  .fontColor(Theme.colors().brandSecondary)
                Text(`${this.summary.totalItems} 件衣物`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              // Season Tag
              Text('夏季精选')
                .fontSize(Theme.type.caption2)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(Theme.isDark() ? '#1B3B32' : '#E0F3EC')
                .borderRadius(Theme.radius.xs)
            }
            .width('100%')

            // Category Count Chips Grid
            Row() {
              this.StatItem('上装', this.summary.tops)
              this.StatDivider()
              this.StatItem('下装', this.summary.bottoms)
              this.StatDivider()
              this.StatItem('连衣裙', this.summary.dresses)
              this.StatDivider()
              this.StatItem('鞋履', this.summary.shoes)
              this.StatDivider()
              this.StatItem('配饰', this.summary.accessories)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(Theme.isDark() ? '#1A2926' : '#F7FAF8')
            .borderRadius(Theme.radius.sm)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({
            radius: 12,
            color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
            offsetY: 2
          })

          // 3. Horizontal Category Filter Chips
          Scroll() {
            Row({ space: 8 }) {
              this.CategoryChip('全部')
              ForEach(WardrobeMedia.CATEGORIES, (cat: string) => {
                this.CategoryChip(cat)
              }, (cat: string) => cat)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          // 4. Clothing Items Grid (2 Columns)
          if (this.items.length === 0) {
            AppEmpty({
              title: '你的衣橱还是空的',
              description: '添加几件喜欢的衣物，开始整理你的专属衣橱。',
              actionLabel: '＋ 添加第一件衣物',
              onAction: () => {
                this.isEditMode = false
                this.selectedItem = undefined
                this.showAddDialog = true
              }
            })
            .margin({ top: Theme.space.s6, bottom: Theme.space.s6 })
          } else {
            GridRow({ columns: 2, gutter: { x: 10, y: 10 } }) {
              ForEach(this.items, (item: WardrobeItemModel) => {
                GridCol() {
                  WardrobeItemCard({
                    item: item,
                    onTap: (it: WardrobeItemModel) => {
                      this.selectedItem = it
                      this.showDetailOverlay = true
                    }
                  })
                }
              }, (item: WardrobeItemModel) => item.id)
            }
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pagePadding,
          right: Theme.space.pagePadding,
          bottom: 100
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfaceBackground)

      // 5. Floating Add Button (＋ 添加衣物)
      Row({ space: 6 }) {
        AppIcon({ name: 'add', iconSize: 18, color: '#FFFFFF' })
        Text('添加衣物')
          .fontSize(Theme.type.callout)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .padding({ left: 16, right: 18, top: 12, bottom: 12 })
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 20, bottom: 20 })
      .shadow({
        radius: 16,
        color: Theme.isDark() ? 'rgba(0,0,0,0.5)' : 'rgba(45,106,79,0.35)',
        offsetY: 6
      })
      .onClick(() => {
        this.isEditMode = false
        this.selectedItem = undefined
        this.showAddDialog = true
      })

      // Modals
      if (this.showAddDialog) {
        AddItemDialog({
          isEdit: this.isEditMode,
          editItem: this.selectedItem,
          onSave: (it: WardrobeItemModel) => this.handleSaveItem(it),
          onCancel: () => { this.showAddDialog = false }
        })
      }

      if (this.showDetailOverlay && this.selectedItem) {
        ItemDetailOverlay({
          item: this.selectedItem,
          onClose: () => {
            this.showDetailOverlay = false
            this.selectedItem = undefined
          },
          onEdit: (it: WardrobeItemModel) => {
            this.selectedItem = it
            this.isEditMode = true
            this.showDetailOverlay = false
            this.showAddDialog = true
          },
          onDelete: (id: string) => this.handleDeleteItem(id),
          onGenerateOutfitWithItem: (it: WardrobeItemModel) => {
            if (this.onNavigateToOutfitWithItem) {
              this.onNavigateToOutfitWithItem(it)
            }
          }
        })
      }

      if (this.showOrganizeOverlay) {
        SmartOrganizeOverlay({
          onClose: () => { this.showOrganizeOverlay = false },
          onSelectItem: (it: WardrobeItemModel) => {
            this.selectedItem = it
            this.showOrganizeOverlay = false
            this.showDetailOverlay = true
          }
        })
      }

      // Top Toast
      if (this.toastText.length > 0) {
        Column() {
          Row({ space: 8 }) {
            AppIcon({ name: 'check', iconSize: 16, color: '#FFFFFF' })
            Text(this.toastText)
              .fontSize(Theme.type.subheadline)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(31,41,39,0.92)')
          .borderRadius(Theme.radius.pill)
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .padding({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private StatItem(label: string, count: number) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(Theme.type.caption2)
        .fontColor(Theme.colors().textTertiary)
      Text(`${count}`)
        .fontSize(Theme.type.callout)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private StatDivider() {
    Divider()
      .vertical(true)
      .height(18)
      .color(Theme.colors().strokeHairline)
  }

  @Builder
  private CategoryChip(cat: string) {
    Text(cat)
      .fontSize(Theme.type.subheadline)
      .fontWeight(this.currentCategory === cat ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.currentCategory === cat ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentCategory === cat ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .shadow({
        radius: this.currentCategory === cat ? 8 : 4,
        color: this.currentCategory === cat ? 'rgba(45,106,79,0.2)' : 'rgba(0,0,0,0.03)',
        offsetY: 1
      })
      .onClick(() => this.handleSelectCategory(cat))
  }
}
