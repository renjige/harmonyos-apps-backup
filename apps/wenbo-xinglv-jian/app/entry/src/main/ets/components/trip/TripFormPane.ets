import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { TripDateHelp, TripItem } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct TripFormPane {
  @StorageLink('tripFormId') @Watch('onId') formId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State title: string = ''
  @State startDate: string = ''
  @State endDate: string = ''
  @State location: string = ''
  @State remark: string = ''
  @State remind: number = 0
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
      this.startDate = TripDateHelp.todayIso()
      this.endDate = TripDateHelp.todayIso()
      this.location = ''
      this.remark = ''
      this.remind = 0
      return
    }
    const t = TripStore.findTrip(this.formId)
    if (t === undefined) {
      this.errorText = '找不到这条行程。'
      return
    }
    this.title = t.title
    this.startDate = t.startDate
    this.endDate = t.endDate
    this.location = t.location
    this.remark = t.remark
    this.remind = t.reminderOffset
  }

  private nextRemind(): void {
    if (this.remind === 0) {
      this.remind = 10
    } else if (this.remind === 10) {
      this.remind = 30
    } else if (this.remind === 30) {
      this.remind = 60
    } else if (this.remind === 60) {
      this.remind = 1440
    } else {
      this.remind = 0
    }
  }

  private async submit(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写行程名称'
      return
    }
    if (this.startDate.length === 0) {
      this.errorText = '请选择开始日期'
      return
    }
    if (this.endDate.length === 0) {
      this.endDate = this.startDate
    }
    if (this.endDate < this.startDate) {
      this.errorText = '结束日期不能早于开始日期'
      return
    }
    const item = this.isEdit && TripStore.findTrip(this.formId) !== undefined ?
      TripStore.findTrip(this.formId) as TripItem : new TripItem()
    if (!this.isEdit) {
      item.id = TripStore.newTripId()
      item.createdAt = Date.now()
      item.status = 'upcoming'
    }
    item.title = this.title.trim()
    item.startDate = this.startDate
    item.endDate = this.endDate
    item.location = this.location.trim()
    item.remark = this.remark.trim()
    item.reminderOffset = this.remind
    item.updatedAt = Date.now()
    item.status = TripDateHelp.liveTripStatus(item, TripDateHelp.todayIso())
    await TripStore.saveTrip(item)
    AppToast.show(this.isEdit ? '行程已更新' : '行程已创建')
    TripNav.closeForm()
    TripNav.openDetail(item.id)
  }

  build() {
    Column() {
      AppNavBar({
        title: this.isEdit ? '编辑行程' : '新建行程',
        onBack: (): void => { TripNav.closeForm() }
      })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.palette(this.darkModeOn).danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          this.Field('行程名称', this.title, '例如：客户拜访', (v: string) => { this.title = v })
          AppDatePickerField({
            label: '开始日期',
            value: this.startDate,
            placeholder: '请选择开始日期',
            minDaysFromToday: -365,
            maxDaysFromToday: 365,
            onChange: (v: string) => {
              this.startDate = v
              if (this.endDate.length === 0 || this.endDate < v) {
                this.endDate = v
              }
            }
          })
          AppDatePickerField({
            label: '结束日期',
            value: this.endDate,
            placeholder: '请选择结束日期',
            minDaysFromToday: -365,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.endDate = v }
          })
          this.Field('地点', this.location, '可选', (v: string) => { this.location = v })
          this.Field('备注', this.remark, '可选', (v: string) => { this.remark = v })
          Row() {
            Column({ space: 4 }) {
              Text('智慧提醒')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.palette(this.darkModeOn).textTertiary)
                .width('100%')
              Text(TripDateHelp.remindLabel(this.remind))
                .fontSize(Theme.type.body)
                .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                .width('100%')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.nextRemind() })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: 24
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      Column() {
        AppButton({
          label: this.isEdit ? '保存' : '创建行程',
          onTap: (): void => { void this.submit() }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s5
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }

  @Builder
  Field(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.palette(this.darkModeOn).textTertiary)
        .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .fontSize(Theme.type.body)
        .fontColor(Theme.palette(this.darkModeOn).textPrimary)
        .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
        .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
        .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
        .borderRadius(Theme.radius.sm)
        .padding({ left: 12, right: 12 })
        .height(48)
        .onChange(onChange)
    }
    .width('100%')
  }
}
