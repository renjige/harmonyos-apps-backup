import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '请确认'
  @Prop message: string = ''
  @Prop confirmLabel: string = '确定'
  onCancel: () => void = () => {}
  onConfirm: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onCancel() })

      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.onCancel() }
          }).layoutWeight(1)
          AppButton({
            label: this.confirmLabel,
            variant: 'primary',
            onTap: (): void => { this.onConfirm() }
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
  }
}
