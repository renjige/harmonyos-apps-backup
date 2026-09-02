import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import { CoverPicker } from './CoverPicker'
import {
  CreateRecordRequest,
  GrowthRecordItem,
  UpdateRecordRequest
} from '../../models/GrowthModels'
import { MonthThemeUtil } from '../../models/StuckWorkshop'
import { GrowthBizService } from '../../services/GrowthBizService'
import { AuthService } from '../../services/AuthService'

@Component
export struct RecordEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop mode: string = 'create'
  @Prop editItem: GrowthRecordItem | undefined = undefined
  @Prop allRecords: GrowthRecordItem[] = []
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = 'hero_latest_inspiration'
  @State formError: string = ''
  @State submitting: boolean = false

  aboutToAppear(): void {
    if (this.mode === 'edit' && this.editItem !== undefined) {
      this.formTitle = this.editItem.title
      this.formBody = this.editItem.body
      this.formTags = this.editItem.tags.join(', ')
      this.formDate = this.editItem.recordDate
      this.formCoverKey = this.editItem.coverKey.length > 0 ?
        this.editItem.coverKey : 'hero_latest_inspiration'
    } else {
      this.formDate = RecordEditorSheet.todayIso()
    }
  }

  private static todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const tags = this.parseTags(this.formTags)
    const monthTheme = MonthThemeUtil.findTheme(this.allRecords)
    if (monthTheme.length > 0 && tags.indexOf(monthTheme) < 0) {
      tags.push(monthTheme)
    }
    if (this.mode === 'edit' && this.editItem !== undefined) {
      const req = new UpdateRecordRequest()
      req.title = this.formTitle.trim()
      req.body = this.formBody.trim()
      req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
      req.tags = tags
      req.recordDate = this.formDate.length > 0 ? this.formDate : RecordEditorSheet.todayIso()
      req.coverKey = this.formCoverKey
      req.userId = this.currentUsername
      const updated = await GrowthBizService.updateRecord(this.editItem.id, req)
      this.submitting = false
      if (updated !== undefined) {
        this.onSaved()
        this.onClose()
      } else {
        this.formError = GrowthBizService.lastError.length > 0 ?
          GrowthBizService.lastError : '保存失败'
      }
      return
    }
    const req = new CreateRecordRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = tags
    req.recordDate = this.formDate.length > 0 ? this.formDate : RecordEditorSheet.todayIso()
    req.coverKey = this.formCoverKey
    req.userId = this.currentUsername
    const created = await GrowthBizService.createRecord(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.onClose()
    } else {
      this.formError = '保存失败，请稍后重试'
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.mode === 'edit' ? '编辑成长记录' : '记录成长')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.formTitle, placeholder: '给成长起个名字…' })
            .width('100%')
            .height(44)
            .onChange((v: string) => { this.formTitle = v })
          AppDatePickerField({
            label: '记录日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.formDate = v }
          })
          TextArea({ text: this.formBody, placeholder: '写下今天的观察、突破与感受…' })
            .width('100%')
            .height(160)
            .onChange((v: string) => { this.formBody = v })
          TextInput({ text: this.formTags, placeholder: '标签，逗号分隔，如：学习, 健康' })
            .width('100%')
            .height(44)
            .onChange((v: string) => { this.formTags = v })
          CoverPicker({
            selectedKey: this.formCoverKey,
            onSelect: (key: string): void => { this.formCoverKey = key }
          })
          AppButton({
            label: this.submitting ? '保存中…' : '保存',
            onTap: (): void => { void this.submit() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
