import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop keepLabel: string = '取消'
  @Prop leaveLabel: string = '确定'
  onKeep: () => void = () => {}
  onLeave: () => void = () => {}

  build() {
    Column() {
      Column()
        .width('100%')
        .layoutWeight(1)
        .onClick(() => this.onKeep())
      Column({ space: Theme.space.s4 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.subtitle)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({ label: this.leaveLabel, variant: 'danger', onTap: () => this.onLeave() })
        AppButton({ label: this.keepLabel, variant: 'ghost', onTap: () => this.onKeep() })
      }
      .width('100%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
