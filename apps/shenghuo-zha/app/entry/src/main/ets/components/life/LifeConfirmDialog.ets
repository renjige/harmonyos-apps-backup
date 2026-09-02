import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct LifeConfirmDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '确认操作'
  @Prop message: string = ''
  @Prop confirmLabel: string = '确认'
  @Prop cancelLabel: string = '取消'
  @Prop danger: boolean = false
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick(() => this.onCancel())

      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.cancelLabel,
            variant: 'ghost',
            onTap: () => this.onCancel()
          }).layoutWeight(1)
          AppButton({
            label: this.confirmLabel,
            variant: this.danger ? 'danger' : 'primary',
            onTap: () => this.onConfirm()
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .zIndex(200)
  }
}
