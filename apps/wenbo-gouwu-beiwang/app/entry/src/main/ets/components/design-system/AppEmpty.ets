import { Theme } from './Theme'
import { AppButton } from './AppButton'
import { AppIcon } from './AppIcon'

@Component
export struct AppEmpty {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '暂无内容'
  @Prop description: string = '当前还没有可展示的数据'
  @Prop actionLabel: string = ''
  onAction: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      AppIcon({ name: 'empty', iconSize: Theme.icon.xl, color: Theme.colors().textTertiary })
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      Text(this.description)
        .fontSize(Theme.type.callout)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .textAlign(TextAlign.Center)
      if (this.actionLabel.length > 0) {
        AppButton({
          label: this.actionLabel,
          variant: 'primary',
          onTap: () => this.onAction()
        })
      }
    }
    .width('100%')
    .padding(Theme.space.s7)
    .justifyContent(FlexAlign.Center)
  }
}
