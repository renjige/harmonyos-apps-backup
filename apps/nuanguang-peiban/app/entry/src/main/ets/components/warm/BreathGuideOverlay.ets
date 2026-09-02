import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { BreathModeItem } from '../../models/WarmCompanionModels'
import { WarmCompanionBizService } from '../../services/WarmCompanionBizService'
import { WarmCompanionLocalStore } from '../../services/WarmCompanionLocalStore'

type BreathPhase = 'inhale' | 'hold' | 'exhale' | 'idle'

@Component
export struct BreathGuideOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: BreathModeItem = new BreathModeItem()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State phase: BreathPhase = 'idle'
  @State phaseLabel: string = '准备'
  @State roundIndex: number = 0
  @State elapsedSec: number = 0
  @State phaseLeft: number = 0
  @State running: boolean = false
  @State paused: boolean = false
  @State ringScale: number = 0.72
  @State toastText: string = ''
  private timerId: number = -1

  aboutToDisappear(): void {
    this.clearTimer()
  }

  private clearTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2400)
  }

  private startPractice(): void {
    this.running = true
    this.paused = false
    this.roundIndex = 1
    this.elapsedSec = 0
    this.beginPhase('inhale')
    this.clearTimer()
    this.timerId = setInterval(() => {
      if (!this.running || this.paused) {
        return
      }
      this.tick()
    }, 1000)
  }

  private beginPhase(next: BreathPhase): void {
    this.phase = next
    if (next === 'inhale') {
      this.phaseLabel = '吸气'
      this.phaseLeft = this.mode.inhaleSec
      this.ringScale = 1.0
    } else if (next === 'hold') {
      this.phaseLabel = '屏息'
      this.phaseLeft = this.mode.holdSec
      this.ringScale = 1.0
    } else if (next === 'exhale') {
      this.phaseLabel = '呼气'
      this.phaseLeft = this.mode.exhaleSec
      this.ringScale = 0.72
    }
  }

  private tick(): void {
    this.elapsedSec += 1
    this.phaseLeft -= 1
    if (this.phaseLeft > 0) {
      return
    }
    if (this.phase === 'inhale') {
      if (this.mode.holdSec > 0) {
        this.beginPhase('hold')
      } else {
        this.beginPhase('exhale')
      }
      return
    }
    if (this.phase === 'hold') {
      this.beginPhase('exhale')
      return
    }
    if (this.phase === 'exhale') {
      if (this.roundIndex >= this.mode.rounds) {
        void this.finish()
        return
      }
      this.roundIndex += 1
      this.beginPhase('inhale')
    }
  }

  private togglePause(): void {
    if (!this.running) {
      return
    }
    this.paused = !this.paused
    this.phaseLabel = this.paused ? '已暂停' : this.phaseLabel
  }

  private async finish(): Promise<void> {
    this.running = false
    this.paused = false
    this.clearTimer()
    this.phase = 'idle'
    this.phaseLabel = '完成'
    const today = WarmCompanionLocalStore.todayKey()
    const ok = await WarmCompanionBizService.recordBreathSession(
      this.mode.id,
      this.mode.title,
      this.elapsedSec,
      today
    )
    if (ok) {
      this.showToast(`已记录 ${this.elapsedSec} 秒练习`)
      this.onSaved()
    } else {
      this.showToast('记录失败，请稍后重试')
    }
  }

  private async endEarly(): Promise<void> {
    this.clearTimer()
    if (this.elapsedSec >= 10) {
      const today = WarmCompanionLocalStore.todayKey()
      await WarmCompanionBizService.recordBreathSession(
        this.mode.id,
        this.mode.title,
        this.elapsedSec,
        today
      )
      this.onSaved()
    }
    this.onClose()
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s6 }) {
        Row() {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { void this.endEarly() })
          Text(this.mode.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Column().width(44).height(44)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Column({ space: Theme.space.s4 }) {
          Stack() {
            Circle()
              .width(220)
              .height(220)
              .fill(Theme.colors().brandPrimaryContainer)
              .scale({ x: this.ringScale, y: this.ringScale })
              .animation({ duration: this.phase === 'exhale' ? 800 : 600, curve: Curve.EaseInOut })
            Column({ space: 6 }) {
              Text(this.phaseLabel)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text(this.running ? `${this.phaseLeft}s` : '点击开始')
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`第 ${this.roundIndex} / ${this.mode.rounds} 轮`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
          }
          .width(240)
          .height(240)

          Text(`${this.mode.rhythmLabel} · 累计 ${this.elapsedSec} 秒`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          if (!this.running) {
            AppButton({
              label: '开始呼吸',
              onTap: (): void => this.startPractice()
            })
          } else {
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.paused ? '继续' : '暂停',
                variant: 'secondary',
                onTap: (): void => this.togglePause()
              }).layoutWeight(1)
              AppButton({
                label: '结束',
                variant: 'secondary',
                onTap: (): void => { void this.endEarly() }
              }).layoutWeight(1)
            }
            .width('100%')
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
