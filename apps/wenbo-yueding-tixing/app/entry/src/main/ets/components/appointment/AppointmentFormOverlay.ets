import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { AppointmentFormDraft, FreeSlot } from '../../models/AppointmentModels'
import { AppointmentLocalStore } from '../../services/AppointmentLocalStore'
import { AppointmentService } from '../../services/AppointmentService'
import { ScheduleEngine } from '../../services/ScheduleEngine'

class OptionChip {
  key: string = ''
  label: string = ''
}

@Component
export struct AppointmentFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: AppointmentFormDraft = new AppointmentFormDraft()
  @State errorText: string = ''
  @State sceneLocked: boolean = false
  @State freeSlots: FreeSlot[] = []
  @State favPlaces: string[] = []
  @State favContacts: string[] = []
  @Prop isEdit: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onSubmit: (draft: AppointmentFormDraft, context: common.UIAbilityContext) => Promise<boolean> = async () => false

  aboutToAppear(): void {
    if (this.draft.dueDate.length === 0) {
      this.draft.dueDate = AppointmentLocalStore.today()
    }
    if (this.draft.dueTime.length === 0) {
      this.draft.dueTime = '09:00'
    }
    if (this.draft.scene.length === 0) {
      this.draft.scene = 'life'
    }
    if (this.draft.durationMin <= 0) {
      this.draft.durationMin = 60
    }
    this.favPlaces = AppointmentLocalStore.places()
    this.favContacts = AppointmentLocalStore.contacts()
  }

  private remindOptions(): OptionChip[] {
    const a = new OptionChip(); a.key = '10'; a.label = '10 分钟'
    const b = new OptionChip(); b.key = '60'; b.label = '1 小时'
    const c = new OptionChip(); c.key = '1440'; c.label = '1 天'
    const d = new OptionChip(); d.key = 'custom'; d.label = '自定义'
    return [a, b, c, d]
  }

  private repeatOptions(): OptionChip[] {
    const a = new OptionChip(); a.key = 'once'; a.label = '不重复'
    const b = new OptionChip(); b.key = 'daily'; b.label = '每天'
    const c = new OptionChip(); c.key = 'weekly'; c.label = '每周'
    const d = new OptionChip(); d.key = 'monthly'; d.label = '每月'
    return [a, b, c, d]
  }

  private sceneOptions(): OptionChip[] {
    const a = new OptionChip(); a.key = 'work'; a.label = '工作'
    const b = new OptionChip(); b.key = 'life'; b.label = '生活'
    const c = new OptionChip(); c.key = 'study'; c.label = '学习'
    const d = new OptionChip(); d.key = 'health'; d.label = '健康'
    return [a, b, c, d]
  }

  private durationOptions(): OptionChip[] {
    const a = new OptionChip(); a.key = '30'; a.label = '30 分'
    const b = new OptionChip(); b.key = '60'; b.label = '1 小时'
    const c = new OptionChip(); c.key = '90'; c.label = '90 分'
    const d = new OptionChip(); d.key = '120'; d.label = '2 小时'
    return [a, b, c, d]
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text(this.isEdit ? '编辑约定' : '新建约定')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text('保存')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { void this.handleSave() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 8 })
        if (this.freeSlots.length > 0) {
          Column({ space: 8 }) {
            Text('推荐空闲时段（点选自动填入）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.freeSlots, (slot: FreeSlot) => {
              Text(slot.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.draft.dueDate = slot.date
                  this.draft.dueTime = slot.time
                  this.draft.allowOverlap = false
                  void this.handleSave()
                })
            }, (slot: FreeSlot) => `${slot.date}_${slot.time}`)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 8 })
        }
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.draft.title, placeholder: '例如：团队周会' })
              .onChange((v: string) => {
                this.draft.title = v
                if (!this.sceneLocked) {
                  this.draft.scene = ScheduleEngine.classifyScene(v, this.draft.note)
                  this.draft.prepLine = ScheduleEngine.defaultPrep(this.draft.scene)
                }
              })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('智能分类（可改）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.sceneOptions(), (opt: OptionChip) => {
                Text(opt.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.draft.scene === opt.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.draft.scene === opt.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.sceneLocked = true
                    this.draft.scene = opt.key
                    if (this.draft.prepLine.length === 0) {
                      this.draft.prepLine = ScheduleEngine.defaultPrep(opt.key)
                    }
                  })
              }, (opt: OptionChip) => opt.key)
            }
            .width('100%')
          }
          .width('100%')

          AppDatePickerField({
            label: '日期',
            value: this.draft.dueDate,
            minDaysFromToday: 0,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.draft.dueDate = v }
          })
          AppTimePickerField({
            label: '开始时间',
            value: this.draft.dueTime,
            onChange: (v: string) => { this.draft.dueTime = v }
          })
          Row() {
            Text(this.draft.allDay ? '全天约定（不按时段撞车检测）' : '按时段安排')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(this.draft.allDay ? '改为时段' : '改为全天')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.draft.allDay = !this.draft.allDay })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('时长')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.durationOptions(), (opt: OptionChip) => {
                Text(opt.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(`${this.draft.durationMin}` === opt.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(`${this.draft.durationMin}` === opt.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.draft.durationMin = parseInt(opt.key, 10) })
              }, (opt: OptionChip) => opt.key)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('地点（选填）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.draft.place, placeholder: '例如：3 楼会议室 / 线上' })
              .onChange((v: string) => { this.draft.place = v })
            if (this.favPlaces.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.favPlaces, (p: string) => {
                  Text(p)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 6 })
                    .onClick((): void => { this.draft.place = p })
                }, (p: string) => `p_${p}`)
              }
              .width('100%')
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('相关人（选填）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.draft.contactName, placeholder: '例如：客户王总 / 孩子' })
              .onChange((v: string) => { this.draft.contactName = v })
            if (this.favContacts.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.favContacts, (p: string) => {
                  Text(p)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 6 })
                    .onClick((): void => { this.draft.contactName = p })
                }, (p: string) => `c_${p}`)
              }
              .width('100%')
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('预留路上时间')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach([0, 10, 15, 30, 45], (mins: number) => {
                Text(mins === 0 ? '不需要' : `${mins} 分钟`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.draft.bufferMin === mins ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.draft.bufferMin === mins ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.draft.bufferMin = mins })
              }, (mins: number) => `buf_${mins}`)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('提前提醒')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.remindOptions(), (opt: OptionChip) => {
                Text(opt.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.draft.remindBeforeKey === opt.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.draft.remindBeforeKey === opt.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.draft.remindBeforeKey = opt.key })
              }, (opt: OptionChip) => opt.key)
            }
            .width('100%')
          }
          .width('100%')

          if (this.draft.remindBeforeKey === 'custom') {
            TextInput({ text: this.draft.customMinutes, placeholder: '自定义提前分钟数' })
              .type(InputType.Number)
              .onChange((v: string) => { this.draft.customMinutes = v })
          }

          Column({ space: 8 }) {
            Text('重复')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.repeatOptions(), (opt: OptionChip) => {
                Text(opt.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.draft.repeatType === opt.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.draft.repeatType === opt.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.draft.repeatType = opt.key })
              }, (opt: OptionChip) => opt.key)
            }
            .width('100%')
          }
          .width('100%')

          Row() {
            Text(this.draft.priority === 'high' ? '已标为重要' : '普通优先级')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(this.draft.priority === 'high' ? '取消重要' : '标为重要')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => {
                this.draft.priority = this.draft.priority === 'high' ? 'normal' : 'high'
              })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('备注')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.draft.note, placeholder: '可选：参与人、材料说明' })
              .height(80)
              .onChange((v: string) => { this.draft.note = v })
          }
          .width('100%')

          AppButton({
            label: this.isEdit ? '保存修改' : '创建约定',
            onTap: (): void => { void this.handleSave() }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private async handleSave(): Promise<void> {
    this.errorText = ''
    this.freeSlots = []
    const ctx = getContext(this) as common.UIAbilityContext
    const ok = await this.onSubmit(this.draft, ctx)
    if (ok) {
      this.onSaved()
      return
    }
    this.errorText = AppointmentService.lastError.length > 0 ?
      AppointmentService.lastError : '保存失败，请检查标题与日期'
    if (AppointmentService.lastConflictTitle.length > 0) {
      this.draft.allowOverlap = true
      this.freeSlots = await AppointmentService.conflictSlots(this.draft)
    }
  }
}
