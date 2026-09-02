import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct OnboardingOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onFinish: () => void = () => {}

  build() {
    Column() {
      Blank().layoutWeight(1)
      Image(TaskMedia.cover('home_hero'))
        .width(120)
        .height(120)
        .borderRadius(28)
        .objectFit(ImageFit.Cover)
      Text('家庭事项')
        .fontSize(Theme.type.titleL)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .margin({ top: 28 })
      Text('让家庭里的每件小事，都有回应。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .margin({ top: 10, left: 32, right: 32 })
        .textAlign(TextAlign.Center)
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
