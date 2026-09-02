import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct AddItemSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State name: string = ''
  @State qty: string = ''
  @State remark: string = ''
  @State category: string = ''
  @State suggested: string = ''
  onClose: () => void = () => {}
  onConfirm: (name: string, qty: string, remark: string, category: string) => void = () => {}

  private refreshSuggest(): void {
    this.suggested = CategorySuggest.suggest(this.name)
    if (this.category.length === 0) {
      this.category = this.suggested
    }
  }

  build() {
    Column() {
      Row() {
        Text('添加事项')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.name, placeholder: '事项名称，例如 购买纸巾' })
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

          if (this.suggested.length > 0 && this.name.trim().length > 0) {
            Column({ space: 10 }) {
              Text(`建议分类：${this.suggested}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
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
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.category = '' })
              }
              .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
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
              this.onConfirm(this.name.trim(), this.qty.trim(), this.remark.trim(), cat)
            }
          })
        }
        .padding({ left: 20, right: 20, bottom: 28 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
