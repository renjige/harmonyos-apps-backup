import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ShoppingItem } from '../../models/ShoppingModels'
import { CategorySuggest } from '../../services/CategorySuggest'
import { ShoppingCatalog } from '../../services/ShoppingCatalog'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct ItemDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop listId: string = ''
  @State item: ShoppingItem = new ShoppingItem()
  @State loaded: boolean = false
  @State isFav: boolean = false
  @State title: string = ''
  @State category: string = ''
  @State qty: string = ''
  @State remark: string = ''
  @State estPrice: string = ''
  @State paidPrice: string = ''
  @State tag: string = ''
  @State assignee: string = ''
  onClose: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onDataChange: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    for (const it of await ShoppingService.items(this.listId)) {
      if (it.id === this.itemId) {
        this.item = it
        this.loaded = true
        this.title = it.title
        this.category = it.category
        this.qty = it.qty
        this.remark = it.remark
        this.estPrice = it.estPrice
        this.paidPrice = it.paidPrice
        this.tag = it.tag
        this.assignee = it.assignee
        this.isFav = GrowthService.isFavorite('item', it.id)
        return
      }
    }
    this.loaded = false
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('物品详情')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      if (!this.loaded) {
        Text('物品不存在或已删除')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .padding(20)
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(this.item.completed ? '已勾选完成' : '待购买')
              .fontSize(Theme.type.subhead)
              .fontColor(this.item.completed ? Theme.colors().brandPrimary : Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '物品名称' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => {
                this.title = v
                if (this.category.length === 0) {
                  this.category = CategorySuggest.suggest(v)
                }
              })
            TextInput({ text: this.category, placeholder: '分类' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.category = v })
            TextInput({ text: this.qty, placeholder: '数量' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.qty = v })
            TextInput({ text: this.estPrice, placeholder: '预估价格（元）' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.estPrice = v })
            TextInput({ text: this.paidPrice, placeholder: '实付价格（元）' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.paidPrice = v })
            TextInput({ text: this.tag, placeholder: '标签' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.tag = v })
            TextInput({ text: this.assignee, placeholder: '负责人（可选）' })
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.assignee = v })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(GrowthService.assigneePresets(), (name: string) => {
                Text(name)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.assignee === name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .backgroundColor(this.assignee === name ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.assignee = name })
              }, (name: string) => name)
            }
            .width('100%')
            TextInput({ text: this.remark, placeholder: '备注' })
              .height(72)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 14, right: 14 })
              .onChange((v: string) => { this.remark = v })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(ShoppingCatalog.itemTags(), (t: string) => {
                Text(t)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.tag === t ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .backgroundColor(this.tag === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.tag = t })
              }, (t: string) => t)
            }
            .width('100%')
            AppButton({
              label: '保存修改',
              onTap: (): void => {
                void ShoppingService.updateItem(this.itemId, this.title, this.category, this.qty, this.remark,
                  this.estPrice, this.paidPrice, this.tag, this.assignee).then((ok) => {
                  if (ok) {
                    void this.reload()
                    this.onDataChange()
                  }
                })
              }
            })
            AppButton({
              label: this.item.completed ? '取消勾选' : '标记已购',
              variant: 'secondary',
              onTap: (): void => {
                void ShoppingService.toggleItem(this.item).then(() => {
                  void this.reload()
                  this.onDataChange()
                })
              }
            })
            AppButton({
              label: this.isFav ? '取消收藏' : '加入收藏',
              variant: 'secondary',
              onTap: (): void => {
                void GrowthService.toggleFavorite('item', this.item.id, this.title, this.category).then((added) => {
                  this.isFav = added
                })
              }
            })
            AppButton({
              label: '查看所属清单',
              variant: 'secondary',
              onTap: (): void => { this.onOpenList(this.listId) }
            })
          }
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
