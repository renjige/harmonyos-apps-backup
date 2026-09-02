import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct FocusSessionPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop knowTitle: string = ''
  @Prop knowId: string = ''
  @State minutes: number = 25
  @State secondsLeft: number = 1500
  @State running: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.resetTimer()
  }

  private resetTimer(): void {
    this.running = false
    this.secondsLeft = this.minutes * 60
  }

  private pickMinutes(m: number): void {
    if (this.running) {
      return
    }
    this.minutes = m
    this.secondsLeft = m * 60
  }

  private timeLabel(): string {
    const m = Math.floor(this.secondsLeft / 60)
    const s = this.secondsLeft % 60
    const mm = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${mm}:${ss}`
  }

  private start(): void {
    if (this.running) {
      return
    }
    this.running = true
    this.scheduleTick()
  }

  private pause(): void {
    this.running = false
  }

  private scheduleTick(): void {
    setTimeout((): void => {
      if (!this.running) {
        return
      }
      if (this.secondsLeft <= 1) {
        void this.complete()
        return
      }
      this.secondsLeft = this.secondsLeft - 1
      this.scheduleTick()
    }, 1000)
  }

  private async complete(): Promise<void> {
    this.running = false
    this.secondsLeft = 0
    await ZhixingStore.logFocusSession(this.knowTitle, this.minutes, this.knowId)
    this.toastText = `已完成 ${this.minutes} 分钟专注，已写入行动日志`
    this.onChanged()
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({ title: '专注学习', onBack: (): void => { this.onClose() } })
        Column({ space: Theme.space.s4 }) {
          Text(this.knowTitle.length > 0 ? this.knowTitle : '通用专注时段')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.timeLabel())
            .fontSize(48)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
          Row({ space: 8 }) {
            this.MinChip('15 分', 15)
            this.MinChip('25 分', 25)
            this.MinChip('45 分', 45)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          Text('本地倒计时，无需联网；结束后自动写入行动日志')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 10 }) {
            AppButton({
              label: this.running ? '暂停' : '开始专注',
              onTap: (): void => {
                if (this.running) {
                  this.pause()
                } else {
                  this.start()
                }
              }
            })
            AppButton({
              label: '提前完成',
              variant: 'secondary',
              onTap: (): void => { void this.complete() }
            })
          }
          .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MinChip(label: string, m: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.minutes === m ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.minutes === m ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.pickMinutes(m) })
  }
}
