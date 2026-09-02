import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { BodyRichText } from './BodyRichText'
import { FrameTemplate, InsightEntry, InsightNotebook, TitleGuard, VerdictGuard } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { InsightStore } from '../../services/InsightStore'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AppContextService } from '../../services/AppContextService'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { MarkupService } from '../../services/MarkupService'

@Component
export struct EditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entryId: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State title: string = ''
  @State body: string = ''
  @State tags: string = ''
  @State notebookId: string = 'nb_work'
  @State imagePath: string = ''
  @State books: InsightNotebook[] = []
  @State toastText: string = ''
  @State existingId: string = ''
  @State selStart: number = 0
  @State selEnd: number = 0
  @State frameKind: string = ''
  @State starred: boolean = false
  @State pinned: boolean = false
  @State reviewNote: string = ''
  @State verdict: string = ''
  private frames: FrameTemplate[] = FrameTemplate.all()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.books = await InsightStore.loadNotebooks()
    if (this.entryId.length === 0) {
      this.existingId = ''
      return
    }
    const found = await InsightStore.findById(this.entryId)
    if (found === undefined) {
      return
    }
    this.existingId = found.id
    this.title = found.title
    this.body = found.body
    this.tags = found.tags
    this.notebookId = found.notebookId
    this.imagePath = found.imagePath
    this.frameKind = found.frameKind
    this.starred = found.starred
    this.pinned = found.pinned
    this.reviewNote = found.reviewNote
    this.verdict = found.verdict
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private applyWrap(open: string, close: string): void {
    this.body = MarkupService.wrap(this.body, this.selStart, this.selEnd, open, close)
    this.showToast('已应用格式，下方预览可见加粗/斜体')
  }

  private applyLinePrefix(prefix: string): void {
    this.body = MarkupService.insertLinePrefix(this.body, this.selStart, prefix)
    this.showToast('已插入段落格式')
  }

  private applyFrame(t: FrameTemplate): void {
    this.frameKind = t.id
    if (t.id === 'judge' && this.verdict.length === 0) {
      this.verdict = VerdictGuard.pending()
    }
    if (this.body.trim().length === 0) {
      this.body = t.body
    } else {
      this.body = `${t.body}${this.body}`
    }
    this.showToast(`已套用「${t.name}」框架`)
  }

  private async pickImage(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const path = await PhotoPickService.pickOneImage(ctx)
    if (path.length === 0) {
      const err = PhotoPickService.lastError
      this.showToast(err.length > 0 ? err : '未选择图片')
      return
    }
    this.imagePath = path
    this.showToast('已插入配图')
  }

  private async save(): Promise<void> {
    if (!TitleGuard.isValid(this.title)) {
      this.showToast('标题仅可用中文、字母、数字和空格')
      return
    }
    let e: InsightEntry
    if (this.existingId.length > 0) {
      e = await this.loadOrNew()
    } else {
      e = InsightEntry.createNew(DateHelper.todayKey())
    }
    e.title = this.title.trim()
    e.body = this.body
    e.tags = this.tags
    e.notebookId = this.notebookId
    e.imagePath = this.imagePath
    e.frameKind = this.frameKind
    e.starred = this.starred
    e.pinned = this.pinned
    e.reviewNote = this.reviewNote
    e.verdict = this.verdict
    const ok = await InsightStore.saveEntry(e)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.onSaved()
  }

  private async loadOrNew(): Promise<InsightEntry> {
    const found = await InsightStore.findById(this.existingId)
    if (found !== undefined) {
      return found
    }
    return InsightEntry.createNew(DateHelper.todayKey())
  }

  private displayImage(): string {
    return ImagePathUtil.toDisplayUri(this.imagePath)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding(12)
            .onClick((): void => { this.onClose() })
          Text(this.existingId.length > 0 ? '编辑见解' : '新建见解')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding(12)
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.title, placeholder: '见解标题' })
              .width('100%')
              .height(48)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .onChange((v: string) => { this.title = v })

            Text('思考框架')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.frames, (t: FrameTemplate) => {
                Text(t.name)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.frameKind === t.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.frameKind === t.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.applyFrame(t) })
              }, (t: FrameTemplate) => t.id)
            }
            .width('100%')

            TextArea({ text: this.body, placeholder: '写下此刻的思考，选中文字后点加粗/斜体…' })
              .width('100%')
              .height(200)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .onChange((v: string) => { this.body = v })
              .onTextSelectionChange((start: number, end: number) => {
                this.selStart = start
                this.selEnd = end
              })

            this.Toolbar()

            if (this.body.trim().length > 0) {
              Text('排版预览')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Column() {
                BodyRichText({ body: this.body })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
            }

            if (this.displayImage().length > 0) {
              Image(this.displayImage())
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Text('移除配图')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .onClick((): void => { this.imagePath = '' })
            }

            Row({ space: 8 }) {
              Text(this.starred ? '已星标' : '星标')
                .fontSize(Theme.type.caption)
                .fontColor(this.starred ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.starred ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.starred = !this.starred })
              Text(this.pinned ? '已置顶' : '置顶')
                .fontSize(Theme.type.caption)
                .fontColor(this.pinned ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.pinned ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.pinned = !this.pinned })
            }
            .width('100%')

            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.tags, placeholder: '如：阅读,决策' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .onChange((v: string) => { this.tags = v })

            Text('笔记本')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.books, (b: InsightNotebook) => {
                Text(b.name)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.notebookId === b.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.notebookId === b.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.notebookId = b.id })
              }, (b: InsightNotebook) => b.id)
            }
            .width('100%')

            AppButton({
              label: '保存见解',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Toolbar() {
    Row({ space: 6 }) {
      this.Tool('H1', (): void => { this.applyLinePrefix('# ') })
      this.Tool('H2', (): void => { this.applyLinePrefix('## ') })
      this.Tool('B', (): void => { this.applyWrap('**', '**') })
      this.Tool('I', (): void => { this.applyWrap('*', '*') })
      this.Tool('列表', (): void => { this.applyLinePrefix('- ') })
      Row() {
        AppIcon({ name: 'photo', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .onClick((): void => { void this.pickImage() })
    }
    .width('100%')
  }

  @Builder
  Tool(label: string, action: () => void) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .constraintSize({ minWidth: 36 })
      .height(36)
      .padding({ left: 8, right: 8 })
      .textAlign(TextAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .onClick((): void => { action() })
  }
}
