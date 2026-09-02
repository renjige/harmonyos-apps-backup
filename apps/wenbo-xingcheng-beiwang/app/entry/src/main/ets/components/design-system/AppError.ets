import { Theme } from './Theme'
import { AppButton } from './AppButton'
import { AppIcon } from './AppIcon'

export type AppErrorVariant = 'inline' | 'banner' | 'page'

@Component
export struct AppError {
  @Prop variant: AppErrorVariant = 'page'
  @Prop title: string = '出错了'
  @Prop message: string = '请稍后重试'
  @Prop retryLabel: string = '重试'
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onRetry: () => void = () => {}

  build() {
    if (this.variant === 'inline') {
      Text(this.message)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.palette(this.darkModeOn).danger)
        .width('100%')
    } else if (this.variant === 'banner') {
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'alert', color: Theme.palette(this.darkModeOn).warning })
        Text(this.message)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.palette(this.darkModeOn).warningContainer)
      .borderRadius(Theme.radius.md)
    } else {
      Column({ space: Theme.space.s3 }) {
        AppIcon({ name: 'alert', iconSize: Theme.icon.xl, color: Theme.palette(this.darkModeOn).danger })
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
        Text(this.message)
          .fontSize(Theme.type.callout)
          .fontColor(Theme.palette(this.darkModeOn).textSecondary)
          .textAlign(TextAlign.Center)
        AppButton({
          label: this.retryLabel,
          onTap: () => this.onRetry()
        })
      }
      .width('100%')
      .padding(Theme.space.s7)
    }
  }
}
