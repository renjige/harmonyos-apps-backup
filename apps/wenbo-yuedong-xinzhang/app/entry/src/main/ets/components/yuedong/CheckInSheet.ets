import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { YdTaskItem } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct CheckInSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onDone: () => void = () => {}
  @State note: string = ''
  @State already: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const today = YdTaskItem.todayKey()
    this.already = await YdLocalStore.hasCheckInToday()
    const check = await YdLocalStore.loadCheckInForDate(today)
    if (check !== undefined) {
      this.note = check.note
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  build() {
    DetailShell({
      title: '今日跃动打卡',
      onClose: (): void => { YdDetailNav.closeCheckIn() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Column({ space: Theme.space.s4 }) {
        Text(this.already ? '今日已打卡，坚持就是跃升。' : '确认今日已推进一小步？打卡会计入连续天数。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)
        TextArea({
          text: this.note,
          placeholder: '可选：今天最想记住的一件事（本机保存）'
        })
          .height(96)
          .onChange((v: string): void => { this.note = v })
        AppButton({
          label: this.already ? '更新打卡说明' : '确认今日跃动',
          variant: 'primary',
          onTap: (): void => { void this.submit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }
    }
  }

  private async submit(): Promise<void> {
    await YdLocalStore.saveCheckIn(this.note)
    this.already = true
    this.onDone()
    this.showToast('今日跃动打卡成功')
    setTimeout((): void => { YdDetailNav.closeCheckIn() }, 800)
  }
}
