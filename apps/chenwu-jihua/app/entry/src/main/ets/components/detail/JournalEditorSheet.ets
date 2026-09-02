import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CwDateUtil, CwJournalEntry } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'

@Component
export struct JournalEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwJournalId') editId: string = ''
  onChanged: () => void = () => {}
  @State dateKey: string = CwDateUtil.todayKey()
  @State doneToday: string = ''
  @State discovery: string = ''
  @State tomorrowAdjust: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findJournal(this.editId)
      if (found !== undefined) {
        this.dateKey = found.dateKey
        this.doneToday = found.doneToday
        this.discovery = found.discovery
        this.tomorrowAdjust = found.tomorrowAdjust
      }
    } else {
      const today = await ChenwuStore.journalForDate(CwDateUtil.todayKey())
      if (today !== undefined) {
        this.editId = today.id
        this.dateKey = today.dateKey
        this.doneToday = today.doneToday
        this.discovery = today.discovery
        this.tomorrowAdjust = today.tomorrowAdjust
      }
    }
  }

  private async save(): Promise<void> {
    if (this.doneToday.trim().length === 0 && this.discovery.trim().length === 0) {
      this.toastText = '请至少填写一项内容'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let j = new CwJournalEntry()
    if (this.editId.length > 0) {
      const found = await ChenwuStore.findJournal(this.editId)
      if (found !== undefined) {
        j = found
      }
    } else {
      j = CwJournalEntry.createNew(this.dateKey)
    }
    j.dateKey = this.dateKey
    j.doneToday = this.doneToday
    j.discovery = this.discovery
    j.tomorrowAdjust = this.tomorrowAdjust
    await ChenwuStore.saveJournal(j)
    this.toastText = '晨记已保存'
    this.onChanged()
    setTimeout((): void => {
      ChenwuDetailNav.closeJournalEditor()
    }, 400)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑晨记' : '写晨记', onClose: (): void => { ChenwuDetailNav.closeJournalEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(CwDateUtil.displayDate(this.dateKey))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.doneToday, placeholder: '今日完成了什么？' })
              .onChange((v: string): void => { this.doneToday = v })
              .height(80)
            TextArea({ text: this.discovery, placeholder: '今日发现了什么？' })
              .onChange((v: string): void => { this.discovery = v })
              .height(80)
            TextArea({ text: this.tomorrowAdjust, placeholder: '明日如何调整？（可选）' })
              .onChange((v: string): void => { this.tomorrowAdjust = v })
              .height(80)
            AppButton({ label: '保存', onTap: (): void => { void this.save() } })
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
