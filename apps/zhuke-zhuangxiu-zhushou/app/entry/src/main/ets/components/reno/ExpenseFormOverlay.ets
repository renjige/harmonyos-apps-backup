import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from './ChoiceChip'
import { RenoDates, RenoExpense } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'

@Component
export struct ExpenseFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: RenoExpense = new RenoExpense()
  @State title: string = ''
  @State amount: string = ''
  @State category: string = '材料'
  @State date: string = ''
  @State remark: string = ''
  @State errorText: string = ''
  onSave: (draft: RenoExpense) => void = (_d: RenoExpense) => {}
  onClose: () => void = () => {}
  private cats: string[] = RenoDates.expenseCats()

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.amount = this.seed.amount
      this.category = this.seed.category
      this.date = this.seed.date
      this.remark = this.seed.remark
      return
    }
    this.date = RenoDates.today()
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写费用说明'
      return
    }
    if (RenoDates.money(this.amount) <= 0) {
      this.errorText = '请填写大于 0 的金额'
      return
    }
    const current = RenoService.currentProject()
    const draft = new RenoExpense()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.amount = `${RenoDates.money(this.amount)}`
    draft.category = this.category
    draft.date = this.date
    draft.remark = this.remark
    draft.projectId = this.seed.projectId.length > 0 ? this.seed.projectId : (current !== null ? current.id : '')
    this.onSave(draft)
  }

  build() {
    Column() {
      Row() {
        Text(this.isEdit ? '编辑费用' : '记一笔费用')
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
          .width('100%')
          .padding({ left: Theme.space.pageX, bottom: 8 })
      }
      Scroll() {
        Column({ space: 14 }) {
          TextInput({ text: this.title, placeholder: '例如：瓷砖定金、木工中期款' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          TextInput({ text: this.amount, placeholder: '金额（元）' })
            .onChange((v: string) => { this.amount = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .type(InputType.Number)
          Text('类别').fontSize(Theme.type.caption).fontColor(Theme.colors().textTertiary).width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cats, (c: string) => {
              ChoiceChip({ label: c, active: this.category === c, onPick: () => { this.category = c } })
                .margin({ right: 8, bottom: 8 })
            }, (c: string) => c)
          }
          AppDatePickerField({
            label: '发生日期',
            value: this.date,
            minDaysFromToday: -400,
            maxDaysFromToday: 1,
            onChange: (v: string) => { this.date = v }
          })
          TextInput({ text: this.remark, placeholder: '备注（选填，不含支付）' })
            .onChange((v: string) => { this.remark = v })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
          AppButton({ label: this.isEdit ? '保存费用' : '记入账本', onTap: () => this.submit() })
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
