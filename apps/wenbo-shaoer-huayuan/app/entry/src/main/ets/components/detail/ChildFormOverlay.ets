import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ChildWriteRequest } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct ChildFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State birthYear: string = ''
  @State note: string = ''
  @State errorText: string = ''

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写孩子称呼'
      return
    }
    const body = new ChildWriteRequest()
    body.title = this.title.trim()
    body.name = this.title.trim()
    body.birthYear = this.birthYear
    body.note = this.note
    const ok = await KagBizService.createChild(body)
    if (ok) {
      KagNav.bump()
      KagNav.close()
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  build() {
    DetailShell({
      title: '添加孩子',
      onBack: () => KagNav.close()
    }) {
      Column({ space: Theme.space.s4 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '称呼，例如：果果' })
          .onChange((v: string) => {
            this.title = v
          })
        TextInput({ text: this.birthYear, placeholder: '出生年，例如：2020' })
          .onChange((v: string) => {
            this.birthYear = v
          })
        TextArea({ text: this.note, placeholder: '可选备注' })
          .height(72)
          .onChange((v: string) => {
            this.note = v
          })
        AppButton({
          label: '保存档案',
          variant: 'primary',
          onTap: () => {
            void this.save()
          }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
