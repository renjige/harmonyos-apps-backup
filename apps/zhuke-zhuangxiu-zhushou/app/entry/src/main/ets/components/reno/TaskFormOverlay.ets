import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from './ChoiceChip'
import { RenoDates, RenoTask } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'

@Component
export struct TaskFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: RenoTask = new RenoTask()
  @State title: string = ''
  @State stage: string = '水电'
  @State status: string = 'todo'
  @State date: string = ''
  @State remindAt: string = ''
  @State remark: string = ''
  @State errorText: string = ''
  onSave: (draft: RenoTask) => void = (_d: RenoTask) => {}
  onClose: () => void = () => {}
  private stages: string[] = RenoDates.names()
  private statuses: string[] = ['todo', 'doing', 'done']

  aboutToAppear(): void {
    const current = RenoService.currentProject()
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.stage = this.seed.stage
      this.status = this.seed.status
      this.date = this.seed.date
      this.remindAt = this.seed.remindAt
      this.remark = this.seed.remark
      return
    }
    this.date = RenoDates.today()
    this.stage = current !== null ? current.stage : '水电'
    this.status = 'todo'
  }

  private statusLabel(code: string): string {
    return RenoDates.taskLabel(code)
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写事项名称'
      return
    }
    const current = RenoService.currentProject()
    const draft = new RenoTask()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.stage = this.stage
    draft.status = this.status
    draft.date = this.date
    draft.remindAt = this.remindAt
    draft.remark = this.remark
    draft.projectId = this.seed.projectId.length > 0 ? this.seed.projectId : (current !== null ? current.id : '')
    this.onSave(draft)
  }

  build() {
    Column() {
      Row() {
        Text(this.isEdit ? '编辑事项' : '新增事项')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('取消').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 12 })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .padding({ left: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: 14 }) {
          TextInput({ text: this.title, placeholder: '事项名称' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          Text('所属阶段').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.stages, (s: string) => {
              ChoiceChip({ label: s, active: this.stage === s, onPick: () => { this.stage = s } })
                .margin({ right: 8, bottom: 8 })
            }, (s: string) => s)
          }
          Text('状态').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.statuses, (s: string) => {
              ChoiceChip({
                label: this.statusLabel(s),
                active: this.status === s,
                onPick: () => { this.status = s }
              }).margin({ right: 8, bottom: 8 })
            }, (s: string) => s)
          }
          AppDatePickerField({
            label: '事项日期',
            value: this.date,
            minDaysFromToday: -30,
            maxDaysFromToday: 120,
            onChange: (v: string) => { this.date = v }
          })
          AppDatePickerField({
            label: '提醒日期（选填）',
            value: this.remindAt,
            placeholder: '不设置提醒',
            minDaysFromToday: 0,
            maxDaysFromToday: 180,
            onChange: (v: string) => { this.remindAt = v }
          })
          TextInput({ text: this.remark, placeholder: '备注（选填）' })
            .onChange((v: string) => { this.remark = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          AppButton({ label: this.isEdit ? '保存事项' : '添加事项', onTap: () => this.submit() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
