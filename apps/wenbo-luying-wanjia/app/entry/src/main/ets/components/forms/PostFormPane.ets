import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct PostFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State body: string = ''
  @State errorText: string = ''

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 || this.body.trim().length === 0) {
      this.errorText = '请填写标题和正文'
      return
    }
    const req = new CampWriteRequest()
    req.title = this.title.trim()
    req.body = this.body.trim()
    req.summary = this.body.trim().substring(0, 60)
    req.coverKey = 'guide_tent'
    req.authorName = CampBizService.username()
    const ok = await CampBizService.create('posts', req)
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '发布失败'
  }

  build() {
    DetailShell({ title: '发布攻略', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '标题' })
          .onChange((v: string) => { this.title = v })
        TextArea({ text: this.body, placeholder: '装备评测、营地建议、过夜经验。不含打赏。' })
          .height(180)
          .onChange((v: string) => { this.body = v })
        AppButton({ label: '发布', onTap: () => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
