import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { ReadingDoc } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'
import { PdfReaderView } from './PdfReaderView'

@Component
export struct ReaderPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDocIdChange') docId: string = ''
  @State doc: ReadingDoc = new ReadingDoc()
  @State fontVp: number = 16
  @State showBar: boolean = true
  @State toastText: string = ''
  @State openedAt: number = 0
  onClose: () => void = () => {}
  onExcerpt: (docId: string) => void = (_id: string) => {}
  onNeedBody: (docId: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.openedAt = Date.now()
    void this.load()
  }

  aboutToDisappear(): void {
    void this.persistMinutes()
  }

  onDocIdChange(): void {
    this.openedAt = Date.now()
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await FolioStore.findDoc(this.docId)
    if (found !== undefined) {
      this.doc = found
      if (found.needsBody()) {
        this.onNeedBody(found.id)
      }
    }
  }

  private async persistMinutes(): Promise<void> {
    const found = await FolioStore.findDoc(this.docId)
    if (found === undefined) {
      return
    }
    const mins = Math.max(1, Math.floor((Date.now() - this.openedAt) / 60000))
    found.readMinutes = found.readMinutes + mins
    found.lastReadAt = Date.now()
    await FolioStore.saveDoc(found)
  }

  private async setProgress(p: number): Promise<void> {
    const found = await FolioStore.findDoc(this.docId)
    if (found === undefined) {
      return
    }
    found.progress = p
    found.lastReadAt = Date.now()
    await FolioStore.saveDoc(found)
    this.doc = found
    this.showToast(`进度已记为 ${found.progressLabel()}`)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private paperBg(): string {
    return Theme.isDark() ? '#121A24' : '#F7F5F0'
  }

  build() {
    Stack() {
      Column() {
        if (this.showBar) {
          Row() {
            Row() {
              AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onClose() })
            Text(this.doc.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.doc.progressLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .padding({ right: 12 })
          }
          .width('100%')
          .padding({ left: 8, right: 4, top: 6, bottom: 6 })
        }

        if (this.doc.hasPdfFile()) {
          Column({ space: 8 }) {
            Text(this.doc.body.length > 0 ? this.doc.body : '下方为 PDF 原页，可缩放翻页。需要记住的句子请点「写入摘录」。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(6)
              .width('100%')
              .padding({ left: 16, right: 16 })
            PdfReaderView({ filePath: this.doc.filePath })
              .width('100%')
              .layoutWeight(1)
          }
          .layoutWeight(1)
          .width('100%')
        } else {
          Scroll() {
            Text(this.doc.body.length > 0 ? this.doc.body : '这篇文稿还没有可阅读正文。请点底部「补充正文」，或从文件中复制文字粘贴进来。')
              .fontSize(this.fontVp)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(this.fontVp * 1.7)
              .width('100%')
              .copyOption(CopyOptions.InApp)
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 24 })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onClick((): void => { this.showBar = !this.showBar })
        }

        if (this.showBar) {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              this.ProgChip('25%', 0.25)
              this.ProgChip('50%', 0.5)
              this.ProgChip('75%', 0.75)
              this.ProgChip('读完', 1)
            }
            .width('100%')
            Row({ space: 8 }) {
              this.FontChip('小', 14)
              this.FontChip('中', 16)
              this.FontChip('大', 18)
              Column() {
                AppButton({
                  label: '写入摘录',
                  onTap: (): void => { this.onExcerpt(this.doc.id) }
                })
              }
              .layoutWeight(1)
              .constraintSize({ minWidth: 96 })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 28 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.paperBg())

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ProgChip(label: string, value: number) {
    Text(label)
      .fontSize(12)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .constraintSize({ minHeight: 40 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.setProgress(value) })
  }

  @Builder
  FontChip(label: string, size: number) {
    Text(label)
      .fontSize(12)
      .fontColor(this.fontVp === size ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .constraintSize({ minHeight: 40 })
      .backgroundColor(this.fontVp === size ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.fontVp = size })
  }
}
