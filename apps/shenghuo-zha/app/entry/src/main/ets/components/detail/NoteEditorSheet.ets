import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { LifeTagChips } from '../life/LifeTagChips'
import { LifeSandboxImage } from '../life/LifeSandboxImage'
import { LifeNoteItem, LifeNoteTemplate } from '../../models/LifeModels'
import { LifeDateHelper, LifeLocalStore } from '../../services/LifeLocalStore'
import { LifeDetailNav } from '../../services/LifeDetailNav'
import { SmartSuggestService } from '../../services/SmartSuggestService'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AppContextService } from '../../services/AppContextService'

@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @State formTitle: string = ''
  @State formBody: string = ''
  @State imagePaths: string[] = []
  @State customTag: string = ''
  @State activeTags: string[] = []
  @State suggestedTags: string[] = []
  @State category: string = '日常'
  @State mood: string = ''
  @State templateKey: string = ''
  @State toast: string = ''
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onNoteIdChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.noteId.length === 0) {
      this.formTitle = ''
      this.formBody = ''
      this.imagePaths = []
      this.activeTags = []
      this.mood = ''
      const tplKey = AppStorage.get<string>('lifeEditorTemplate') ?? ''
      const cat = AppStorage.get<string>('lifeEditorCategory') ?? ''
      this.templateKey = tplKey
      this.category = cat.length > 0 ? cat : '日常'
      if (tplKey.length > 0) {
        const tpl = LifeNoteTemplate.find(tplKey)
        if (tpl !== undefined) {
          this.formTitle = tpl.title
          this.category = tpl.category
          const tags: string[] = []
          tags.push(tpl.tag)
          this.activeTags = tags
        }
      }
      this.refreshSuggestions()
      return
    }
    const note = await LifeLocalStore.findNote(this.noteId)
    if (note !== undefined) {
      this.formTitle = note.title
      this.formBody = note.body
      this.imagePaths = note.imagePaths.slice()
      this.activeTags = note.tags.slice()
      this.category = note.category.length > 0 ? note.category : '日常'
      this.mood = note.mood
      this.templateKey = note.templateKey
      this.refreshSuggestions()
    }
  }

  private refreshSuggestions(): void {
    this.suggestedTags = SmartSuggestService.suggestTags(`${this.formTitle}\n${this.formBody}`, this.activeTags)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private addCustomTag(): void {
    const trimmed = this.customTag.trim()
    if (trimmed.length === 0) {
      return
    }
    let dup = false
    for (const t of this.activeTags) {
      if (t === trimmed) {
        dup = true
        break
      }
    }
    if (!dup) {
      const next: string[] = []
      for (const t of this.activeTags) {
        next.push(t)
      }
      next.push(trimmed)
      this.activeTags = next
    }
    this.customTag = ''
    this.refreshSuggestions()
  }

  private toggleSuggested(tag: string): void {
    let found = false
    const next: string[] = []
    for (const t of this.activeTags) {
      if (t === tag) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(tag)
    }
    this.activeTags = next
  }

  private async pickImages(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法访问相册')
      return
    }
    const remain = 9 - this.imagePaths.length
    if (remain <= 0) {
      this.showToast('最多添加 9 张照片')
      return
    }
    const picked = await PhotoPickService.pickImages(ctx, remain)
    if (picked.length === 0) {
      return
    }
    const merged: string[] = []
    for (const p of this.imagePaths) {
      merged.push(p)
    }
    for (const p of picked) {
      merged.push(p)
    }
    this.imagePaths = merged.slice(0, 9)
  }

  private removeImage(path: string): void {
    const next: string[] = []
    for (const p of this.imagePaths) {
      if (p !== path) {
        next.push(p)
      }
    }
    this.imagePaths = next
  }

  private async save(): Promise<void> {
    if (!LifeLocalStore.storeReady()) {
      this.showToast('存储未就绪，请关闭应用后重开')
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    if (this.formBody.trim().length === 0 && this.imagePaths.length === 0) {
      this.showToast('请填写正文或添加照片')
      return
    }
    const savedTags = this.activeTags.slice()
    if (this.noteId.length > 0) {
      const existing = await LifeLocalStore.findNote(this.noteId)
      if (existing !== undefined) {
        existing.title = this.formTitle.trim()
        existing.body = this.formBody.trim()
        existing.tags = savedTags
        existing.imagePaths = this.imagePaths.slice()
        existing.category = this.category
        existing.mood = this.mood
        existing.templateKey = this.templateKey
        existing.updatedAt = Date.now()
        const ok = await LifeLocalStore.saveNote(existing)
        if (!ok) {
          this.showToast('保存失败，请关闭应用后重开再试')
          return
        }
        this.onSaved()
        LifeDetailNav.closeNoteEditor()
        LifeDetailNav.openNote(this.noteId)
      }
    } else {
      const note = LifeNoteItem.create(LifeDateHelper.newId(), this.formTitle.trim(), this.formBody.trim())
      note.tags = savedTags
      note.imagePaths = this.imagePaths.slice()
      note.category = this.category
      note.mood = this.mood
      note.templateKey = this.templateKey
      note.updatedAt = Date.now()
      const ok = await LifeLocalStore.saveNote(note)
      if (!ok) {
        this.showToast('保存失败，请关闭应用后重开再试')
        return
      }
      AppStorage.setOrCreate('lifeEditorTemplate', '')
      AppStorage.setOrCreate('lifeEditorCategory', '')
      this.onSaved()
      LifeDetailNav.closeNoteEditor()
      LifeDetailNav.openNote(note.id)
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.noteId.length > 0 ? '编辑札记' : '新建札记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { LifeDetailNav.closeNoteEditor() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.formTitle, placeholder: '标题（必填）' })
              .fontSize(Theme.type.title3)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandDeep)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .onChange((v: string) => {
                this.formTitle = v
                this.refreshSuggestions()
              })
            TextArea({ text: this.formBody, placeholder: '记录今天的生活片段，可配照片…' })
              .height(200)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandDeep)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .onChange((v: string) => {
                this.formBody = v
                this.refreshSuggestions()
              })

            Text('生活分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(LifeNoteTemplate.categories(), (c: string) => {
                Text(c)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                  .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.category = c })
              }, (c: string) => c)
            }
            .width('100%')

            Text('心情')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(LifeNoteTemplate.moods(), (m: string) => {
                Text(m)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.mood === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                  .backgroundColor(this.mood === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.mood = this.mood === m ? '' : m })
              }, (m: string) => m)
            }
            .width('100%')

            Row({ space: Theme.space.s2 }) {
              Text('照片')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text(`${this.imagePaths.length}/9`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.imagePaths, (path: string) => {
                Stack({ alignContent: Alignment.TopEnd }) {
                  LifeSandboxImage({ srcPath: path, imgWidth: 96, imgHeight: 96, radius: Theme.radius.sm })
                  AppIcon({ name: 'close', iconSize: 14, color: '#FFFFFF' })
                    .backgroundColor('rgba(0,0,0,0.5)')
                    .borderRadius(Theme.radius.pill)
                    .padding(4)
                    .onClick((): void => { this.removeImage(path) })
                }
                .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
              }, (path: string) => path)

              if (this.imagePaths.length < 9) {
                Column() {
                  AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
                  Text('添加')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                }
                .width(96)
                .height(96)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { void this.pickImages() })
              }
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('智慧识别标签')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              if (this.suggestedTags.length > 0) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.suggestedTags, (tag: string) => {
                    Text(tag)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.toggleSuggested(tag) })
                  }, (tag: string) => tag)
                }
              }
              if (this.activeTags.length > 0) {
                LifeTagChips({ tags: this.activeTags })
              }
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.customTag, placeholder: '输入标签名称' })
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .placeholderColor(Theme.colors().textSecondary)
                  .caretColor(Theme.colors().brandDeep)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(Theme.radius.sm)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  .padding({ left: 12, right: 12 })
                  .onChange((v: string) => { this.customTag = v })
                Text('添加')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .constraintSize({ minHeight: 44 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.addCustomTag() })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            AppButton({
              label: '保存',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .padding(Theme.space.pageX)
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
