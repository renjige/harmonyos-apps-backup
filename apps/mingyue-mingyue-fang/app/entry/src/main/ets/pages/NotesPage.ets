import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { TagChips } from '../components/reading/TagChips'
import { CreateNoteRequest, NoteItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onNoteCreated: () => void = () => {}
  @State notes: NoteItem[] = []
  @State filteredNotes: NoteItem[] = []
  @State tagOptions: string[] = ['全部']
  @State activeTag: string = '全部'
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State refreshing: boolean = false
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

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private rebuildTagOptions(items: NoteItem[]): void {
    const names: string[] = ['全部']
    const seen: string[] = []
    for (const item of items) {
      for (const tag of item.tags) {
        if (tag.length > 0 && !seen.includes(tag)) {
          seen.push(tag)
          names.push(tag)
        }
      }
    }
    if (names.length === 1) {
      names.push('文学', '哲学', '摘抄', '明悟')
    }
    this.tagOptions = names
    if (!names.includes(this.activeTag)) {
      this.activeTag = '全部'
    }
  }

  private applyFilter(): void {
    if (this.activeTag === '全部') {
      this.filteredNotes = this.notes
      return
    }
    const out: NoteItem[] = []
    for (const item of this.notes) {
      if (item.tags.includes(this.activeTag)) {
        out.push(item)
      }
    }
    this.filteredNotes = out
  }

  private async reload(): Promise<void> {
    this.refreshing = true
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.notes = await ReadingBizService.loadNotes(this.currentUsername, '', '')
    } else {
      this.notes = []
    }
    this.rebuildTagOptions(this.notes)
    this.applyFilter()
    this.loading = false
    this.refreshing = false
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
        Row({ space: Theme.space.s3 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(40)
              .height(40)
              .linearGradient({
                angle: 135,
                colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
              })
              .borderRadius(10)
            AppIcon({ name: 'edit', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
          }
          Column({ space: 2 }) {
            Text('明阅笔记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('记录阅读思考与感悟')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s2
        })

        if (!this.loading && this.notes.length > 0) {
          TagChips({
            selected: this.activeTag,
            options: this.tagOptions,
            onSelect: (name: string): void => {
              this.activeTag = name
              this.applyFilter()
            }
          })
        }

        Refresh({ refreshing: this.refreshing, offset: 64, friction: 100 }) {
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
                emojiMark: '📝',
                iconName: 'edit',
                onAction: (): void => { this.openCreateForm() }
              })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else if (this.filteredNotes.length === 0) {
            Column() {
              AppEmpty({
                title: '该标签暂无笔记',
                description: '切换其他标签，或创建新笔记',
                emojiMark: '🏷️',
                iconName: 'list'
              })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.filteredNotes, (item: NoteItem) => {
                  ReadingListCard({
                    title: item.title,
                    summary: item.summary.length > 0 ? item.summary : item.body,
                    coverKey: 'cover_note',
                    category: item.tags.length > 0 ? item.tags[0] : '',
                    meta: item.recordDate,
                    tags: item.tags,
                    useSymbolCover: true,
                    showCover: false,
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
        .layoutWeight(1)
        .onRefreshing((): void => { void this.reload() })
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
        .shadow({ radius: 12, color: 'rgba(26,42,58,0.18)', offsetY: 4 })
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
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '文学, 哲学, 摘抄' })
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
