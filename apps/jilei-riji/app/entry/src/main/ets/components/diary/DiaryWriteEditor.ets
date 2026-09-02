import { Theme } from '../design-system/Theme'
import { RichTextToolbar } from './RichTextToolbar'

@Component
export struct DiaryWriteEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedBody: string = ''
  @Prop @Watch('onSeedUpdate') seedVersion: number = 0
  @State editorKey: number = 0
  private draftBody: string = ''
  private notifyTimer: number = -1
  onDraftChange: (text: string) => void = () => {}
  onFormatToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.draftBody = this.seedBody
  }

  aboutToDisappear(): void {
    if (this.notifyTimer >= 0) {
      clearTimeout(this.notifyTimer)
      this.notifyTimer = -1
    }
    this.onDraftChange(this.draftBody)
  }

  private onSeedUpdate(): void {
    this.draftBody = this.seedBody
    this.editorKey++
  }

  private flushDraftSoon(): void {
    if (this.notifyTimer >= 0) {
      clearTimeout(this.notifyTimer)
    }
    this.notifyTimer = setTimeout((): void => {
      this.notifyTimer = -1
      this.onDraftChange(this.draftBody)
    }, 500)
  }

  private appendSnippet(snippet: string): void {
    if (this.draftBody.length === 0) {
      this.draftBody = snippet.trimStart()
    } else {
      this.draftBody = `${this.draftBody}${snippet}`
    }
    this.editorKey++
    this.onDraftChange(this.draftBody)
  }

  private handleFormat(kind: string): void {
    if (kind === 'bold') {
      this.appendSnippet(' **文字**')
      this.onFormatToast('已插入粗体标记 **文字**')
      return
    }
    if (kind === 'italic') {
      this.appendSnippet(' *文字*')
      this.onFormatToast('已插入斜体标记 *文字*')
      return
    }
    const prefix = this.draftBody.length > 0 && !this.draftBody.endsWith('\n') ? '\n' : ''
    this.appendSnippet(`${prefix}• `)
    this.onFormatToast('已插入列表项')
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      TextArea({ text: this.draftBody, placeholder: '今天发生了什么？写下今天的积累…' })
        .key(`diary_editor_${this.editorKey}`)
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .padding(Theme.space.s3)
        .fontSize(Theme.type.bodyL)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .onChange((v: string) => {
          // 仅写私有字段，不触发 @State，避免连按退格时整页重绘卡死
          this.draftBody = v
          this.flushDraftSoon()
        })

      Text('支持 **粗体**、*斜体*、• 列表；点保存后在时间轴详情可预览格式')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(18)

      RichTextToolbar({
        onAction: (kind: string): void => { this.handleFormat(kind) }
      })
    }
    .width('100%')
    .height('100%')
  }
}
