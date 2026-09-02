import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MathMedia } from '../../services/MathMedia'

@Component
export struct WelcomeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onFinish: () => void = () => {}

  build() {
    Column() {
      Blank().layoutWeight(1)
      Column({ space: Theme.space.s5 }) {
        Image(MathMedia.resource('hero_desk'))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sheet)
        Text('趣味算学')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text('智慧启迪，趣味成长')
          .fontSize(Theme.type.subtitleM)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
      Blank().layoutWeight(1)
      Column() {
        AppButton({ label: '开始体验', onTap: () => this.onFinish() })
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7, bottom: Theme.space.s8 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
