import { Theme } from './Theme'
import { AppButton } from './AppButton'
import { AppIcon, AppIconName } from './AppIcon'

@Component
export struct AppEmpty {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '暂无内容'
  @Prop description: string = '当前还没有可展示的数据'
  @Prop actionLabel: string = ''
  @Prop iconName: AppIconName = 'empty'
  @Prop emojiMark: string = ''
  onAction: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.emojiMark.length > 0) {
        Text(this.emojiMark)
          .fontSize(32)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      Column() {
        AppIcon({ name: this.iconName, iconSize: Theme.icon.xl, color: Theme.colors().brandAccent })
      }
      .width(64)
      .height(64)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(this.description)
        .fontSize(Theme.type.callout)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
      if (this.actionLabel.length > 0) {
        AppButton({
          label: this.actionLabel,
          variant: 'primary',
          onTap: (): void => { this.onAction() }
        })
      }
    }
    .width('100%')
    .padding(Theme.space.s7)
    .justifyContent(FlexAlign.Center)
  }
}
