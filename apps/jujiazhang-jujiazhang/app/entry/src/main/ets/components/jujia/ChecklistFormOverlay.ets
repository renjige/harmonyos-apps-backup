import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FormSheetHeader } from '../design-system/FormSheetHeader'
import { ChoiceChip } from '../family/ChoiceChip'
import { ChecklistKindOption } from '../../models/JujiaModels'

@Component
export struct ChecklistFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State kind: string = '日用品'
  @State errorText: string = ''
  onSave: (title: string, kind: string) => void = (_t: string, _k: string) => {}
  onClose: () => void = () => {}

  private submit(): void {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写清单名称'
      return
    }
    this.onSave(this.title.trim(), this.kind)
  }

  build() {
    Column() {
      FormSheetHeader({ title: '新建居家清单', onClose: () => this.onClose() })
      if (this.errorText.length > 0) {
        Text(this.errorText).fontSize(Theme.type.caption).fontColor(Theme.colors().danger)
          .width('100%').padding({ left: 20, right: 20, bottom: 8 })
      }
      Column({ space: 16 }) {
        TextInput({ text: this.title, placeholder: '如：周末大扫除、搬家准备' })
          .onChange((v: string) => { this.title = v })
        Text('清单类型').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(ChecklistKindOption.all(), (opt: ChecklistKindOption) => {
            ChoiceChip({ label: opt.label, active: this.kind === opt.value, onPick: () => { this.kind = opt.value } })
          }, (opt: ChecklistKindOption) => opt.value)
        }
        AppButton({ label: '创建清单', variant: 'primary', onTap: () => this.submit() })
      }
      .padding({ left: 20, right: 20, top: 8 })
    }
    .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
  }
}
