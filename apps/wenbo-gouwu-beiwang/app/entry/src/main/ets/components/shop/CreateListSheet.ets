import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ShoppingCatalog } from '../../services/ShoppingCatalog'

@Component
export struct CreateListSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State kind: string = '日常采购'
  onClose: () => void = () => {}
  onConfirm: (title: string, kind: string) => void = () => {}

  @Builder
  NameChip(name: string) {
    Text(name)
      .fontSize(Theme.type.caption)
      .fontColor(this.title === name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.title === name ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.title = name })
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('新购物清单')
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
      TextInput({ text: this.title, placeholder: '例如 周末采购' })
        .height(48)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => { this.title = v })
      Text('点选常用名称，或自己填写')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        this.NameChip('周末采购')
        this.NameChip('家庭用品')
        this.NameChip('旅行用品')
        this.NameChip('节日采购')
        this.NameChip('开学采购')
      }
      .width('100%')
      Text('清单分类')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(ShoppingCatalog.listKinds(), (k: string) => {
          Text(k)
            .fontSize(Theme.type.caption)
            .fontColor(this.kind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.kind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick(() => { this.kind = k })
        }, (k: string) => k)
      }
      .width('100%')
      AppButton({
        label: '创建清单',
        onTap: (): void => {
          if (this.title.trim().length === 0) {
            return
          }
          this.onConfirm(this.title.trim(), this.kind)
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
