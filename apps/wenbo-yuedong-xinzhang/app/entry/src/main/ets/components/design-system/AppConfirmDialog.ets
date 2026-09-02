import { Theme } from './Theme'
import { AppButton } from './AppButton'

@Component
export struct AppConfirmDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop message: string = ''
  @Prop confirmLabel: string = '确认'
  @Prop cancelLabel: string = '取消'
  @Prop danger: boolean = false
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onCancel() })

      Column({ space: Theme.space.s4 }) {
        if (this.title.length > 0) {
          Text(this.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
        }
        Scroll() {
          Text(this.message)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .lineHeight(22)
        }
        .width('100%')
        .constraintSize({ maxHeight: 160 })
        .scrollBar(BarState.Off)

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: this.cancelLabel,
              variant: 'secondary',
              onTap: (): void => { this.onCancel() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: this.confirmLabel,
              variant: this.danger ? 'danger' : 'primary',
              onTap: (): void => { this.onConfirm() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('88%')
      .constraintSize({ maxWidth: 400 })
      .padding(Theme.space.s5)
      .margin({ bottom: Theme.space.s6 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeStrong })
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(100)
  }
}
