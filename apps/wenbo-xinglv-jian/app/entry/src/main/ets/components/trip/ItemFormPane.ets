import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { MemoItem, TripDateHelp } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct ItemFormPane {
  @StorageLink('itemFormTripId') tripId: string = ''
  @StorageLink('itemFormId') @Watch('onId') itemId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State title: string = ''
  @State itemDate: string = ''
  @State time: string = ''
  @State location: string = ''
  @State remark: string = ''
  @State remind: number = 0
  @State status: string = 'pending'
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
    this.isEdit = this.itemId.length > 0
    if (!this.isEdit) {
      this.title = ''
      const trip = TripStore.findTrip(this.tripId)
      this.itemDate = trip !== undefined ? trip.startDate : TripDateHelp.todayIso()
      this.time = '09:00'
      this.location = ''
      this.remark = ''
      this.remind = 0
      this.status = 'pending'
      return
    }
    const n = TripStore.findItem(this.itemId)
    if (n === undefined) {
      this.errorText = '找不到这条事项。'
      return
    }
    this.title = n.title
    this.itemDate = n.itemDate
    this.time = n.time
    this.location = n.location
    this.remark = n.remark
    this.remind = n.reminderOffset
    this.status = n.status
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

  private nextStatus(): void {
    if (this.status === 'pending') {
      this.status = 'ongoing'
    } else if (this.status === 'ongoing') {
      this.status = 'done'
    } else if (this.status === 'done') {
      this.status = 'cancelled'
    } else {
      this.status = 'pending'
    }
  }

  private statusLabel(): string {
    if (this.status === 'ongoing') {
      return '进行中'
    }
    if (this.status === 'done') {
      return '已完成'
    }
    if (this.status === 'cancelled') {
      return '已取消'
    }
    return '待开始'
  }

  private async submit(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写事项名称'
      return
    }
    if (this.tripId.length === 0) {
      this.errorText = '请先选择行程'
      return
    }
    let item = TripStore.findItem(this.itemId)
    if (item === undefined) {
      item = new MemoItem()
      item.id = TripStore.newItemId()
      item.createdAt = Date.now()
    }
    item.tripId = this.tripId
    item.title = this.title.trim()
    item.itemDate = this.itemDate.length > 0 ? this.itemDate : TripDateHelp.todayIso()
    item.time = this.time
    item.location = this.location.trim()
    item.remark = this.remark.trim()
    item.reminderOffset = this.remind
    item.status = this.status
    item.updatedAt = Date.now()
    await TripStore.saveItem(item)
    AppToast.show(this.isEdit ? '事项已更新' : '事项已保存')
    TripNav.closeItemForm()
  }

  private async remove(): Promise<void> {
    if (this.itemId.length === 0) {
      TripNav.closeItemForm()
      return
    }
    await TripStore.removeItem(this.itemId)
    AppToast.show('事项已删除')
    TripNav.closeItemForm()
  }

  build() {
    Column() {
      AppNavBar({
        title: this.isEdit ? '编辑事项' : '新增事项',
        onBack: (): void => { TripNav.closeItemForm() }
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
          Column({ space: 4 }) {
            Text('事项名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.palette(this.darkModeOn).textTertiary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '例如：客户会议' })
              .fontSize(Theme.type.body)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
              .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
              .height(48)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.title = v })
          }
          .width('100%')
          AppDatePickerField({
            label: '日期',
            value: this.itemDate,
            minDaysFromToday: -365,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.itemDate = v }
          })
          AppTimePickerField({
            label: '时间',
            value: this.time,
            placeholder: '请选择时间',
            onChange: (v: string) => { this.time = v }
          })
          Column({ space: 4 }) {
            Text('地点')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.palette(this.darkModeOn).textTertiary)
              .width('100%')
            TextInput({ text: this.location, placeholder: '可选' })
              .height(48)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
              .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.location = v })
          }
          .width('100%')
          Column({ space: 4 }) {
            Text('备注')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.palette(this.darkModeOn).textTertiary)
              .width('100%')
            TextInput({ text: this.remark, placeholder: '可选' })
              .height(48)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .placeholderColor(Theme.palette(this.darkModeOn).textTertiary)
              .caretColor(Theme.palette(this.darkModeOn).brandPrimary)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.remark = v })
          }
          .width('100%')
          this.TapRow('智慧提醒', TripDateHelp.remindLabel(this.remind), (): void => { this.nextRemind() })
          this.TapRow('状态', this.statusLabel(), (): void => { this.nextStatus() })
          if (this.isEdit) {
            Text('删除事项')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.darkModeOn).danger)
              .padding({ top: 8 })
              .onClick((): void => { void this.remove() })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      Row({ space: 12 }) {
        AppButton({
          label: '取消',
          variant: 'secondary',
          onTap: (): void => { TripNav.closeItemForm() }
        })
          .layoutWeight(1)
        AppButton({
          label: '保存',
          onTap: (): void => { void this.submit() }
        })
          .layoutWeight(1)
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
  TapRow(label: string, value: string, onTap: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.palette(this.darkModeOn).textTertiary)
          .width('100%')
        Text(value)
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
    .onClick(onTap)
  }
}
