import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearWriteRequest } from '../../models/GearModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct PostFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State body: string = ''
  @State errorText: string = ''
  @State saving: boolean = false

  private async save(): Promise<void> {
    if (this.body.trim().length === 0) {
      this.errorText = '请填写动态内容'
      return
    }
    this.saving = true
    const req = new GearWriteRequest()
    req.title = this.title.trim().length > 0 ? this.title.trim() : this.body.trim().substring(0, 24)
    req.body = this.body.trim()
    req.summary = req.body.substring(0, 80)
    req.coverKey = 'banner_ready'
    req.authorName = GearBizService.username()
    const ok = await GearBizService.create('posts', req)
    this.saving = false
    if (ok) {
      GearDetailNav.close()
      return
    }
    this.errorText = '发布失败，请稍后重试'
  }

  build() {
    DetailShell({ title: '发布动态', onClose: () => GearDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '标题（可选）' })
          .onChange((v: string) => { this.title = v })
        TextArea({ text: this.body, placeholder: '分享装备使用或路线心得' })
          .height(160)
          .onChange((v: string) => { this.body = v })
        AppButton({
          label: this.saving ? '发布中…' : '发布',
          disabled: this.saving,
          onTap: (): void => { void this.save() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
