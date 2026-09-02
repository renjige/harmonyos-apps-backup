import { Theme } from '../design-system/Theme'
import { TemplateDetailPane } from '../detail/TemplateDetailPane'
import { ShoppingTemplate } from '../../models/ShoppingModels'

@Component
export struct TemplateDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: ShoppingTemplate = new ShoppingTemplate()
  onClose: () => void = () => {}
  onCreate: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      TemplateDetailPane({
        template: this.template,
        onCreate: () => this.onCreate()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
