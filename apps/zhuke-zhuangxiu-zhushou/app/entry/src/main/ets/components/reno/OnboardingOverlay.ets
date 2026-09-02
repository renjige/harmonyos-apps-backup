import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { RenoMedia } from '../../services/RenoMedia'

@Component
export struct OnboardingOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onFinish: () => void = () => {}

  build() {
    Column() {
      Blank().layoutWeight(1)
      Image(RenoMedia.cover('home_hero'))
        .width(112)
        .height(112)
        .borderRadius(28)
        .objectFit(ImageFit.Cover)
      Text('筑科装修助手')
        .fontSize(Theme.type.titleL)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .margin({ top: 24 })
      Text('装修有章法，施工更安心')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .margin({ top: 8 })
      Text('简洁记录每一个装修节点')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textTertiary)
        .margin({ top: 6 })
      Blank().layoutWeight(1)
      AppButton({
        label: '开始使用',
        variant: 'primary',
        onTap: () => this.onFinish()
      })
        .width('100%')
        .margin({ bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 48, bottom: 24 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
