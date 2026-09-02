import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CwDateUtil, CwHabit, CwHabitEntry } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct HabitRecordSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwHabitId') habitId: string = ''
  onChanged: () => void = () => {}
  @State habit: CwHabit = new CwHabit()
  @State note: string = ''
  @State changeNote: string = ''
  @State done: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    const found = await ChenwuStore.findHabit(this.habitId)
    if (found !== undefined) {
      this.habit = found
    }
    const today = CwDateUtil.todayKey()
    const entries = await ChenwuStore.entriesForHabit(this.habitId)
    for (const e of entries) {
      if (e.dateKey === today) {
        this.note = e.note
        this.changeNote = e.changeNote
        this.done = e.done
      }
    }
  }

  private async save(): Promise<void> {
    const today = CwDateUtil.todayKey()
    const entries = await ChenwuStore.entriesForHabit(this.habitId)
    let entry = CwHabitEntry.createNew(this.habitId, today)
    for (const e of entries) {
      if (e.dateKey === today) {
        entry = e
      }
    }
    entry.note = this.note
    entry.changeNote = this.changeNote
    entry.done = this.done
    await ChenwuStore.saveHabitEntry(entry)
    this.toastText = this.done ? '打卡成功' : '已保存记录'
    this.onChanged()
    setTimeout((): void => {
      ChenwuDetailNav.closeHabitRecord()
    }, 400)
  }

  build() {
    Stack() {
      DetailShell({ title: '习惯打卡', onClose: (): void => { ChenwuDetailNav.closeHabitRecord() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.habit.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(CwDateUtil.displayDate(CwDateUtil.todayKey()))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row() {
              Text('今日完成')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.done })
                .onChange((v: boolean): void => { this.done = v })
            }
            .width('100%')
            TextArea({ text: this.note, placeholder: '今日记录（可选）' })
              .onChange((v: string): void => { this.note = v })
              .height(80)
            TextArea({ text: this.changeNote, placeholder: '变化与感受（可选）' })
              .onChange((v: string): void => { this.changeNote = v })
              .height(80)
            AppButton({ label: '保存打卡', onTap: (): void => { void this.save() } })
            Column().height(Theme.space.s8)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
