import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WriteNoteForm } from './WriteNoteForm'
import { ConfirmLeaveSheet } from './ConfirmLeaveSheet'
import { HeartNoteStore } from '../../services/HeartNoteStore'
import { HeartNoteBizService } from '../../services/HeartNoteBizService'
import { NoteComposer } from '../../services/NoteComposer'
import { NoteNav } from '../../services/NoteNav'
import { PhotoPickService } from '../../services/PhotoPickService'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct WriteNotePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  onSaved: () => void = () => {}
  @State titleText: string = ''
  @State bodyText: string = ''
  @State mood: string = 'calm'
  @State tags: string[] = []
  @State customTag: string = ''
  @State photo0: string = ''
  @State photo1: string = ''
  @State photo2: string = ''
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State tagChoices: string[] = MoodCatalog.defaultTags()
  private editingId: string = ''

  aboutToAppear(): void {
    this.hydrate()
    void this.loadTags()
  }

  onEditIdChange(): void {
    this.hydrate()
  }

  private async loadTags(): Promise<void> {
    const remote = await HeartNoteBizService.loadTags()
    if (remote.length > 0) {
      this.tagChoices = remote
    }
  }

  private hydrate(): void {
    this.confirmDelete = false
    const found = this.editId.length > 0 ? NoteComposer.fromExisting(this.editId) : undefined
    if (found !== undefined) {
      this.editingId = found.id
      this.titleText = found.title
      this.bodyText = found.body
      this.mood = found.mood
      this.tags = found.tagList()
      this.photo0 = found.photoUri0
      this.photo1 = found.photoUri1
      this.photo2 = found.photoUri2
      return
    }
    this.editingId = ''
    this.titleText = ''
    this.bodyText = ''
    this.mood = AppStorage.get<string>('todayMood') ?? 'calm'
    if (this.mood.length === 0) {
      this.mood = 'calm'
    }
    this.tags = []
    this.photo0 = ''
    this.photo1 = ''
    this.photo2 = ''
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private toggleTag(tag: string): void {
    this.tags = NoteComposer.toggleTag(this.tags, tag)
  }

  private addCustomTag(): void {
    const t = this.customTag.trim()
    if (t.length === 0) {
      return
    }
    this.tags = NoteComposer.toggleTag(this.tags, t)
    this.tagChoices = NoteComposer.addChoice(this.tagChoices, t)
    this.customTag = ''
  }

  private async pickPhoto(): Promise<void> {
    if (this.photo0.length > 0 && this.photo1.length > 0 && this.photo2.length > 0) {
      this.showToast('最多放进三张照片')
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const uri = await PhotoPickService.pickOne(ctx)
    if (uri.length === 0) {
      return
    }
    if (this.photo0.length === 0) {
      this.photo0 = uri
      return
    }
    if (this.photo1.length === 0) {
      this.photo1 = uri
      return
    }
    this.photo2 = uri
  }

  private async handleSave(): Promise<void> {
    if (this.titleText.trim().length === 0 && this.bodyText.trim().length === 0) {
      this.showToast('写一句给今天的话吧')
      return
    }
    const item = NoteComposer.toItem(
      this.editingId, this.titleText, this.bodyText, this.mood,
      this.tags.join(','), this.photo0, this.photo1, this.photo2
    )
    await NoteComposer.saveDraft(item)
    this.showToast('已收进心笺')
    setTimeout(() => {
      NoteNav.closeWrite()
      this.onSaved()
    }, 400)
  }

  private async handleDelete(): Promise<void> {
    if (this.editingId.length === 0) {
      NoteNav.closeWrite()
      return
    }
    await HeartNoteStore.remove(this.editingId)
    this.confirmDelete = false
    NoteNav.closeWrite()
    this.onSaved()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { NoteNav.closeWrite() })
          Text('写一封给今天的心笺')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: Theme.space.pageX, top: 8 })
        Scroll() {
          WriteNoteForm({
            titleText: $titleText,
            bodyText: $bodyText,
            mood: $mood,
            customTag: $customTag,
            photo0: $photo0,
            photo1: $photo1,
            photo2: $photo2,
            tagChoices: this.tagChoices,
            selectedCsv: this.tags.join(','),
            onToggleTag: (tag: string): void => { this.toggleTag(tag) },
            onAddTag: (): void => { this.addCustomTag() },
            onPickPhoto: (): void => { void this.pickPhoto() }
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        Column({ space: 8 }) {
          AppButton({ label: '保存心笺', onTap: (): void => { void this.handleSave() } })
          if (this.editingId.length > 0) {
            AppButton({
              label: '删除',
              variant: 'ghost',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16, top: 8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      if (this.confirmDelete) {
        ConfirmLeaveSheet({
          title: '确定要让这篇心笺离开吗？',
          subtitle: '离开之后，它不会再出现在你的手账里。',
          onKeep: (): void => { this.confirmDelete = false },
          onLeave: (): void => { void this.handleDelete() }
        })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
