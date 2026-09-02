import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmSheet {
  @Prop title: string = '确认删除'
  @Prop message: string = '删除后无法恢复。'
  @Prop confirmLabel: string = '删除'
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.palette(this.darkModeOn).overlayScrim)
        .onClick((): void => { this.onCancel() })
      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.titleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .width('100%')
        Text(this.message)
          .fontSize(Theme.type.bodyM)
          .fontColor(Theme.palette(this.darkModeOn).textSecondary)
          .width('100%')
        AppButton({
          label: this.confirmLabel,
          variant: 'danger',
          onTap: (): void => { this.onConfirm() }
        })
        AppButton({
          label: '取消',
          variant: 'ghost',
          onTap: (): void => { this.onCancel() }
        })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
      .align(Alignment.Bottom)
    }
    .width('100%')
    .height('100%')
  }
}
