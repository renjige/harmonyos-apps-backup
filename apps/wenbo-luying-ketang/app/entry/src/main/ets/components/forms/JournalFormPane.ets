import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct JournalFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State body: string = ''
  @State daysText: string = '1'
  @State errorText: string = ''
  @State saving: boolean = false

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    if (this.body.trim().length === 0) {
      this.errorText = '请写下这次露营'
      return
    }
    const days = Number.parseInt(this.daysText, 10)
    this.saving = true
    const req = new CampWriteRequest()
    req.title = this.title.trim()
    req.body = this.body.trim()
    req.days = Number.isNaN(days) ? 1 : days
    req.coverKey = 'hero_camp_night'
    req.summary = this.body.trim().substring(0, 48)
    const ok = await CampBizService.create('journals', req)
    this.saving = false
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '保存失败'
  }

  build() {
    DetailShell({ title: '新建露营记录', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '给这次过夜起个名字' })
          .onChange((v: string) => { this.title = v })
        TextInput({ text: this.daysText, placeholder: '过夜天数' })
          .onChange((v: string) => { this.daysText = v })
        TextArea({ text: this.body, placeholder: '风、虫鸣、炉火，写下来。' })
          .height(160)
          .onChange((v: string) => { this.body = v })
        AppButton({ label: this.saving ? '保存中…' : '写下记录', onTap: () => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
