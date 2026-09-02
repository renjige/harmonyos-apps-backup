import { Theme } from '../design-system/Theme'

@Component
export struct HomeGuideCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onCustom: () => void = () => {}
  onGoal: () => void = () => {}
  onReview: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('从这里开始')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('童趣算坊是亲子学习工作台，建议先体验这三步：')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      this.step('1', '家长出题', '自己写 7+8 等算式，保存题单', () => this.onCustom())
      this.step('2', '设本周目标', '选 30～100 题，看完成进度', () => this.onGoal())
      this.step('3', '学习回顾', '查看今日/本周总结并复制', () => this.onReview())
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  step(num: string, title: string, hint: string, tap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Text(num)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(22)
        .height(22)
        .textAlign(TextAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(11)
      Column({ space: Theme.space.s1 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(hint)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
    .onClick(tap)
  }
}
