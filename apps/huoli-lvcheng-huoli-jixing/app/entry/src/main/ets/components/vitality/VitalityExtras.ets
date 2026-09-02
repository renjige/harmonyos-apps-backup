import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct WeeklyGoalBar {
  @Prop weekDone: number = 0
  @Prop weekGoal: number = 5

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('本周打卡目标')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(`${this.weekDone}/${this.weekGoal} 天`)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Row()
          .width(`${Math.min(100, Math.round((this.weekDone / Math.max(1, this.weekGoal)) * 100))}%`)
          .height(8)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')

      Text(this.weekDone >= this.weekGoal ?
        '本周目标已达成，继续保持节奏。' :
        `还差 ${Math.max(0, this.weekGoal - this.weekDone)} 天达成本周目标。`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
export struct VitalityInsightsCard {
  @Prop insightText: string = ''
  onBreathing: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('活力洞察')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.insightText)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)
        .width('100%')
      AppButton({
        label: '开始 60 秒呼吸练习',
        variant: 'secondary',
        onTap: (): void => this.onBreathing()
      })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
export struct BreathingGuideOverlay {
  onClose: () => void = () => {}
  @State phaseLabel: string = '吸气'
  @State secondsLeft: number = 4
  @State round: number = 1
  @State running: boolean = true
  private timerId: number = -1

  aboutToAppear(): void {
    this.startTimer()
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
    }
  }

  private startTimer(): void {
    this.timerId = setInterval((): void => {
      if (!this.running) {
        return
      }
      if (this.secondsLeft > 1) {
        this.secondsLeft--
        return
      }
      if (this.phaseLabel === '吸气') {
        this.phaseLabel = '屏息'
        this.secondsLeft = 4
      } else if (this.phaseLabel === '屏息') {
        this.phaseLabel = '呼气'
        this.secondsLeft = 4
      } else if (this.phaseLabel === '呼气') {
        this.phaseLabel = '放松'
        this.secondsLeft = 4
      } else {
        this.round++
        if (this.round > 4) {
          this.running = false
          clearInterval(this.timerId)
          return
        }
        this.phaseLabel = '吸气'
        this.secondsLeft = 4
      }
    }, 1000)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => this.onClose())

      Column({ space: Theme.space.s5 }) {
        Text('盒式呼吸 · 60 秒')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(this.running ? this.phaseLabel : '练习完成')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text(this.running ? `${this.secondsLeft}` : '感受身体是否更放松')
          .fontSize(Theme.type.title2)
          .fontColor(Theme.colors().textSecondary)
        Text(`第 ${Math.min(this.round, 4)} / 4 轮`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        AppButton({
          label: this.running ? '结束练习' : '完成',
          variant: 'primary',
          onTap: (): void => this.onClose()
        })
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
  }
}
