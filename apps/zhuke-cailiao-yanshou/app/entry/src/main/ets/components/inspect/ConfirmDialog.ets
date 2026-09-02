import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '确认操作'
  @Prop message: string = ''
  @Prop confirmLabel: string = '删除'
  onCancel: () => void = () => {}
  onConfirm: () => void = () => {}

  build() {
    Column() {
      Column({ space: Theme.space.s3 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.message)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 12 }) {
          AppButton({ label: '取消', variant: 'secondary', onTap: () => this.onCancel() })
            .layoutWeight(1)
          AppButton({ label: this.confirmLabel, variant: 'danger', onTap: () => this.onConfirm() })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .margin({ left: Theme.space.s6, right: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
    .onClick(() => this.onCancel())
  }
}
