import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { BookCategoryUtil, CreateNoteRequest, NoteItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onNoteCreated: () => void = () => {}
  onClose: () => void = () => {}
  @Prop overlayMode: boolean = false
  @State notes: NoteItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = 'note_scene_desk'
  @State formKind: string = 'note'
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    this.formDate = NotesPage.todayIso()
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.notes = await ReadingBizService.loadNotes(this.currentUsername, '', '')
    } else {
      this.notes = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formBody = ''
    this.formTags = ''
    this.formDate = NotesPage.todayIso()
    this.formCoverKey = 'note_scene_desk'
    this.formKind = 'note'
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
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

  private async submitNote(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateNoteRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate.length > 0 ? this.formDate : NotesPage.todayIso()
    req.coverKey = this.formCoverKey
    req.kind = this.formKind
    req.userId = this.currentUsername
    const created = await ReadingBizService.createNote(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onNoteCreated()
    } else {
      this.formError = '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.overlayMode) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onClose() })
            Text('阅读札记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
        } else {
          AppHeader({ title: '阅读札记', subtitle: '补充性札记；核心差异化见「书房玩法」' })
        }
        if (this.loading) {
          AppLoading({ label: '加载笔记…' }).layoutWeight(1)
        } else if (this.notes.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有笔记',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，写下第一篇读书笔记'
                : '登录后可创建并同步你的笔记',
              actionLabel: '写笔记',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.notes, (item: NoteItem) => {
                ReadingListCard({
                  title: item.title,
                  summary: item.summary.length > 0 ? item.summary : item.body,
                  coverKey: item.coverKey.length > 0 ? item.coverKey : 'note_scene_desk',
                  meta: item.recordDate,
                  tags: item.tags,
                  onTap: (): void => { ReadingDetailNav.openNote(item.id) }
                })
              }, (item: NoteItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(45,90,74,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.NoteFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NoteFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('写笔记')
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
          Column({ space: 6 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '给笔记起个名字…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '记录日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.formDate = v }
          })

          Column({ space: 6 }) {
            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下阅读思考与感悟…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(140)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('笔记类型')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: 8 }) {
              Text('阅读心得')
                .fontSize(Theme.type.caption)
                .fontColor(this.formKind === 'note' ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.formKind === 'note' ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.formKind = 'note' })
              Text('文字感悟')
                .fontSize(Theme.type.caption)
                .fontColor(this.formKind === 'insight' ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.formKind === 'insight' ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.formKind = 'insight' })
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('插入阅读现场图')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(BookCategoryUtil.noteScenes(), (key: string) => {
                Text(BookCategoryUtil.sceneLabel(key))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formCoverKey === key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.formCoverKey === key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.formCoverKey = key })
              }, (key: string) => key)
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(BookCategoryUtil.insightTags(), (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formTags.indexOf(tag) >= 0 ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .backgroundColor(this.formTags.indexOf(tag) >= 0 ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    if (this.formTags.indexOf(tag) >= 0) {
                      this.formTags = this.formTags.replace(tag, '').replace(',,', ',')
                    } else if (this.formTags.length === 0) {
                      this.formTags = tag
                    } else {
                      this.formTags = `${this.formTags},${tag}`
                    }
                  })
              }, (tag: string) => tag)
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('更多标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '文学, 哲学, 摘抄' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '保存中…' : '保存笔记',
            disabled: this.submitting,
            onTap: (): void => { void this.submitNote() }
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
