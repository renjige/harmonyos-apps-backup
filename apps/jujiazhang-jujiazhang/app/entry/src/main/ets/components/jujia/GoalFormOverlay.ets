import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FormSheetHeader } from '../design-system/FormSheetHeader'

@Component
export struct GoalFormOverlay {
  @State title: string = ''
  @State target: string = '10'
  onClose: () => void = () => {}
  onSave: (title: string, target: number) => void = (_t: string, _n: number) => {}

  build() {
    Column() {
      FormSheetHeader({ title: '新建家庭目标', onClose: () => this.onClose() })
      Column({ space: 12 }) {
        TextInput({ text: this.title, placeholder: '例如：本月整理 3 个房间' })
          .onChange((v: string) => { this.title = v })
        TextInput({ text: this.target, placeholder: '目标数量（默认 10）' })
          .onChange((v: string) => { this.target = v })
        Row() {
          AppButton({
            label: '保存目标',
            variant: 'primary',
            onTap: (): void => {
              const n = Number.parseInt(this.target)
              this.onSave(this.title, Number.isNaN(n) ? 10 : n)
            }
          })
        }
        .width('100%')
        .onClick((): void => {
          const n = Number.parseInt(this.target)
          this.onSave(this.title, Number.isNaN(n) ? 10 : n)
        })
      }
      .padding(16)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
