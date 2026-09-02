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

  private pickCover(): string {
    const keys: string[] = ['guide_tent', 'guide_rain', 'guide_cook', 'guide_stars', 'guide_kids']
    const seed = this.title.length + this.body.length
    return keys[seed % keys.length]
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 || this.body.trim().length === 0) {
      this.errorText = '请填写标题和正文'
      return
    }
    const req = new CampWriteRequest()
    req.title = this.title.trim()
    req.body = this.body.trim()
    req.summary = this.body.trim().substring(0, 60)
    req.coverKey = this.pickCover()
    req.authorName = CampBizService.username()
    const ok = await CampBizService.create('posts', req)
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '发布失败，请稍后重试'
  }

  build() {
    DetailShell({ title: '发布笔记', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '笔记标题' })
          .onChange((v: string) => { this.title = v })
        TextArea({ text: this.body, placeholder: '分享露营学习心得、装备体验或行程记录。不含打赏与外链。' })
          .height(180)
          .onChange((v: string) => { this.body = v })
        AppButton({ label: '发布到社区', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
