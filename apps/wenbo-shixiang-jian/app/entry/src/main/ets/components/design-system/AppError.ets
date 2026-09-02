import { Theme } from './Theme'
import { AppButton } from './AppButton'
import { AppIcon } from './AppIcon'

export type AppErrorVariant = 'inline' | 'banner' | 'page'

@Component
export struct AppError {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop variant: AppErrorVariant = 'page'
  @Prop title: string = '出错了'
  @Prop message: string = '请稍后重试'
  @Prop retryLabel: string = '重试'
  onRetry: () => void = () => {}

  build() {
    if (this.variant === 'inline') {
      Text(this.message)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().danger)
        .width('100%')
    } else if (this.variant === 'banner') {
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'alert', color: Theme.colors().warning })
        Text(this.message)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().warningContainer)
      .borderRadius(Theme.radius.md)
    } else {
      Column({ space: Theme.space.s3 }) {
        AppIcon({ name: 'alert', iconSize: Theme.icon.xl, color: Theme.colors().danger })
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.message)
          .fontSize(Theme.type.callout)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
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
