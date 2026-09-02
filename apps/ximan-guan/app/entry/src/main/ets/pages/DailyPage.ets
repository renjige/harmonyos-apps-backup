import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { EmotionPicker } from '../components/ximan/EmotionPicker'
import { NoteTimelineCard } from '../components/ximan/NoteTimelineCard'
import { NoteDetailOverlay } from '../components/ximan/NoteDetailOverlay'
import { ObservationNote } from '../models/ObservationModels'
import { DateHelper } from '../services/DateHelper'
import { ObservationStore } from '../services/ObservationStore'

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State inputText: string = ''
  @State selectedEmotion: string = 'calm'
  @State todayNotes: ObservationNote[] = []
  @State timelineNotes: ObservationNote[] = []
  @State todayCount: number = 0
  @State toastText: string = ''
  @State dateLabel: string = ''
  @State detailNote: ObservationNote = new ObservationNote()
  @State showDetail: boolean = false

  aboutToAppear(): void {
    this.dateLabel = DateHelper.displayDate(DateHelper.todayKey())
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    const today = DateHelper.todayKey()
    this.todayNotes = await ObservationStore.notesForDate(today)
    this.todayCount = this.todayNotes.length
    const keys = DateHelper.lastNDays(7)
    const keySet = new Set<string>()
    for (const k of keys) {
      if (k !== today) {
        keySet.add(k)
      }
    }
    const all = await ObservationStore.loadAll()
    const out: ObservationNote[] = []
    for (const n of all) {
      if (keySet.has(n.dateKey)) {
        out.push(n)
      }
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    this.timelineNotes = out
  }

  private async handleSave(): Promise<void> {
    const ok = await ObservationStore.addNote(this.inputText, this.selectedEmotion)
    if (!ok) {
      if (this.inputText.trim().length === 0) {
        this.showToast('请输入观察内容')
      } else if (this.inputText.trim().length > 50) {
        this.showToast('笔记限 50 字以内')
      } else {
        this.showToast('今日已记录 3 条，明天再来')
      }
      return
    }
    this.inputText = ''
    this.showToast('已记录')
    await this.reload()
  }

  private openDetail(note: ObservationNote): void {
    this.detailNote = note
    this.showDetail = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeDetail(): void {
    this.showDetail = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async handleDeleteDetail(): Promise<void> {
    if (this.detailNote.id.length === 0) {
      return
    }
    await ObservationStore.deleteNote(this.detailNote.id)
    this.closeDetail()
    this.showToast('已删除')
    await this.reload()
  }

  private async handleSaveDetail(text: string, emotionKey: string): Promise<void> {
    const ok = await ObservationStore.updateNote(this.detailNote.id, text, emotionKey)
    if (!ok) {
      this.showToast('保存失败，请检查字数')
      return
    }
    this.closeDetail()
    this.showToast('已保存修改')
    await this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s2 }) {
            Text('溪漫观')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.dateLabel)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(91,140,140,0.05)', 0], ['rgba(61,95,95,0.55)', 1]]
              })
              .borderRadius(Theme.radius.lg)
            Text('让每一天的碎片生活，被智慧地看见')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
          }
          .width('100%')

          Column({ space: Theme.space.s4 }) {
            Text(`今日漫观 · 还可记录 ${ObservationStore.DAILY_LIMIT - this.todayCount} 条`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            EmotionPicker({
              selectedKey: this.selectedEmotion,
              onSelect: (key: string): void => { this.selectedEmotion = key }
            })

            TextArea({ text: this.inputText, placeholder: '今天，你观察到了什么？' })
              .height(88)
              .maxLength(50)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.inputText = v })

            Text(`${this.inputText.length}/50`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
              .textAlign(TextAlign.End)

            AppButton({
              label: '记录',
              variant: 'primary',
              disabled: this.todayCount >= ObservationStore.DAILY_LIMIT,
              onTap: (): void => { void this.handleSave() }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(20)
          .shadow({ radius: 12, color: 'rgba(44,44,44,0.06)', offsetY: 4 })

          if (this.todayNotes.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('今日已记录')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.todayNotes, (n: ObservationNote) => {
                NoteTimelineCard({
                  note: n,
                  onTap: (): void => this.openDetail(n)
                })
              }, (n: ObservationNote) => n.id)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            Text('近 7 日（不含今天）')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            if (this.timelineNotes.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image($r('app.media.empty_calm'))
                  .width('100%')
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
                AppEmpty({
                  title: '还没有漫观笔记',
                  description: '写下第一条观察，时间线会在这里展开',
                  actionLabel: '',
                  onAction: (): void => {}
                })
              }
              .width('100%')
            } else {
              ForEach(this.timelineNotes, (n: ObservationNote) => {
                NoteTimelineCard({
                  note: n,
                  onTap: (): void => this.openDetail(n)
                })
              }, (n: ObservationNote) => n.id)
            }
          }
          .width('100%')

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }

      if (this.showDetail && this.detailNote.id.length > 0) {
        NoteDetailOverlay({
          note: this.detailNote,
          onClose: (): void => this.closeDetail(),
          onDelete: (): void => { void this.handleDeleteDetail() },
          onSave: (text: string, emotionKey: string): void => {
            void this.handleSaveDetail(text, emotionKey)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
