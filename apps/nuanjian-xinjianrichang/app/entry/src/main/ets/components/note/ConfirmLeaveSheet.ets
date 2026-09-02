import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ConfirmLeaveSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop keepLabel: string = '留下它'
  @Prop leaveLabel: string = '删除'
  onKeep: () => void = () => {}
  onLeave: () => void = () => {}

  build() {
    Column() {
      Column({ space: 14 }) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        AppButton({ label: this.keepLabel, onTap: (): void => { this.onKeep() } })
        AppButton({
          label: this.leaveLabel,
          variant: 'danger',
          onTap: (): void => { this.onLeave() }
        })
      }
      .width('100%')
      .padding(24)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
