import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { BookNote } from '../models/BookNoteModels'
import { NoteStore } from '../services/NoteStore'
import { WisdomTagService } from '../services/WisdomTagService'
import { PhotoPickService } from '../services/PhotoPickService'
import { MediaUriUtil } from '../utils/MediaUriUtil'
import { CoverPickRow } from '../components/note/CoverPickRow'
import { NoteAreaCard, NoteFieldCard } from '../components/note/NoteFieldCard'
import { WisdomTagSheet } from '../components/note/WisdomTagSheet'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct CapturePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordIdChange') recordId: string = ''
  @Prop @Watch('onDefaultBookChange') defaultBookName: string = ''
  @Prop reloadToken: number = 0
  @Prop asOverlay: boolean = false
  @State bookName: string = ''
  @State pageText: string = ''
  @State excerpt: string = ''
  @State reflection: string = ''
  @State coverImage: string = ''
  @State selected: string[] = []
  @State suggested: string[] = []
  @State showTags: boolean = false
  @State toastText: string = ''
  @State saving: boolean = false
  private uiContext: common.UIAbilityContext | null = null
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onRecordIdChange(): void {
    void this.bootstrap()
  }

  onDefaultBookChange(): void {
    if (this.recordId.length === 0 && this.defaultBookName.length > 0) {
      this.bookName = this.defaultBookName
    }
  }

  private async bootstrap(): Promise<void> {
    if (this.recordId.length === 0) {
      if (!this.asOverlay) {
        this.resetForm()
        if (this.defaultBookName.length > 0) {
          this.bookName = this.defaultBookName
        }
      }
      return
    }
    const found = await NoteStore.findById(this.recordId)
    if (found === undefined) {
      return
    }
    this.bookName = found.bookName
    this.pageText = found.pageNumber > 0 ? `${found.pageNumber}` : ''
    this.excerpt = found.excerpt
    this.reflection = found.reflection
    this.coverImage = found.coverImage
    this.selected = found.tags
    this.suggested = WisdomTagService.suggest(found.bookName, found.excerpt)
  }

  private resetForm(): void {
    this.bookName = ''
    this.pageText = ''
    this.excerpt = ''
    this.reflection = ''
    this.coverImage = ''
    this.selected = []
    this.suggested = []
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private runSuggest(): void {
    this.suggested = WisdomTagService.suggest(this.bookName, this.excerpt)
    if (this.selected.length === 0) {
      this.selected = this.suggested
    }
    this.showTags = true
  }

  private toggleTag(name: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.selected) {
      if (t === name) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(name)
    }
    this.selected = next
  }

  private isSelected(name: string): boolean {
    for (const t of this.selected) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  private pageNumber(): number {
    if (this.pageText.trim().length === 0) {
      return 0
    }
    const n = Number.parseInt(this.pageText, 10)
    if (n !== n || n < 0) {
      return 0
    }
    return n
  }

  private async pickCover(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('相册选择器未就绪')
      return
    }
    const path = await PhotoPickService.pickAlbum(this.uiContext)
    if (path.length > 0) {
      this.coverImage = MediaUriUtil.imageSrc(path)
    }
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.bookName.trim().length === 0) {
      this.showToast('请填写书籍名称')
      return
    }
    if (this.excerpt.trim().length === 0) {
      this.showToast('请填写原文摘录')
      return
    }
    if (this.excerpt.trim().length > 300) {
      this.showToast('摘录建议在 300 字以内')
      return
    }
    this.saving = true
    let rec: BookNote
    if (this.recordId.length > 0) {
      const found = await NoteStore.findById(this.recordId)
      rec = found ?? BookNote.createNew()
    } else {
      rec = BookNote.createNew()
    }
    rec.bookName = this.bookName.trim()
    rec.pageNumber = this.pageNumber()
    rec.excerpt = this.excerpt.trim()
    rec.reflection = this.reflection.trim()
    rec.coverImage = MediaUriUtil.imageSrc(this.coverImage)
    rec.tags = this.selected
    await NoteStore.save(rec)
    this.saving = false
    this.showToast('书摘已保存')
    if (!this.asOverlay) {
      this.resetForm()
    }
    this.onSaved()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          if (this.asOverlay) {
            Row() {
              AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onClose() })
          }
          Text(this.recordId.length > 0 ? '编辑书摘' : '添加书摘')
            .fontSize(Theme.type.titleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            NoteFieldCard({
              label: '书籍名称 *',
              value: this.bookName,
              placeholder: '书名',
              onChange: (v: string): void => { this.bookName = v }
            })
            NoteFieldCard({
              label: '页码（可选）',
              value: this.pageText,
              placeholder: '例如 128',
              numberOnly: true,
              onChange: (v: string): void => { this.pageText = v }
            })
            NoteAreaCard({
              label: '原文摘录 *',
              value: this.excerpt,
              placeholder: '抄录书中金句',
              onChange: (v: string): void => { this.excerpt = v }
            })
            Text('摘录建议在 300 字以内，让精华更聚焦')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            NoteAreaCard({
              label: '我的感悟（可选）',
              value: this.reflection,
              placeholder: '写下这一段为何打动你',
              onChange: (v: string): void => { this.reflection = v }
            })

            CoverPickRow({
              coverImage: this.coverImage,
              onAlbum: (): void => { void this.pickCover() }
            })

            Text('智慧分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 12, bottom: 12 })
              .border({ width: 1.5, color: Theme.colors().brandAccent })
              .borderRadius(Theme.radius.xl)
              .onClick((): void => { this.runSuggest() })

            if (this.selected.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.selected, (t: string) => {
                  Text(CategoryEmojiUtil.chipLabel(t))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }, (t: string) => t)
              }
              .width('100%')
            }

            Text(this.saving ? '保存中…' : '提交书摘')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(24)
              .onClick((): void => { void this.save() })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showTags) {
        WisdomTagSheet({
          selected: this.selected,
          onToggle: (name: string): void => { this.toggleTag(name) },
          onDone: (): void => { this.showTags = false }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }
}
