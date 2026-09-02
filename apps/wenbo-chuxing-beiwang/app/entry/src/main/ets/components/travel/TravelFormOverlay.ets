import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { ChoiceChip } from './TravelCards'
import {
  CreateChecklistRequest,
  CreateItineraryRequest,
  CreateNoteRequest,
  CreateReminderRequest,
  CreateTripRequest,
  TravelEditSeed
} from '../../models/TravelModels'
import { TravelService } from '../../services/TravelService'

export type TravelFormMode = 'trip' | 'itinerary' | 'checklist' | 'reminder' | 'note'

@Component
export struct TravelFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: TravelFormMode = 'trip'
  @Prop tripId: string = ''
  @Prop editId: string = ''
  @Prop @Watch('applySeed') editSeed: TravelEditSeed = new TravelEditSeed()
  @State title: string = ''
  @State destination: string = ''
  @State startDate: string = ''
  @State endDate: string = ''
  @State detail: string = ''
  @State category: string = '证件'
  @State reminderType: string = '出发'
  @State remindAt: string = ''
  @State startTime: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSaved: (message: string) => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.applySeed()
  }

  applySeed(): void {
    if (this.editId.length === 0) {
      return
    }
    this.title = this.editSeed.title
    this.destination = this.editSeed.destination
    this.startDate = this.editSeed.startDate
    this.endDate = this.editSeed.endDate
    this.detail = this.editSeed.detail
    this.category = this.editSeed.category.length > 0 ? this.editSeed.category : '证件'
    this.reminderType = this.editSeed.reminderType.length > 0 ? this.editSeed.reminderType : '出发'
    this.remindAt = this.editSeed.remindAt
    this.startTime = this.editSeed.startTime
  }

  private heading(): string {
    const editing = this.editId.length > 0
    if (this.mode === 'trip') {
      return editing ? '编辑行程' : '创建行程'
    }
    if (this.mode === 'checklist') {
      return editing ? '编辑清单事项' : '创建清单事项'
    }
    if (this.mode === 'itinerary') {
      return editing ? '编辑每日安排' : '添加每日安排'
    }
    if (this.mode === 'reminder') {
      return editing ? '编辑提醒' : '创建提醒'
    }
    return editing ? '编辑备忘' : '记录备忘'
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  private async submit(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    this.errorText = ''
    this.submitting = true
    let ok = false
    try {
      if (this.mode === 'trip') {
        if (this.destination.trim().length === 0 || this.startDate.length === 0 || this.endDate.length === 0) {
          this.errorText = '请完整填写目的地和日期'
          this.submitting = false
          return
        }
        const body = new CreateTripRequest()
        body.title = this.title.trim()
        body.destination = this.destination.trim()
        body.startDate = this.startDate
        body.endDate = this.endDate
        body.summary = this.detail.trim()
        if (this.editId.length > 0) {
          ok = await TravelService.updateTrip(this.editId, body)
        } else {
          const trip = await TravelService.createTrip(body)
          ok = trip !== undefined
        }
      } else if (this.mode === 'itinerary') {
        const linkedTrip = this.tripId.length > 0 ? this.tripId : this.editSeed.tripId
        if (linkedTrip.length === 0 || this.startDate.length === 0) {
          this.errorText = '请选择行程并填写安排日期'
          this.submitting = false
          return
        }
        const body = new CreateItineraryRequest()
        body.title = this.title.trim()
        body.tripId = linkedTrip
        body.itemDate = this.startDate
        body.startTime = this.startTime.trim()
        body.location = this.destination.trim()
        body.note = this.detail.trim()
        if (this.editId.length > 0) {
          ok = await TravelService.updateItinerary(this.editId, body)
        } else {
          ok = await TravelService.createItinerary(body)
        }
      } else if (this.mode === 'checklist') {
        const body = new CreateChecklistRequest()
        body.title = this.title.trim()
        body.category = this.category
        body.tripId = this.tripId.length > 0 ? this.tripId : this.editSeed.tripId
        if (this.editId.length > 0) {
          ok = await TravelService.updateChecklist(this.editId, body)
        } else {
          ok = await TravelService.createChecklist(body)
        }
      } else if (this.mode === 'reminder') {
        if (this.remindAt.length === 0) {
          this.errorText = '请选择提醒日期'
          this.submitting = false
          return
        }
        const body = new CreateReminderRequest()
        body.title = this.title.trim()
        body.reminderType = this.reminderType
        body.remindAt = this.remindAt
        body.note = this.detail.trim()
        body.tripId = this.tripId.length > 0 ? this.tripId : this.editSeed.tripId
        if (this.editId.length > 0) {
          ok = await TravelService.updateReminder(this.editId, body)
        } else {
          ok = await TravelService.createReminder(body)
        }
      } else {
        const body = new CreateNoteRequest()
        body.title = this.title.trim()
        body.body = this.detail.trim()
        body.tripId = this.tripId.length > 0 ? this.tripId : this.editSeed.tripId
        if (this.editId.length > 0) {
          ok = await TravelService.updateNote(this.editId, body)
        } else {
          ok = await TravelService.createNote(body)
        }
      }
    } catch {
      ok = false
    }
    this.submitting = false
    if (ok) {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.onSaved('保存成功')
      return
    }
    this.errorText = '保存失败，请检查网络后重试'
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.close())
        Text(this.heading())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: this.mode === 'trip' ? '行程名称' : '事项标题' })
            .height(52)
            .padding({ left: 14, right: 14 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onChange((value: string) => { this.title = value })
          if (this.mode === 'trip') {
            TextInput({ text: this.destination, placeholder: '目的地' })
              .height(52)
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((value: string) => { this.destination = value })
            AppDatePickerField({ label: '出发日期', value: this.startDate,
              onChange: (value: string) => { this.startDate = value } })
            AppDatePickerField({ label: '返程日期', value: this.endDate,
              onChange: (value: string) => { this.endDate = value } })
          }
          if (this.mode === 'checklist') {
            Text('选择分类').fontSize(Theme.type.subhead).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Row({ space: Theme.space.s2 }) {
              ChoiceChip({ label: '证件', selected: this.category === '证件',
                onTap: () => { this.category = '证件' } })
              ChoiceChip({ label: '衣物', selected: this.category === '衣物',
                onTap: () => { this.category = '衣物' } })
              ChoiceChip({ label: '设备', selected: this.category === '设备',
                onTap: () => { this.category = '设备' } })
              ChoiceChip({ label: '用品', selected: this.category === '用品',
                onTap: () => { this.category = '用品' } })
            }
          }
          if (this.mode === 'itinerary') {
            AppDatePickerField({ label: '安排日期', value: this.startDate,
              onChange: (value: string) => { this.startDate = value } })
            TextInput({ text: this.startTime, placeholder: '开始时间，如 09:30' })
              .height(52)
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((value: string) => { this.startTime = value })
            TextInput({ text: this.destination, placeholder: '地点（选填）' })
              .height(52)
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((value: string) => { this.destination = value })
          }
          if (this.mode === 'reminder') {
            Text('提醒类型').fontSize(Theme.type.subhead).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Row({ space: Theme.space.s2 }) {
              ChoiceChip({ label: '出发', selected: this.reminderType === '出发',
                onTap: () => { this.reminderType = '出发' } })
              ChoiceChip({ label: '入住', selected: this.reminderType === '入住',
                onTap: () => { this.reminderType = '入住' } })
              ChoiceChip({ label: '自定义', selected: this.reminderType === '自定义',
                onTap: () => { this.reminderType = '自定义' } })
            }
            AppDatePickerField({ label: '提醒日期', value: this.remindAt,
              onChange: (value: string) => { this.remindAt = value } })
          }
          if (this.mode === 'trip' || this.mode === 'itinerary' ||
            this.mode === 'reminder' || this.mode === 'note') {
            TextArea({ text: this.detail, placeholder: this.mode === 'note' ? '写下交通、地址或注意事项' : '补充说明（选填）' })
              .height(128)
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((value: string) => { this.detail = value })
          }
          if (this.errorText.length > 0) {
            Text(this.errorText).fontSize(Theme.type.caption).fontColor(Theme.colors().danger).width('100%')
          }
          AppButton({ label: this.submitting ? '正在保存…' : (this.editId.length > 0 ? '保存修改' : '保存'), disabled: this.submitting,
            onTap: () => { void this.submit() } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
