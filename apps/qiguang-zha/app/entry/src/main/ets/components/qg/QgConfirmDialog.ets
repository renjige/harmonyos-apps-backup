import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct QgConfirmDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '确认'
  @Prop message: string = ''
  @Prop confirmLabel: string = '确认'
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onCancel() })
      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        AppButton({ label: this.confirmLabel, variant: 'danger', onTap: (): void => { this.onConfirm() } })
        AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.onCancel() } })
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
  }
}
