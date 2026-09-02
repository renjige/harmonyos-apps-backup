import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct XuConfirmDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '确认'
  @Prop message: string = ''
  @Prop confirmLabel: string = '确认删除'
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Column() {
      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: this.confirmLabel,
          variant: 'danger',
          onTap: (): void => { this.onConfirm() }
        })
        AppButton({
          label: '取消',
          variant: 'secondary',
          onTap: (): void => { this.onCancel() }
        })
      }
      .width('86%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
