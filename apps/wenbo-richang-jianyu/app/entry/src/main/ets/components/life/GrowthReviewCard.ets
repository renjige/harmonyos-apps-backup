import { Theme } from '../design-system/Theme'

@Component
export struct GrowthReviewCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @Prop cardTitle: string = ''
  @Prop summary: string = ''
  @Prop diaryCount: number = 0
  @Prop moodCount: number = 0
  @Prop habitHits: number = 0
  @Prop todoDone: number = 0

  private bodyText(): string {
    if (this.summary.length > 0) {
      return this.summary
    }
    if (this.accessToken.length > 0) {
      return '这一段日子还是空白。写一页、记个心情或打个卡，回顾会写在这里。'
    }
    return '登录后用你自己的记录生成回顾。'
  }

  private heading(): string {
    return this.cardTitle.length > 0 ? this.cardTitle : '生活回顾'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.heading())
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.bodyText())
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(`笺语 ${this.diaryCount}  ·  心情 ${this.moodCount}  ·  打卡 ${this.habitHits}  ·  待办 ${this.todoDone}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}
