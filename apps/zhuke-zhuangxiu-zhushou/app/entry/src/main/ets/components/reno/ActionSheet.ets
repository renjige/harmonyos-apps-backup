import { Theme } from '../design-system/Theme'
import { RenoAction } from '../../models/RenoModels'

@Component
export struct ActionSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '新增'
  onPick: (id: string) => void = (_id: string) => {}
  onCancel: () => void = () => {}
  private items: RenoAction[] = RenoAction.quick()

  build() {
    Column() {
      Column({ space: 8 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .margin({ bottom: 8 })
        ForEach(this.items, (it: RenoAction) => {
          Text(it.label)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 14, bottom: 14 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.onPick(it.id))
        }, (it: RenoAction) => it.id)
        Text('取消')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 14, bottom: 6 })
          .onClick(() => this.onCancel())
      }
      .width('100%')
      .padding(24)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
      .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor(Theme.colors().overlayScrim)
    .onClick(() => this.onCancel())
  }
}
