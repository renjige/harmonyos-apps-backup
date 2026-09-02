import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { XuAgendaItem, XuDateHelper } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuBizService } from '../../services/XuBizService'
import { XuDetailNav } from '../../services/XuDetailNav'

@Component
export struct AgendaEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onPresetChange') presetDate: string = ''
  @State title: string = ''
  @State remark: string = ''
  @State dateKey: string = ''
  @State timeText: string = ''
  @State priority: string = 'mid'
  @State kind: string = 'todo'
  @State remindOn: boolean = true
  @State errorText: string = ''
  onSaved: () => void = () => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.applyPresetDate()
    void this.hydrate()
  }

  onPresetChange(): void {
    this.applyPresetDate()
  }

  private applyPresetDate(): void {
    if (this.presetDate.length > 0) {
      this.dateKey = this.presetDate
      return
    }
    if (this.dateKey.length === 0) {
      this.dateKey = XuDateHelper.todayKey()
    }
  }

  private async hydrate(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await XuLocalStore.findAgenda(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.remark = found.remark
      this.dateKey = found.dateKey
      this.timeText = found.timeText
      this.priority = found.priority
      this.kind = found.kind
      this.remindOn = found.remindOn
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    if (this.dateKey.length === 0) {
      this.dateKey = XuDateHelper.todayKey()
    }
    let item = new XuAgendaItem()
    if (this.editId.length > 0) {
      const found = await XuLocalStore.findAgenda(this.editId)
      if (found !== undefined) {
        item = found
      }
    } else {
      item = XuAgendaItem.create(this.kind, this.title.trim(), this.dateKey, this.timeText, this.priority)
    }
    item.title = this.title.trim()
    item.remark = this.remark
    item.dateKey = this.dateKey
    item.timeText = this.timeText
    item.priority = this.priority
    item.kind = this.kind
    item.remindOn = this.remindOn
    item.updatedAt = Date.now()
    await XuLocalStore.saveAgenda(item)
    XuLocalStore.publishHomeStats()
    XuDetailNav.markAgendaFocus(item.dateKey)
    void XuBizService.syncAgenda(item)
    this.onSaved()
    this.onClose()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.editId.length > 0 ? '编辑日程' : '新建日程 / 待办')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.title, placeholder: '标题' })
        .onChange((v: string) => { this.title = v })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      TextArea({ text: this.remark, placeholder: '备注（可选）' })
        .onChange((v: string) => { this.remark = v })
        .height(88)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      Row({ space: Theme.space.s3 }) {
        this.Chip('待办', 'todo')
        this.Chip('日程', 'event')
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        this.Prio('高', 'high')
        this.Prio('中', 'mid')
        this.Prio('低', 'low')
      }
      .width('100%')
      AppDatePickerField({
        label: '日期',
        value: this.dateKey,
        minDaysFromToday: -30,
        maxDaysFromToday: 180,
        onChange: (v: string) => { this.dateKey = v }
      })
      AppTimePickerField({
        label: '时间（可选）',
        value: this.timeText,
        onChange: (v: string) => { this.timeText = v }
      })
      Row() {
        Text('计入首页智慧提醒')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.remindOn })
          .onChange((v: boolean) => { this.remindOn = v })
          .selectedColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      if (this.errorText.length > 0) {
        Text(this.errorText).fontSize(Theme.type.footnote).fontColor(Theme.colors().danger).width('100%')
      }
      AppButton({ label: '保存', onTap: (): void => { void this.save() } })
      AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.onClose() } })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Chip(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.kind === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.kind === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.kind = value })
  }

  @Builder
  Prio(label: string, value: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.priority === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.priority === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.priority = value })
  }
}
