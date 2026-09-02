import { Theme } from '../design-system/Theme'
import { RichTextToolbar } from './RichTextToolbar'

@Component
export struct EssayWriteEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedBody: string = ''
  @Prop @Watch('onSeedUpdate') seedVersion: number = 0
  @Prop fontScale: number = 1
  @Prop @Watch('onFlushRequest') flushNonce: number = 0
  @State displayBody: string = ''
  private draftBody: string = ''
  onDraftChange: (text: string) => void = () => {}
  onFormatToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.draftBody = this.seedBody
    this.displayBody = this.seedBody
  }

  aboutToDisappear(): void {
    this.onDraftChange(this.draftBody)
  }

  private onSeedUpdate(): void {
    this.draftBody = this.seedBody
    this.displayBody = this.seedBody
  }

  private onFlushRequest(): void {
    this.onDraftChange(this.draftBody)
  }

  private appendSnippet(snippet: string): void {
    if (this.draftBody.length === 0) {
      this.draftBody = snippet.trimStart()
    } else {
      this.draftBody = `${this.draftBody}${snippet}`
    }
    this.displayBody = this.draftBody
    this.onDraftChange(this.draftBody)
  }

  private handleFormat(kind: string): void {
    if (kind === 'bold') {
      this.appendSnippet(' **文字**')
      this.onFormatToast('已插入粗体标记')
      return
    }
    if (kind === 'italic') {
      this.appendSnippet(' *文字*')
      this.onFormatToast('已插入斜体标记')
      return
    }
    if (kind === 'underline') {
      this.appendSnippet(' __文字__')
      this.onFormatToast('已插入下划线标记')
      return
    }
    const prefix = this.draftBody.length > 0 && !this.draftBody.endsWith('\n') ? '\n' : ''
    this.appendSnippet(`${prefix}• `)
    this.onFormatToast('已插入列表项')
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      TextArea({ text: this.displayBody, placeholder: '写下此刻的观察与灵感…' })
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
        .padding(Theme.space.s3)
        .fontSize(Theme.type.bodyL * this.fontScale)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .onChange((v: string) => {
          this.draftBody = v
          this.displayBody = v
          this.onDraftChange(this.draftBody)
        })

      Text('支持 **粗体**、*斜体*、__下划线__、• 列表')
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
