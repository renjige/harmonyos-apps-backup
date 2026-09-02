import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { BrainNav } from '../services/BrainNav'
import { BrainProgress } from '../services/BrainProgress'

@Component
export struct ScoreOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('brainLastScore') score: number = 0
  @StorageLink('brainScoreTitle') title: string = ''
  @StorageLink('wisdomIndex') wisdom: number = 0

  build() {
    Column() {
      DetailShell({ title: '训练完成', onBack: () => BrainNav.close() })
      Column({ space: 16 }) {
        Text('智慧之光')
          .fontSize(14)
          .fontColor(Theme.colors().brandAccent)
        Text(`${this.score}`)
          .fontSize(56)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandAccent)
        Text(this.title)
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`今日智慧指数 ${this.wisdom} · 连续 ${BrainProgress.snapshot().streak} 天`)
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text('回到训练')
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor(Theme.colors().brandOnPrimary)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(14)
          .onClick(() => BrainNav.close())
        Text('查看轨迹')
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(14)
          .onClick(() => {
            BrainNav.close()
            AppStorage.setOrCreate('mainTab', 1)
          })
      }
      .width('100%')
      .padding(24)
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
