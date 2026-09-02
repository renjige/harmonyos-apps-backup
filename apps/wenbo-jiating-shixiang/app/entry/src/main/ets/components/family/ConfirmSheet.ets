import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '确认删除'
  @Prop message: string = '删除后无法恢复。'
  @Prop confirmLabel: string = '删除'
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Column() {
      Column({ space: 12 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: this.confirmLabel,
          variant: 'danger',
          onTap: () => this.onConfirm()
        })
        AppButton({
          label: '取消',
          variant: 'ghost',
          onTap: () => this.onCancel()
        })
      }
      .width('100%')
      .padding(24)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: 24, topRight: 24 })
      .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor(Theme.colors().overlayScrim)
    .onClick(() => this.onCancel())
  }
}
