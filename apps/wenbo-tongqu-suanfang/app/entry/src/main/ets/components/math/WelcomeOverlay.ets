import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct WelcomeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onFinish: () => void = () => {}

  build() {
    Column() {
      Blank().layoutWeight(1)
      Column({ space: Theme.space.s5 }) {
        Image($r('app.media.hero_desk'))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sheet)
        Text('童趣算坊')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text('亲子口算学习工作台')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text('不只是练题，还帮家长与孩子记录成长')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)

        Column({ space: Theme.space.s3 }) {
          this.cap('家长出题', '自己写算式，保存题单给孩子练')
          this.cap('本周目标', '设 30～100 题，看真实完成进度')
          this.cap('学习打卡', '练完自动记一天，可补家长备注')
          this.cap('练习回顾', '时间轴串起记录，总结可复制给家长')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
      Blank().layoutWeight(1)
      Column() {
        AppButton({ label: '进入工作台', onTap: () => this.onFinish() })
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7, bottom: Theme.space.s8 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  cap(title: string, hint: string) {
    Column({ space: Theme.space.s1 }) {
      Text(title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
