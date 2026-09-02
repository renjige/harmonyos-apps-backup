import { Theme } from '../design-system/Theme'
import { TodayProgress } from '../../models/ZhiweiModels'
import { ZhiweiNav } from '../../services/ZhiweiNav'

@Component
export struct TodayProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop progress: TodayProgress = new TodayProgress()

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日学习进度')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        Blank()
        Text(`${this.progress.percent}%`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
      }
      .width('100%')
      Progress({ value: this.progress.percent, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(Theme.colorOf(this.themeEpoch).brandPrimary)
        .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceSubtle)
      Text(`已记 ${this.progress.captureToday} 条 · 每日一知${this.progress.dailyRead ? '已读' : '未读'} · 待消化 ${this.progress.inboxCount}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
        .width('100%')
      Text(this.progress.hint)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        .width('100%')
      Text('继续完成 →')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
        .width('100%')
        .onClick(() => {
          if (!this.progress.dailyRead) {
            ZhiweiNav.openDaily()
          } else {
            ZhiweiNav.openCompose('', false)
          }
        })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
