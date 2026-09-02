import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { FamilyLocalStore } from '../../services/FamilyLocalStore'
import { FamilyNotifyService } from '../../services/FamilyNotifyService'
import { FamilyService } from '../../services/FamilyService'

@Component
export struct ReminderSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop remain: number = 0
  @State mode: string = 'soon'
  @State cycle: string = 'once'
  @State dateText: string = FamilyLocalStore.today()
  @State timeText: string = FamilyNotifyService.defaultTimeText()
  onClose: () => void = () => {}
  onConfirm: (whenText: string, message: string, cycle: string) => void = () => {}

  aboutToAppear(): void {
    this.timeText = FamilyNotifyService.defaultTimeText()
    this.dateText = FamilyLocalStore.today()
    void FamilyNotifyService.ensurePermission()
  }

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
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mode === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.mode = value
        if (value === 'soon') {
          this.dateText = FamilyLocalStore.today()
          this.timeText = FamilyNotifyService.defaultTimeText()
        }
        if (value === 'today') {
          this.dateText = FamilyLocalStore.today()
        }
        if (value === 'tomorrow') {
          this.dateText = this.tomorrow()
        }
      })
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('智慧提醒')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      Text(FamilyService.reminderCopy(this.remain))
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 8 }) {
        this.ModeChip('15分钟后', 'soon')
        this.ModeChip('今天', 'today')
        this.ModeChip('明天', 'tomorrow')
        this.ModeChip('自定义', 'custom')
      }
      .width('100%')
      if (this.mode === 'custom') {
        AppDatePickerField({
          label: '日期',
          value: this.dateText,
          onChange: (v: string) => { this.dateText = v }
        })
      }
      if (this.mode !== 'soon') {
        AppTimePickerField({
          label: '时间',
          value: this.timeText,
          onChange: (v: string) => { this.timeText = v }
        })
      }
      Row({ space: 8 }) {
        Text('仅一次')
          .fontSize(Theme.type.footnote)
          .fontColor(this.cycle === 'once' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.cycle === 'once' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { this.cycle = 'once' })
        Text('每周重复')
          .fontSize(Theme.type.footnote)
          .fontColor(this.cycle === 'weekly' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(this.cycle === 'weekly' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { this.cycle = 'weekly' })
      }
      .width('100%')
      AppButton({
        label: '保存提醒',
        onTap: (): void => {
          this.onConfirm(`${this.dateText} ${this.timeText}`, FamilyService.reminderCopy(this.remain), this.cycle)
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
