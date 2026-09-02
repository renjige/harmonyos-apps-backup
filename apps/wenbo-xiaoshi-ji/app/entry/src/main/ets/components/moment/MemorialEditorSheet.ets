import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { LifeMemorial } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'
import { MemorialReminderService } from '../../services/MemorialReminderService'
import { AppContextService } from '../../services/AppContextService'

@Component
export struct MemorialEditorSheet {
  @Prop memorialId: string = ''
  onDone: () => void = () => {}
  @State title: string = ''
  @State dateKey: string = ''
  @State time: string = '09:00'
  @State note: string = ''
  @State reminderOn: boolean = true
  @State toast: string = ''
  @State confirmDelete: boolean = false
  @State saving: boolean = false
  private agentId: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.memorialId.length === 0) {
      this.dateKey = DateHelper.todayKey()
      return
    }
    const item = await MomentStore.findMemorial(this.memorialId)
    if (item === undefined) {
      this.dateKey = DateHelper.todayKey()
      return
    }
    this.title = item.title
    this.dateKey = item.dateKey
    this.time = item.time
    this.note = item.note
    this.reminderOn = item.enabled
    this.agentId = item.agentId
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    const name = this.title.trim()
    if (name.length === 0) {
      this.showToast('请填写纪念日名称')
      return
    }
    if (this.dateKey.length < 10) {
      this.showToast('请选择日期')
      return
    }
    this.saving = true
    const item = this.memorialId.length > 0 ? (await MomentStore.findMemorial(this.memorialId)) : undefined
    const m = item !== undefined ? item : LifeMemorial.createNew()
    m.title = name
    m.dateKey = this.dateKey
    m.time = this.time.length >= 5 ? this.time : '09:00'
    m.note = this.note.trim()
    m.enabled = this.reminderOn
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      m.agentId = await MemorialReminderService.schedule(m, ctx)
    } else {
      MemorialReminderService.lastAction = '已保存纪念日'
    }
    const ok = await MomentStore.saveMemorial(m)
    this.saving = false
    if (!ok) {
      this.showToast('保存失败，请填写名称和日期')
      return
    }
    const action = MemorialReminderService.lastAction
    if (action.indexOf('请允许') >= 0 || action.indexOf('失败') >= 0 || action.indexOf('已过') >= 0) {
      this.showToast(action)
      return
    }
    this.onDone()
  }

  private async remove(): Promise<void> {
    if (this.memorialId.length === 0) {
      this.onDone()
      return
    }
    const agentId = await MomentStore.deleteMemorial(this.memorialId)
    await MemorialReminderService.cancelAgent(agentId)
    this.onDone()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick((): void => this.onDone())
          Text(this.memorialId.length > 0 ? '编辑纪念日' : '添加纪念日')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 4, top: 8, bottom: 8 })
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s5 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('名称')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '如：妈妈生日、结婚纪念日' })
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.title = v })

            AppDatePickerField({
              label: '日期',
              value: this.dateKey,
              placeholder: '请选择日期',
              minDaysFromToday: 0,
              maxDaysFromToday: 400,
              onChange: (v: string): void => { this.dateKey = v }
            })
            AppTimePickerField({
              label: '提醒时间',
              value: this.time,
              placeholder: '请选择时间',
              onChange: (v: string): void => { this.time = v }
            })

            Row() {
              Text('到点系统提醒')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.reminderOn })
                .selectedColor(Theme.colors().brandPrimary)
                .onChange((v: boolean): void => { this.reminderOn = v })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(12)

            Text('纪念内容（选填）')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '想对这一天说的话…' })
              .height(88)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.note = v })

            AppButton({
              label: '保存纪念日',
              onTap: (): void => { void this.save() }
            })

            if (this.memorialId.length > 0) {
              if (!this.confirmDelete) {
                AppButton({
                  label: '删除纪念日',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmDelete = true }
                })
              } else {
                Column({ space: Theme.space.s2 }) {
                  Text('删除后提醒一并取消，不可恢复')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().danger)
                    .width('100%')
                  AppButton({
                    label: '确认删除',
                    variant: 'danger',
                    onTap: (): void => { void this.remove() }
                  })
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmDelete = false }
                  })
                }
                .width('100%')
              }
            }
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
