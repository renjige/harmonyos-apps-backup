import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AlbumWriteRequest } from '../../models/KagModels'
import { KagBizService } from '../../services/KagBizService'
import { KagNav } from '../../services/KagNav'
import { DetailShell } from './DetailShell'

@Component
export struct AlbumFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kagChildId') childId: string = ''
  @State title: string = ''
  @State summary: string = ''
  @State errorText: string = ''

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写画册名称'
      return
    }
    const body = new AlbumWriteRequest()
    body.title = this.title.trim()
    body.summary = this.summary
    body.childId = this.childId
    body.coverKey = 'empty_easel'
    const ok = await KagBizService.createAlbum(body)
    if (ok) {
      KagNav.bump()
      KagNav.close()
      return
    }
    this.errorText = '创建失败，请稍后重试'
  }

  build() {
    DetailShell({
      title: '新建画册',
      onBack: () => KagNav.close()
    }) {
      Column({ space: Theme.space.s4 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '例如：水彩作品集' })
          .onChange((v: string) => {
            this.title = v
          })
        TextArea({ text: this.summary, placeholder: '这本画册想记住什么' })
          .height(80)
          .onChange((v: string) => {
            this.summary = v
          })
        AppButton({
          label: '创建',
          variant: 'primary',
          onTap: () => {
            void this.save()
          }
        })
        AppEmpty({
          title: '小提示',
          description: '8 到 16 幅刚刚好。创建后可在作品详情里「加入画册」。'
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
