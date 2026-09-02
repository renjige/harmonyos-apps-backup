import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CategorySuggest } from '../../services/CategorySuggest'
import { ShoppingCatalog } from '../../services/ShoppingCatalog'

@Component
export struct AddItemSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onOpenChange') openToken: number = 0
  @State name: string = ''
  @State qty: string = ''
  @State remark: string = ''
  @State category: string = ''
  @State suggested: string = ''
  @State estPrice: string = ''
  @State tag: string = ''
  onClose: () => void = () => {}
  onConfirm: (name: string, qty: string, remark: string, category: string, estPrice: string, tag: string) => void = () => {}

  aboutToAppear(): void {
    this.name = ''
    this.qty = ''
    this.remark = ''
    this.category = ''
    this.suggested = ''
    this.estPrice = ''
    this.tag = ''
  }

  onOpenChange(): void {
    this.name = ''
    this.qty = ''
    this.remark = ''
    this.category = ''
    this.suggested = ''
    this.estPrice = ''
    this.tag = ''
  }

  private refreshSuggest(): void {
    this.suggested = CategorySuggest.suggest(this.name)
    if (this.category.length === 0) {
      this.category = this.suggested
    }
  }

  build() {
    Column() {
      Row() {
        Text('添加物品')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.name, placeholder: '物品名称，例如 牛奶' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => {
              this.name = v
              this.refreshSuggest()
            })
          TextInput({ text: this.qty, placeholder: '数量（可选）例如 2 瓶' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.qty = v })
          TextInput({ text: this.remark, placeholder: '备注（可选）' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.remark = v })
          TextInput({ text: this.estPrice, placeholder: '预估金额（可选）例如 12.5' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.estPrice = v })
          Text('商品标签')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(ShoppingCatalog.itemTags(), (t: string) => {
              Text(t)
                .fontSize(Theme.type.caption)
                .fontColor(this.tag === t ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.tag === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.tag = this.tag === t ? '' : t })
            }, (t: string) => t)
          }
          .width('100%')

          if (this.suggested.length > 0 && this.name.trim().length > 0) {
            Column({ space: 10 }) {
              Text(`建议分类：${this.suggested}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .width('100%')
              Row({ space: 10 }) {
                Text('采用')
                  .fontSize(Theme.type.footnote)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.category = this.suggested })
                Text('修改')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.category = '' })
              }
              .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CategorySuggest.categories(), (c: string) => {
              Text(c)
                .fontSize(Theme.type.caption)
                .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.category = c })
            }, (c: string) => c)
          }
          .width('100%')

          AppButton({
            label: '确认添加',
            onTap: (): void => {
              if (this.name.trim().length === 0) {
                return
              }
              const cat = this.category.length > 0 ? this.category : CategorySuggest.suggest(this.name)
              this.onConfirm(this.name.trim(), this.qty.trim(), this.remark.trim(), cat, this.estPrice.trim(), this.tag)
            }
          })
        }
        .padding({ left: 20, right: 20, bottom: 28 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
