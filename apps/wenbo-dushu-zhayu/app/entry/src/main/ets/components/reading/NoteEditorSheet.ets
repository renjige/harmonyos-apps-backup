import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { PatchNoteRequest } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'

/** 笔记编辑 / 删除确认 */
@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'edit'
  @Prop noteId: string = ''
  @Prop initialTitle: string = ''
  @Prop initialBody: string = ''
  @Prop initialTags: string = ''
  @Prop initialDate: string = ''
  onClose: () => void = () => {}
  onDone: (kind: string) => void = (kind: string) => { if (kind.length < 0) { return } }
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    this.formTitle = this.initialTitle
    this.formBody = this.initialBody
    this.formTags = this.initialTags
    this.formDate = this.initialDate
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

  private async saveEdit(): Promise<void> {
    if (this.formTitle.trim().length === 0 || this.formBody.trim().length === 0) {
      this.errorText = '请填写标题和正文'
      return
    }
    this.submitting = true
    const req = new PatchNoteRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate
    const updated = await ReadingBizService.patchNote(this.noteId, req)
    this.submitting = false
    if (updated !== undefined) {
      this.onDone('saved')
      return
    }
    this.errorText = '保存失败，请稍后重试'
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
        Text(this.mode === 'delete' ? '删除笔记' : '编辑笔记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.mode === 'delete') {
            Text(`确认删除「${this.initialTitle}」？删除后不可恢复。`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            AppButton({
              label: '确认删除',
              variant: 'danger',
              onTap: (): void => { this.onDone('delete') }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          } else {
            TextInput({ text: this.formTitle, placeholder: '笔记标题' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
            AppDatePickerField({
              label: '记录日期',
              value: this.formDate,
              minDaysFromToday: -3650,
              maxDaysFromToday: 0,
              onChange: (v: string) => { this.formDate = v }
            })
            TextArea({ text: this.formBody, placeholder: '笔记正文…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(180)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
            TextInput({ text: this.formTags, placeholder: '标签，逗号分隔' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
            AppButton({
              label: this.submitting ? '保存中…' : '保存修改',
              disabled: this.submitting,
              onTap: (): void => { void this.saveEdit() }
            })
          }
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
  }
}
