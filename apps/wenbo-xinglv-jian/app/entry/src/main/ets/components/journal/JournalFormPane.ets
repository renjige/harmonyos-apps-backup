import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { JournalEntry } from '../../models/JournalModels'
import { TripDateHelp } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct JournalFormPane {
  @StorageLink('journalFormId') @Watch('onId') formId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State location: string = ''
  @State tag: string = 'scenery'
  @State recordDate: string = ''
  @State errorText: string = ''
  @State isEdit: boolean = false

  aboutToAppear(): void {
    this.hydrate()
  }

  onId(): void {
    this.hydrate()
  }

  onTok(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.errorText = ''
    this.isEdit = this.formId.length > 0
    if (!this.isEdit) {
      this.title = ''
      this.body = ''
      this.location = ''
      this.tag = 'scenery'
      this.recordDate = TripDateHelp.todayIso()
      return
    }
    const j = TripStore.findJournal(this.formId)
    if (j === undefined) {
      this.errorText = '找不到这条记录。'
      return
    }
    this.title = j.title
    this.body = j.body
    this.location = j.location
    this.tag = j.tag
    this.recordDate = j.recordDate
  }

  private cycleTag(): void {
    if (this.tag === 'scenery') {
      this.tag = 'food'
    } else if (this.tag === 'food') {
      this.tag = 'culture'
    } else {
      this.tag = 'scenery'
    }
  }

  private tagLabel(): string {
    if (this.tag === 'food') {
      return '美食'
    }
    if (this.tag === 'culture') {
      return '人文'
    }
    return '风景'
  }

  private coverKey(): string {
    if (this.tag === 'food') {
      return 'journal_food'
    }
    return 'journal_scenery'
  }

  private async submit(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    const item = new JournalEntry()
    item.id = this.isEdit ? this.formId : TripStore.newJournalId()
    item.title = this.title.trim()
    item.body = this.body.trim()
    item.location = this.location.trim()
    item.tag = this.tag
    item.coverKey = this.coverKey()
    item.recordDate = this.recordDate
    item.updatedAt = Date.now()
    if (!this.isEdit) {
      item.createdAt = Date.now()
    } else {
      const old = TripStore.findJournal(this.formId)
      item.createdAt = old !== undefined ? old.createdAt : Date.now()
    }
    await TripStore.saveJournal(item)
    TripNav.closeJournalForm()
    AppToast.show(this.isEdit ? '记录已更新' : '旅迹已保存')
  }

  build() {
    Column() {
      AppNavBar({
        title: this.isEdit ? '编辑旅迹' : '写旅迹',
        onBack: (): void => { TripNav.closeJournalForm() }
      })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.palette(this.darkModeOn).danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '标题，如：西湖晨雾' })
            .onChange((v: string) => { this.title = v })
          AppDatePickerField({
            label: '记录日期',
            value: this.recordDate,
            onChange: (v: string): void => { this.recordDate = v }
          })
          TextInput({ text: this.location, placeholder: '地点（选填）' })
            .onChange((v: string) => { this.location = v })
          Row() {
            Text('标签')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            Blank()
            Text(this.tagLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.darkModeOn).brandAccent)
              .onClick((): void => { this.cycleTag() })
          }
          .width('100%')
          TextArea({ text: this.body, placeholder: '写下此刻的感受与见闻…' })
            .height(160)
            .onChange((v: string) => { this.body = v })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      AppButton({
        label: this.isEdit ? '保存修改' : '保存旅迹',
        onTap: (): void => { void this.submit() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
