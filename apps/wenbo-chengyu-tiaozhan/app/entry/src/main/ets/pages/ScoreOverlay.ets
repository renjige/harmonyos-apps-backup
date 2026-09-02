import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { IdiomNav } from '../services/IdiomNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct ScoreOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State score: number = 0
  @State correct: number = 0
  @State maxCombo: number = 0
  @State total: number = 0
  @State passed: boolean = true
  @State source: string = 'daily'

  aboutToAppear(): void {
    this.score = AppStorage.get<number>('quizScore') ?? 0
    this.correct = AppStorage.get<number>('quizCorrect') ?? 0
    this.maxCombo = AppStorage.get<number>('quizMaxCombo') ?? 0
    this.total = IdiomNav.queue().length
    this.source = AppStorage.get<string>('quizSource') ?? 'daily'
    if (this.source === 'campaign') {
      const need = Math.ceil(this.total * 0.8)
      this.passed = this.correct >= need
    }
  }

  build() {
    Column({ space: 16 }) {
      Text(this.source === 'campaign' ? (this.passed ? '本关已过' : '再试一关') : '今日成绩')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Column({ space: 8 }) {
        Text(`总分 ${this.score}`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(`答对 ${this.correct} / ${this.total}    最高连击 ${this.maxCombo}`)
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`称号：${ProgressStore.titleRank()}`)
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        if (this.source === 'campaign' && !this.passed) {
          Text('需答对八成才能解锁下一关。进度已记在本机。')
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
      }
      .width('100%')
      .padding(24)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceGlass)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      AppButton({ label: '返回', onTap: () => IdiomNav.close() })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 48, bottom: 24 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
