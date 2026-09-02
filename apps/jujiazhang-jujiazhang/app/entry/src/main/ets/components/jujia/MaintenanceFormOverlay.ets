import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { FormSheetHeader } from '../design-system/FormSheetHeader'
import { ChoiceChip } from '../family/ChoiceChip'
import { MaintenanceCycleOption, MaintenanceJob, RoomOption } from '../../models/JujiaModels'

@Component
export struct MaintenanceFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: MaintenanceJob = new MaintenanceJob()
  @State title: string = ''
  @State room: string = '客厅'
  @State cycleDays: number = 90
  @State lastDoneDate: string = ''
  @State remark: string = ''
  @State errorText: string = ''
  onSave: (draft: MaintenanceJob) => void = (_d: MaintenanceJob) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.room = this.seed.room
      this.cycleDays = this.seed.cycleDays
      this.lastDoneDate = this.seed.lastDoneDate
      this.remark = this.seed.remark
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写维护项目名称'
      return
    }
    const draft = new MaintenanceJob()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.room = this.room
    draft.cycleDays = this.cycleDays
    draft.lastDoneDate = this.lastDoneDate
    draft.remark = this.remark.trim()
    this.onSave(draft)
  }

  build() {
    Column() {
      FormSheetHeader({ title: this.isEdit ? '编辑维护' : '添加维护提醒', onClose: () => this.onClose() })
      Scroll() {
        Column({ space: 16 }) {
          TextInput({ text: this.title, placeholder: '如：清洗空调、更换滤芯' })
            .onChange((v: string) => { this.title = v })
          Text('所在空间').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(RoomOption.all(), (opt: RoomOption) => {
              ChoiceChip({ label: opt.label, active: this.room === opt.value, onPick: () => { this.room = opt.value } })
            }, (opt: RoomOption) => opt.value)
          }
          Text('维护周期').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(MaintenanceCycleOption.all(), (opt: MaintenanceCycleOption) => {
              ChoiceChip({
                label: opt.label,
                active: this.cycleDays === opt.days,
                onPick: () => { this.cycleDays = opt.days }
              })
            }, (opt: MaintenanceCycleOption) => `c_${opt.days}`)
          }
          AppDatePickerField({
            label: '上次维护日期（可选）',
            value: this.lastDoneDate,
            onChange: (v: string) => { this.lastDoneDate = v }
          })
          TextArea({ text: this.remark, placeholder: '维护说明、注意事项…' })
            .height(88).onChange((v: string) => { this.remark = v })
          AppButton({ label: this.isEdit ? '保存' : '添加提醒', variant: 'primary', onTap: () => this.submit() })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10, top: 8 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
  }
}
