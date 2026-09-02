import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextField } from '../design-system/AppTextField'
import { DetailShell } from '../detail/DetailShell'
import { PracticeItem } from '../../models/PracticeModels'
import { AtelierPractice } from '../../services/AtelierPractice'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierProgress } from '../../services/AtelierProgress'
import { AtelierTime } from '../../models/AtelierModels'

@Component
export struct FocusTimerPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State planned: number = 10
  @State remain: number = 600
  @State running: boolean = false
  @State note: string = ''
  private tickId: number = -1

  aboutToAppear(): void {
    this.remain = this.planned * 60
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

  private clock(): string {
    const m = Math.floor(this.remain / 60)
    const s = this.remain % 60
    const mm = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${mm}:${ss}`
  }

  private choose(mins: number): void {
    if (this.running) {
      return
    }
    this.planned = mins
    this.remain = mins * 60
  }

  private start(): void {
    if (this.remain <= 0) {
      this.remain = this.planned * 60
    }
    this.running = true
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
    this.running = false
    this.clearTick()
  }

  private async finish(completed: boolean): Promise<void> {
    this.clearTick()
    this.running = false
    const used = completed ? this.planned : Math.ceil((this.planned * 60 - this.remain) / 60)
    let mins = used
    if (mins < 1) {
      AtelierDetailNav.showToast('请先开始计时')
      return
    }
    const note = this.note.trim()
    const item = PracticeItem.of('', 'focus', '', '专注阅读',
      note.length > 0 ? note : `${this.planned} 分钟专注`, '', '', mins, AtelierTime.todayKey())
    await AtelierPractice.save(item)
    await AtelierProgress.addReadMinutes(mins)
    AtelierDetailNav.bumpRefresh()
    AtelierDetailNav.showToast(completed ? '本段已记入课业' : '已保存本次时长')
    this.remain = this.planned * 60
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '专注计时',
        onClose: (): void => { AtelierDetailNav.close() }
      }) {
        Column({ space: Theme.space.s4 }) {
          Text(this.clock())
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 12 })
          Row({ space: 8 }) {
            this.Chip(5)
            this.Chip(10)
            this.Chip(15)
            this.Chip(25)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          AppTextField({
            text: this.note,
            placeholder: '读完可写一句收获（选填）',
            multiline: true,
            fieldHeight: 88,
            onChange: (v: string): void => { this.note = v }
          })
          if (!this.running) {
            AppButton({ label: '开始', onTap: (): void => { this.start() } })
          } else {
            AppButton({ label: '暂停', variant: 'secondary', onTap: (): void => { this.pause() } })
          }
          AppButton({
            label: '结束并记入课业',
            variant: 'secondary',
            onTap: (): void => { void this.finish(false) }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Chip(mins: number) {
    Text(`${mins} 分`)
      .fontSize(13)
      .fontColor(this.planned === mins ? Theme.colorOf(this.themeEpoch).brandOnPrimary :
        Theme.colorOf(this.themeEpoch).brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.planned === mins ? Theme.colorOf(this.themeEpoch).brandPrimary :
        Theme.colorOf(this.themeEpoch).brandPrimaryContainer)
      .borderRadius(8)
      .onClick((): void => { this.choose(mins) })
  }
}
