import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct NoteFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop campId: string = ''
  @State body: string = ''
  @State errorText: string = ''

  private async save(): Promise<void> {
    if (this.body.trim().length === 0) {
      this.errorText = '请填写笔记'
      return
    }
    const req = new CampWriteRequest()
    req.title = '营地笔记'
    req.body = this.body.trim()
    req.campId = this.campId
    const ok = await CampBizService.create('notes', req)
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '保存失败'
  }

  build() {
    DetailShell({ title: '营地笔记', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextArea({ text: this.body, placeholder: '风口、水位、淋浴时段…只写给你自己看。' })
          .height(180)
          .onChange((v: string) => { this.body = v })
        AppButton({ label: '保存笔记', onTap: () => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
