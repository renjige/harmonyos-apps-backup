import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FormSheetHeader } from '../design-system/FormSheetHeader'
import { ChoiceChip } from '../family/ChoiceChip'
import { FamilyMemo, MemoTagOption } from '../../models/JujiaModels'

@Component
export struct MemoFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop isEdit: boolean = false
  @Prop seed: FamilyMemo = new FamilyMemo()
  @State title: string = ''
  @State body: string = ''
  @State tag: string = '采购'
  @State pinned: boolean = false
  @State errorText: string = ''
  onSave: (draft: FamilyMemo) => void = (_d: FamilyMemo) => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    if (this.isEdit && this.seed.title.length > 0) {
      this.title = this.seed.title
      this.body = this.seed.body
      this.tag = this.seed.tag
      this.pinned = this.seed.pinned
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写备忘标题'
      return
    }
    const draft = new FamilyMemo()
    draft.id = this.seed.id
    draft.title = this.title.trim()
    draft.body = this.body.trim()
    draft.tag = this.tag
    draft.pinned = this.pinned
    this.onSave(draft)
  }

  build() {
    Column() {
      FormSheetHeader({
        title: this.isEdit ? '编辑备忘' : '新建备忘',
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
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '如：周末采购清单' })
              .onChange((v: string) => { this.title = v })
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('标签')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(MemoTagOption.all(), (opt: MemoTagOption) => {
                ChoiceChip({
                  label: opt.label,
                  active: this.tag === opt.value,
                  onPick: () => { this.tag = opt.value }
                })
              }, (opt: MemoTagOption) => opt.value)
            }
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('内容')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.body, placeholder: '写下家人共享的清单、计划或提醒…' })
              .height(140)
              .onChange((v: string) => { this.body = v })
          }
          .width('100%')

          Row({ space: 10 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.pinned })
              .onChange((v: boolean) => { this.pinned = v })
            Text('置顶备忘')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('100%')

          AppButton({
            label: this.isEdit ? '保存修改' : '保存备忘',
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
