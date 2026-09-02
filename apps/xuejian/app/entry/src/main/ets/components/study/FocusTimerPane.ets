import { Theme } from '../design-system/Theme'
import { StudySession } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct FocusTimerPane {
  @State planned: number = 25
  @State remain: number = 0
  @State running: boolean = false
  @State paused: boolean = false
  @State toastText: string = ''
  @State customText: string = '25'
  private tickId: number = -1
  private everStarted: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.remain = this.planned * 60
    this.customText = `${this.planned}`
  }

  aboutToDisappear(): void {
    this.clearTick()
  }

  private clearTick(): void {
    if (this.tickId >= 0) {
      clearInterval(this.tickId)
      this.tickId = -1
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private displayClock(): string {
    const m = Math.floor(this.remain / 60)
    const s = this.remain % 60
    const mm = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${mm}:${ss}`
  }

  private progress(): number {
    const total = this.planned * 60
    if (total <= 0) {
      return 0
    }
    return (total - this.remain) / total
  }

  private choose(mins: number): void {
    if (this.running) {
      return
    }
    this.planned = mins
    this.remain = mins * 60
    this.customText = `${mins}`
  }

  private start(): void {
    if (this.remain <= 0) {
      this.remain = this.planned * 60
    }
    this.running = true
    this.paused = false
    this.everStarted = true
    this.clearTick()
    this.tickId = setInterval((): void => {
      if (this.remain <= 1) {
        this.remain = 0
        void this.finish(true)
        return
      }
      this.remain = this.remain - 1
    }, 1000)
  }

  private pause(): void {
    this.paused = true
    this.running = false
    this.clearTick()
  }

  private resume(): void {
    this.start()
  }

  private async finish(completed: boolean): Promise<void> {
    this.clearTick()
    this.running = false
    this.paused = false
    const total = this.planned * 60
    const usedSec = completed ? total : (total - this.remain)
    let mins = Math.ceil(usedSec / 60)
    if (mins < 1 && this.everStarted) {
      mins = 1
    }
    if (mins < 1) {
      this.showToast('请先点「开始专注」，或到「我的 → 今日」补记')
      return
    }
    const session = StudySession.create(this.planned, mins, completed)
    await StudyStore.addSession(session)
    this.onChanged()
    this.showToast(completed ? '本段专注已看见。可点下方开始 5 分钟休息' : '已保存本次时长')
    this.remain = this.planned * 60
    this.everStarted = false
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text('专注计时')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A2A4A')
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor('#F5A623')
            .borderRadius(16)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onClose() })
        }
        .width('100%')

        Stack() {
          Progress({ value: this.progress() * 100, total: 100, type: ProgressType.Ring })
            .width(220)
            .height(220)
            .color('#F5A623')
            .backgroundColor('rgba(255,255,255,0.12)')
            .style({ strokeWidth: 12 })
          Text(this.displayClock())
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(220)
        .height(220)

        if (!this.running && !this.paused) {
          Row({ space: 8 }) {
            this.PresetChip(15)
            this.PresetChip(25)
            this.PresetChip(45)
          }
          Row({ space: 8 }) {
            Text('自定义分钟')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
            TextInput({ text: this.customText, placeholder: '分钟' })
              .width(88)
              .height(40)
              .fontSize(Theme.type.body)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .borderRadius(8)
              .onChange((v: string) => { this.customText = v })
            Text('应用')
              .fontSize(Theme.type.body)
              .fontColor('#1A2A4A')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#F5A623')
              .borderRadius(20)
              .constraintSize({ minWidth: 48, minHeight: 40 })
              .onClick((): void => {
                const n = Number.parseInt(this.customText, 10)
                if (n !== n || n < 1 || n > 180) {
                  this.showToast('请填写 1–180 分钟')
                  return
                }
                this.choose(n)
              })
          }
        }

        Column({ space: 10 }) {
          if (!this.running && !this.paused) {
            Text('开始专注')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A2A4A')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#F5A623')
              .borderRadius(24)
              .constraintSize({ minHeight: 48 })
              .onClick((): void => { this.start() })
          } else if (this.running) {
            Text('暂停')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 14, bottom: 14 })
              .border({ width: 2, color: '#FFFFFF' })
              .borderRadius(24)
              .constraintSize({ minHeight: 48 })
              .onClick((): void => { this.pause() })
          } else {
            Text('继续')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A2A4A')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#F5A623')
              .borderRadius(24)
              .constraintSize({ minHeight: 48 })
              .onClick((): void => { this.resume() })
          }
          Text('结束并记录')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 14, bottom: 14 })
            .border({ width: 2, color: '#FFFFFF' })
            .borderRadius(24)
            .constraintSize({ minHeight: 48 })
            .onClick((): void => { void this.finish(false) })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding(Theme.space.pageX)
      .linearGradient({
        angle: 180,
        colors: [['#1A2A4A', 0], ['#2C3A58', 0.6], ['#1A2A4A', 1]]
      })

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#1A1A1A')
          .padding(12)
          .backgroundColor('#FDF0D5')
          .borderRadius(12)
          .margin({ top: 24 })
          .constraintSize({ maxWidth: '86%' })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  PresetChip(mins: number) {
    Text(`${mins} 分钟`)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.planned === mins ? '#1A2A4A' : '#FFFFFF')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.planned === mins ? '#F5A623' : 'rgba(255,255,255,0.12)')
      .borderRadius(20)
      .constraintSize({ minHeight: 44 })
      .onClick((): void => { this.choose(mins) })
  }
}
