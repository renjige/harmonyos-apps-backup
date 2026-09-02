import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FormSheetHeader } from '../design-system/FormSheetHeader'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChoiceChip } from '../family/ChoiceChip'
import { HomeItem, ItemCategoryOption, ItemTagOption, RemindLeadOption, RoomOption } from '../../models/JujiaModels'

@Component
export struct ItemFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: HomeItem = new HomeItem()
  @State name: string = ''
  @State category: string = '其他'
  @State purchaseDate: string = ''
  @State expiryDate: string = ''
  @State location: string = ''
  @State room: string = ''
  @State customTag: string = ''
  @State remark: string = ''
  @State remindLeadDays: number = 0
  @State errorText: string = ''
  onSave: (draft: HomeItem) => void = (_d: HomeItem) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    if (this.isEdit && this.seed.name.length > 0) {
      this.name = this.seed.name
      this.category = this.seed.category
      this.purchaseDate = this.seed.purchaseDate
      this.expiryDate = this.seed.expiryDate
      this.location = this.seed.location
      this.room = this.seed.room
      this.customTag = this.seed.customTag
      this.remark = this.seed.remark
      this.remindLeadDays = this.seed.remindLeadDays
    }
  }

  private submit(): void {
    if (this.name.trim().length === 0) {
      this.errorText = '请填写物品名称'
      return
    }
    const draft = new HomeItem()
    draft.id = this.seed.id
    draft.name = this.name.trim()
    draft.category = this.category
    draft.purchaseDate = this.purchaseDate
    draft.expiryDate = this.expiryDate
    draft.location = this.location.trim()
    draft.room = this.room
    draft.customTag = this.customTag
    draft.remark = this.remark.trim()
    draft.remindLeadDays = this.remindLeadDays
    this.onSave(draft)
  }

  build() {
    Column() {
      FormSheetHeader({
        title: this.isEdit ? '编辑物品' : '登记物品',
        onClose: (): void => { this.onClose() }
      })

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
            Text('物品名称')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.name, placeholder: '如：冰箱、身份证、常备药' })
              .onChange((v: string) => { this.name = v })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(ItemCategoryOption.all(), (opt: ItemCategoryOption) => {
                ChoiceChip({
                  label: opt.label,
                  active: this.category === opt.value,
                  onPick: () => { this.category = opt.value }
                })
              }, (opt: ItemCategoryOption) => opt.value)
            }
          }
          .width('100%')

          AppDatePickerField({
            label: '购买日期',
            value: this.purchaseDate,
            onChange: (v: string) => { this.purchaseDate = v }
          })

          AppDatePickerField({
            label: '到期日期',
            value: this.expiryDate,
            onChange: (v: string) => { this.expiryDate = v }
          })

          Column({ space: 8 }) {
            Text('系统到期提醒')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text('到达所选时间后，会在通知栏弹出系统提醒（需允许通知）。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(RemindLeadOption.all(), (opt: RemindLeadOption) => {
                ChoiceChip({
                  label: opt.label,
                  active: this.remindLeadDays === opt.days,
                  onPick: () => { this.remindLeadDays = opt.days }
                })
              }, (opt: RemindLeadOption) => `lead_${opt.days}`)
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('所在房间')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(RoomOption.all(), (opt: RoomOption) => {
                ChoiceChip({ label: opt.label, active: this.room === opt.value, onPick: () => { this.room = opt.value } })
              }, (opt: RoomOption) => opt.value)
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('物品标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(ItemTagOption.all(), (opt: ItemTagOption) => {
                ChoiceChip({ label: opt.label, active: this.customTag === opt.value, onPick: () => { this.customTag = opt.value } })
              }, (opt: ItemTagOption) => opt.value)
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('存放位置')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.location, placeholder: '如：厨房、药箱、抽屉' })
              .onChange((v: string) => { this.location = v })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('备注')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.remark, placeholder: '保修说明、使用提醒…' })
              .height(88)
              .onChange((v: string) => { this.remark = v })
          }
          .width('100%')

          AppButton({
            label: this.isEdit ? '保存修改' : '登记物品',
            variant: 'primary',
            onTap: () => this.submit()
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
