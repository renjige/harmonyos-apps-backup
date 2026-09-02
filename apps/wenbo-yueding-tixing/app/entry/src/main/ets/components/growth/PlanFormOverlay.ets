import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppDatePickerField } from '../../components/design-system/AppDatePickerField'
import { PlanFormDraft } from '../../models/GrowthModels'
import { AppointmentLocalStore } from '../../services/AppointmentLocalStore'

@Component
export struct PlanFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: PlanFormDraft = new PlanFormDraft()
  @Prop isEdit: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onSubmit: (draft: PlanFormDraft) => Promise<boolean> = async () => false

  aboutToAppear(): void {
    if (this.draft.startDate.length === 0) {
      this.draft.startDate = AppointmentLocalStore.today()
    }
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text(this.isEdit ? '编辑计划' : '新建计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('保存')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { void this.handleSave() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          TextInput({ text: this.draft.title, placeholder: '计划名称，如「本月守约 12 次」' })
            .onChange((v: string) => { this.draft.title = v })
          TextInput({ text: this.draft.description, placeholder: '计划说明（选填）' })
            .onChange((v: string) => { this.draft.description = v })
          TextInput({ text: this.draft.targetCount, placeholder: '目标次数' })
            .type(InputType.Number)
            .onChange((v: string) => { this.draft.targetCount = v })
          AppDatePickerField({
            label: '开始日期',
            value: this.draft.startDate,
            minDaysFromToday: -365,
            maxDaysFromToday: 730,
            onChange: (iso: string): void => { this.draft.startDate = iso }
          })
          AppDatePickerField({
            label: '结束日期（选填）',
            value: this.draft.endDate,
            minDaysFromToday: -365,
            maxDaysFromToday: 730,
            onChange: (iso: string): void => { this.draft.endDate = iso }
          })
          Row({ space: 8 }) {
            ForEach(['work', 'life', 'study', 'health'], (key: string) => {
              Text(key === 'work' ? '工作' : key === 'life' ? '生活' : key === 'study' ? '学习' : '健康')
                .fontSize(Theme.type.caption)
                .fontColor(this.draft.scene === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.draft.scene === key ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.draft.scene = key })
            }, (key: string) => key)
          }
          .width('100%')
          AppButton({
            label: '保存计划',
            onTap: (): void => { void this.handleSave() }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  private async handleSave(): Promise<void> {
    const ok = await this.onSubmit(this.draft)
    if (ok) {
      this.onSaved()
    }
  }
}
