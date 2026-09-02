import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct TripFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State title: string = ''
  @State startAt: string = ''
  @State peopleText: string = '2'
  @State daysText: string = '2'
  @State errorText: string = ''
  @State saving: boolean = false

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '请填写目的地'
      return
    }
    if (this.startAt.length === 0) {
      this.errorText = '请选择出发日期'
      return
    }
    const people = Number.parseInt(this.peopleText, 10)
    const days = Number.parseInt(this.daysText, 10)
    if (Number.isNaN(people) || people < 1) {
      this.errorText = '人数至少为 1'
      return
    }
    if (Number.isNaN(days) || days < 1) {
      this.errorText = '天数至少为 1'
      return
    }
    this.saving = true
    const body = new CampWriteRequest()
    body.title = this.title.trim()
    body.startAt = this.startAt
    body.people = people
    body.days = days
    body.summary = `${this.startAt} · ${people} 人 · ${days} 夜`
    const ok = await CampBizService.create('trips', body)
    this.saving = false
    if (ok) {
      CampDetailNav.close()
      return
    }
    this.errorText = '保存失败，请稍后重试'
  }

  build() {
    DetailShell({ title: '规划行程', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        Text('目的地')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.title, placeholder: '例如 莫干山竹海营地' })
          .onChange((v: string) => { this.title = v })
        AppDatePickerField({
          label: '出发日期',
          value: this.startAt,
          onChange: (v: string) => { this.startAt = v }
        })
        Text('同行人数')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.peopleText, placeholder: '2' })
          .onChange((v: string) => { this.peopleText = v })
        Text('过夜天数')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.daysText, placeholder: '2' })
          .onChange((v: string) => { this.daysText = v })
        AppButton({
          label: this.saving ? '保存中…' : '创建行程',
          onTap: () => { void this.save() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
