import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ShiyiMedia } from '../../services/ShiyiMedia'

@Component
export struct ShiyiEmpty {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '今天还没有留下什么。'
  @Prop description: string = '有些小事，值得被记住。'
  @Prop actionLabel: string = ''
  onAction: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Image(ShiyiMedia.cover('empty_star'))
        .width(132)
        .height(132)
        .objectFit(ImageFit.Contain)
        .borderRadius(Theme.radius.xl)
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .textAlign(TextAlign.Center)
      Text(this.description)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
      if (this.actionLabel.length > 0) {
        AppButton({
          label: this.actionLabel,
          onTap: () => this.onAction()
        })
          .width('70%')
      }
    }
    .width('100%')
    .padding({ top: Theme.space.s6, bottom: Theme.space.s6 })
    .alignItems(HorizontalAlign.Center)
  }
}
