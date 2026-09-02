import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ProgressStore } from '../services/ProgressStore'
import { QuizNav } from '../services/QuizNav'

@Component
export struct QuizSummaryOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State correct: number = 0
  @State total: number = 0
  @State todayCount: number = 0
  @State streakDays: number = 0
  @State doneCount: number = 0

  aboutToAppear(): void {
    this.correct = QuizNav.summaryCorrect()
    this.total = QuizNav.summaryTotal()
    ProgressStore.sync()
    this.todayCount = ProgressStore.todayProgress()
    this.streakDays = ProgressStore.displayStreak()
    this.doneCount = ProgressStore.snapshot().completedIds.length
  }

  private backHome(): void {
    ProgressStore.sync()
    AppStorage.setOrCreate('mainTab', 0)
    QuizNav.close()
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => QuizNav.close())
        Blank()
        Text('挑战小结')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Column({ space: 12 }) {
        Text('本轮完成')
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`${this.correct}/${this.total}`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.correct >= this.total ? '全部答对，真棒！' : '有错题也没关系，再想想就更好。')
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(24)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(24)
      .width('100%')
      .margin({ left: 20, right: 20 })

      Row({ space: 10 }) {
        this.Stat('今日进度', `${this.todayCount}/${ProgressStore.dailyGoal()}`)
        this.Stat('已完成', `${this.doneCount} 题`)
        this.Stat('连续挑战', `${this.streakDays} 天`)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      Blank()
      AppButton({
        label: '回今日看看',
        onTap: () => this.backHome()
      })
        .margin({ left: 20, right: 20, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Stat(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }
}
