import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TagPreset, MomentNote, ScenePreset } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'

@Component
export struct NoteEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  onSaved: () => void = () => {}
  onCancel: () => void = () => {}

  @State content: string = ''
  @State selected: string[] = []
  @State toast: string = ''
  @State listening: boolean = false
  private draftId: string = ''
  private dateKey: string = ''
  private createdAt: number = 0
  private pinned: boolean = false

  aboutToAppear(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.noteId.length > 0) {
      const found = await MomentStore.findNote(this.noteId)
      if (found !== undefined) {
        this.draftId = found.id
        this.content = found.content
        this.selected = found.tags
        this.dateKey = found.dateKey
        this.createdAt = found.createdAt
        this.pinned = found.pinned
        return
      }
    }
    const n = MomentNote.createNew(DateHelper.todayKey())
    this.draftId = n.id
    this.dateKey = n.dateKey
    this.createdAt = n.createdAt
    const seed = AppStorage.get<string>('noteDraftSeed')
    if (seed !== undefined && seed.length > 0) {
      this.content = seed
      AppStorage.setOrCreate('noteDraftSeed', '')
    }
    const tag = AppStorage.get<string>('noteDraftTag')
    if (tag !== undefined && tag.length > 0) {
      this.selected = [tag]
      AppStorage.setOrCreate('noteDraftTag', '')
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private toggleTag(label: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.selected) {
      if (t === label) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      if (next.length >= 3) {
        this.showToast('最多选择 3 个标签')
        return
      }
      next.push(label)
    }
    this.selected = next
  }

  private isOn(label: string): boolean {
    return this.selected.indexOf(label) >= 0
  }

  private async save(): Promise<void> {
    const note = new MomentNote()
    note.id = this.draftId
    note.content = this.content
    note.tags = this.selected
    note.dateKey = this.dateKey.length > 0 ? this.dateKey : DateHelper.todayKey()
    note.createdAt = this.createdAt > 0 ? this.createdAt : Date.now()
    note.pinned = this.pinned
    const ok = await MomentStore.saveNote(note)
    if (ok) {
      this.onSaved()
      return
    }
    this.showToast('请先写下一件小事')
  }

  private onKeyboardVoiceHint(): void {
    this.listening = true
    this.showToast('请点键盘上的语音键输入，文字会写入正文')
    setTimeout((): void => { this.listening = false }, 2200)
  }

  private useScene(s: ScenePreset): void {
    if (this.content.trim().length === 0) {
      this.content = s.seed
    }
    if (!this.isOn(s.tag)) {
      this.toggleTag(s.tag)
    }
  }

  @Builder
  TagChip(t: TagPreset) {
    Text(`#${t.label}`)
      .fontSize(13)
      .fontColor(this.isOn(t.label) ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.isOn(t.label) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => this.toggleTag(t.label))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick((): void => this.onCancel())
          Text(this.noteId.length > 0 ? '编辑小事' : '记下小事')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 4, top: 8, bottom: 8 })
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s5 })

        Scroll() {
          Column() {
            TextArea({ text: this.content, placeholder: '此刻想记下的一件小事、灵感或小确幸…' })
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .height(180)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
              .onChange((v: string): void => { this.content = v })

            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({
                  name: 'mic',
                  iconSize: Theme.icon.lg,
                  color: this.listening ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary
                })
              }
              .width(48)
              .height(48)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.listening ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onKeyboardVoiceHint() })
              Text(this.listening ? '请使用键盘语音键' : '键盘语音输入（无需应用权限）')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
            .alignItems(VerticalAlign.Center)

            Text('场景模板')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })
            Row({ space: 8 }) {
              ForEach(ScenePreset.all(), (s: ScenePreset) => {
                Text(s.label)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => this.useScene(s))
              }, (s: ScenePreset) => s.key)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text('选择生活分类（1–3）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s2 })

            Column({ space: 8 }) {
              Row({ space: 8 }) {
                ForEach(TagPreset.firstRow(), (t: TagPreset) => {
                  this.TagChip(t)
                }, (t: TagPreset) => t.key)
              }
              .width('100%')
              Row({ space: 8 }) {
                ForEach(TagPreset.secondRow(), (t: TagPreset) => {
                  this.TagChip(t)
                }, (t: TagPreset) => t.key)
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column() {
              AppButton({
                label: '保存这件事',
                onTap: (): void => { void this.save() }
              })
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s5,
              bottom: Theme.space.s10
            })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
