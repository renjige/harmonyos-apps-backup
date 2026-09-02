import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from './ChoiceChip'
import { RenoDates, RenoProject } from '../../models/RenoModels'

@Component
export struct ProjectFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: RenoProject = new RenoProject()
  @State title: string = ''
  @State houseType: string = '三室两厅'
  @State startDate: string = ''
  @State stage: string = '拆改'
  @State remark: string = ''
  @State budget: string = ''
  @State errorText: string = ''
  onSave: (draft: RenoProject) => void = (_d: RenoProject) => {}
  onClose: () => void = () => {}
  private houses: string[] = RenoDates.houseTypes()
  private stages: string[] = RenoDates.names()

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.houseType = this.seed.houseType
      this.startDate = this.seed.startDate
      this.stage = this.seed.stage
      this.remark = this.seed.remark
      this.budget = this.seed.budget
      return
    }
    this.startDate = RenoDates.today()
    this.stage = '拆改'
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写项目名称'
      return
    }
    const draft = new RenoProject()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.houseType = this.houseType
    draft.startDate = this.startDate
    draft.stage = this.stage
    draft.remark = this.remark
    draft.budget = this.budget.trim()
    draft.status = this.seed.status.length > 0 ? this.seed.status : 'active'
    draft.progress = this.seed.progress
    this.onSave(draft)
  }

  build() {
    Column() {
      this.Head()
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: 14 }) {
          TextInput({ text: this.title, placeholder: '项目名称，如小区名 · 户型' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          Text('房屋类型').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.houses, (h: string) => {
              ChoiceChip({ label: h, active: this.houseType === h, onPick: () => { this.houseType = h } })
                .margin({ right: 8, bottom: 8 })
            }, (h: string) => h)
          }
          AppDatePickerField({
            label: '开始日期',
            value: this.startDate,
            minDaysFromToday: -400,
            maxDaysFromToday: 30,
            onChange: (v: string) => { this.startDate = v }
          })
          Text('当前阶段').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.stages, (s: string) => {
              ChoiceChip({ label: s, active: this.stage === s, onPick: () => { this.stage = s } })
                .margin({ right: 8, bottom: 8 })
            }, (s: string) => s)
          }
          TextInput({ text: this.budget, placeholder: '预算金额（元，选填）' })
            .onChange((v: string) => { this.budget = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .type(InputType.Number)
          TextInput({ text: this.remark, placeholder: '备注（选填）' })
            .onChange((v: string) => { this.remark = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          AppButton({ label: this.isEdit ? '保存项目' : '创建项目', onTap: () => this.submit() })
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

  @Builder
  Head() {
    Row() {
      Text(this.isEdit ? '编辑项目' : '创建项目')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Text('取消')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .onClick(() => this.onClose())
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 12 })
  }
}
