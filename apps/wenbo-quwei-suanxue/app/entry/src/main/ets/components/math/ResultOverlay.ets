import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { PracticeSession } from '../../models/MathModels'

@Component
export struct ResultOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop session: PracticeSession = new PracticeSession()
  onAgain: () => void = () => {}
  onHome: () => void = () => {}

  private accuracy(): number {
    if (this.session.total <= 0) {
      return 0
    }
    return Math.round((this.session.correct / this.session.total) * 100)
  }

  private durationLabel(): string {
    const sec = Math.max(1, Math.round(this.session.durationMs / 1000))
    if (sec < 60) {
      return `${sec} 秒`
    }
    const m = Math.floor(sec / 60)
    const s = sec % 60
    return `${m} 分 ${s} 秒`
  }

  private starLine(): string {
    if (this.session.stars >= 3) {
      return '⭐ ⭐ ⭐'
    }
    if (this.session.stars === 2) {
      return '⭐ ⭐'
    }
    return '⭐'
  }

  build() {
    Column() {
      Blank().layoutWeight(1)
      Column({ space: Theme.space.s5 }) {
        Text('挑战完成！')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(this.starLine())
          .fontSize(28)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text(`获得 ${this.session.stars} 星`)
          .fontSize(Theme.type.subtitleM)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
        Column({ space: Theme.space.s4 }) {
          this.statRow('正确题数', `${this.session.correct} / ${this.session.total}`)
          this.statRow('正确率', `${this.accuracy()}%`)
          this.statRow('用时', this.durationLabel())
        }
        .width('100%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .shadow({ radius: 16, color: 'rgba(23,32,51,0.06)', offsetY: 4 })
        Text('今天也进步了一点')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7 })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
      Blank().layoutWeight(1)
      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '再来一关', onTap: () => this.onAgain() })
        AppButton({ label: '返回首页', variant: 'secondary', onTap: () => this.onHome() })
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
  statRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
  }
}
