import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from './ChoiceChip'
import { FamilyTaskItem, TaskDates } from '../../models/FamilyTaskModels'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct TaskFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: FamilyTaskItem = new FamilyTaskItem()
  @State title: string = ''
  @State dateMode: string = 'today'
  @State date: string = ''
  @State time: string = ''
  @State reminder: string = 'none'
  @State category: string = '其他'
  @State repeatType: string = 'none'
  @State errorText: string = ''
  onSave: (draft: FamilyTaskItem) => void = (_d: FamilyTaskItem) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.date = this.seed.date
      this.time = this.seed.time
      this.reminder = this.seed.reminder
      this.category = this.seed.category
      this.repeatType = this.seed.repeatType
      this.dateMode = 'custom'
      return
    }
    this.date = TaskDates.today()
    this.dateMode = 'today'
    const def = AppStorage.get<string>('defaultReminder') ?? 'none'
    this.reminder = def
  }

  private pickDate(mode: string): void {
    this.dateMode = mode
    if (mode === 'today') {
      this.date = TaskDates.today()
    }
    if (mode === 'tomorrow') {
      this.date = TaskDates.tomorrow()
    }
  }

  private onTitleChange(v: string): void {
    this.title = v
    if (!this.isEdit) {
      this.category = CategorySuggest.suggest(v)
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写事项名称'
      return
    }
    const draft = new FamilyTaskItem()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.date = this.date.length > 0 ? this.date : TaskDates.today()
    draft.time = this.time
    draft.reminder = this.reminder
    draft.category = this.category
    draft.repeatType = this.repeatType
    this.onSave(draft)
  }

  build() {
    Column() {
      Row() {
        Text(this.isEdit ? '编辑事项' : '新建事项')
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
      .padding({ left: 20, right: 20, top: 18, bottom: 8 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 8 })
      }

      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 8 }) {
            Text('事项名称')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '例如：买牛奶' })
              .onChange((v: string) => this.onTitleChange(v))
              .height(48)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.input)
          }

          Column({ space: 8 }) {
            Text('时间')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              ChoiceChip({ label: '今天', active: this.dateMode === 'today', onPick: () => this.pickDate('today') })
              ChoiceChip({ label: '明天', active: this.dateMode === 'tomorrow', onPick: () => this.pickDate('tomorrow') })
              ChoiceChip({ label: '自定义', active: this.dateMode === 'custom', onPick: () => this.pickDate('custom') })
            }
            .width('100%')
            if (this.dateMode === 'custom') {
              AppDatePickerField({
                label: '选择日期',
                value: this.date,
                minDaysFromToday: 0,
                maxDaysFromToday: 365,
                onChange: (v: string) => { this.date = v }
              })
            }
            AppTimePickerField({
              label: '具体时间（可选）',
              value: this.time,
              placeholder: '不选则为全天',
              onChange: (v: string) => { this.time = v }
            })
          }

          Column({ space: 8 }) {
            Text('提醒')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ChoiceChip({ label: '不提醒', active: this.reminder === 'none', onPick: () => { this.reminder = 'none' } })
              ChoiceChip({ label: '提前 10 分钟', active: this.reminder === '10', onPick: () => { this.reminder = '10' } })
              ChoiceChip({ label: '提前 30 分钟', active: this.reminder === '30', onPick: () => { this.reminder = '30' } })
              ChoiceChip({ label: '提前 1 小时', active: this.reminder === '60', onPick: () => { this.reminder = '60' } })
            }
            .width('100%')
          }

          Column({ space: 8 }) {
            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(CategorySuggest.categories(), (c: string) => {
                ChoiceChip({ label: c, active: this.category === c, onPick: () => { this.category = c } })
              }, (c: string) => c)
            }
            .width('100%')
          }

          Column({ space: 8 }) {
            Text('重复')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ChoiceChip({ label: '不重复', active: this.repeatType === 'none', onPick: () => { this.repeatType = 'none' } })
              ChoiceChip({ label: '每天', active: this.repeatType === 'daily', onPick: () => { this.repeatType = 'daily' } })
              ChoiceChip({ label: '每周', active: this.repeatType === 'weekly', onPick: () => { this.repeatType = 'weekly' } })
              ChoiceChip({ label: '每月', active: this.repeatType === 'monthly', onPick: () => { this.repeatType = 'monthly' } })
            }
            .width('100%')
          }

          AppButton({
            label: this.isEdit ? '保存' : '完成',
            variant: 'primary',
            onTap: () => this.submit()
          })
        }
        .padding({ left: 20, right: 20, bottom: 40, top: 8 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
