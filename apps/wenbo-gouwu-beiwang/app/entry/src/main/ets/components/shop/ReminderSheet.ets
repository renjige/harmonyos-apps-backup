import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { ShoppingLocalStore } from '../../services/ShoppingLocalStore'
import { ShoppingService } from '../../services/ShoppingService'
import { ShoppingNotifyService } from '../../services/ShoppingNotifyService'

@Component
export struct ReminderSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop remain: number = 0
  @State mode: string = 'today'
  @State cycle: string = 'once'
  @State dateText: string = ShoppingLocalStore.today()
  @State timeText: string = ShoppingNotifyService.defaultTimeText()
  onClose: () => void = () => {}
  onConfirm: (whenText: string, message: string, cycle: string) => void = () => {}
  onTest: () => void = () => {}

  private tomorrow(): string {
    const d = new Date()
    d.setDate(d.getDate() + 1)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  @Builder
  ModeChip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.mode === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.mode === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.mode = value
        if (value === 'today') {
          this.dateText = ShoppingLocalStore.today()
          this.cycle = 'once'
        }
        if (value === 'tomorrow') {
          this.dateText = this.tomorrow()
          this.cycle = 'once'
        }
        if (value === 'weekly') {
          this.dateText = ShoppingLocalStore.today()
          this.cycle = 'weekly'
        }
        if (value === 'custom') {
          this.cycle = 'once'
        }
      })
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('智慧提醒')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      Text(ShoppingService.reminderCopy(this.remain))
        .fontSize(Theme.type.body)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      Row({ space: 8 }) {
        this.ModeChip('今天', 'today')
        this.ModeChip('明天', 'tomorrow')
        this.ModeChip('每周采购', 'weekly')
        this.ModeChip('自定义日期', 'custom')
      }
      .width('100%')
      if (this.mode === 'custom') {
        AppDatePickerField({
          label: '日期',
          value: this.dateText,
          onChange: (v: string) => { this.dateText = v }
        })
      }
      Text(this.cycle === 'weekly' ? '将按每周同一时间提醒补货。可用「1 分钟后试响」先验证通知。' :
        '到点后会发送系统通知。已开启通知即可保存；若所选时间已过，会自动改到 1 分钟后。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      AppTimePickerField({
        label: '时间',
        value: this.timeText,
        onChange: (v: string) => { this.timeText = v }
      })
      AppButton({
        label: '保存提醒',
        onTap: (): void => {
          this.onConfirm(`${this.dateText} ${this.timeText}`, ShoppingService.reminderCopy(this.remain), this.cycle)
        }
      })
      AppButton({
        label: '1 分钟后试响',
        variant: 'secondary',
        onTap: (): void => { this.onTest() }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
