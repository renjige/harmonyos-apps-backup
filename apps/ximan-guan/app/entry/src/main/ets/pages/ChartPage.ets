import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DayNotesOverlay } from '../components/ximan/DayNotesOverlay'
import { NoteDetailOverlay } from '../components/ximan/NoteDetailOverlay'
import { EmotionStat, KeywordItem, ObservationNote, TrendPoint } from '../models/ObservationModels'
import { DateHelper } from '../services/DateHelper'
import { InsightService } from '../services/InsightService'
import { ObservationStore } from '../services/ObservationStore'

@Component
export struct ChartPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State weekly: boolean = true
  @State emotions: EmotionStat[] = []
  @State visibleEmotions: EmotionStat[] = []
  @State trends: TrendPoint[] = []
  @State keywords: KeywordItem[] = []
  @State selectedDateKey: string = ''
  @State dayNotes: ObservationNote[] = []
  @State showDayOverlay: boolean = false
  @State detailNote: ObservationNote = new ObservationNote()
  @State showDetail: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private rangeKeys(): string[] {
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (this.weekly ? 6 : 29))
    const start = DateHelper.keyFromDate(startDate)
    return [start, end]
  }

  private async reload(): Promise<void> {
    const keys = this.rangeKeys()
    this.emotions = await InsightService.emotionStats(keys[0], keys[1])
    const visible: EmotionStat[] = []
    for (const e of this.emotions) {
      if (e.count > 0) {
        visible.push(e)
      }
    }
    this.visibleEmotions = visible
    this.trends = await InsightService.trendPoints(this.weekly ? 7 : 30)
    this.keywords = await InsightService.keywords(16, keys[0], keys[1])
  }

  private maxTrend(): number {
    let m = 1
    for (const p of this.trends) {
      if (p.score > m) {
        m = p.score
      }
    }
    return m
  }

  private async openDay(dateKey: string): Promise<void> {
    this.selectedDateKey = dateKey
    this.dayNotes = await ObservationStore.notesForDate(dateKey)
    this.showDayOverlay = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeDay(): void {
    this.showDayOverlay = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openNoteDetail(note: ObservationNote): void {
    this.detailNote = note
    this.showDetail = true
  }

  private closeDetail(): void {
    this.showDetail = false
    if (!this.showDayOverlay) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private async deleteDetailNote(): Promise<void> {
    if (this.detailNote.id.length === 0) {
      return
    }
    await ObservationStore.deleteNote(this.detailNote.id)
    this.showDetail = false
    this.dayNotes = await ObservationStore.notesForDate(this.selectedDateKey)
    void this.reload()
  }

  private async saveDetailNote(text: string, emotionKey: string): Promise<void> {
    const ok = await ObservationStore.updateNote(this.detailNote.id, text, emotionKey)
    if (!ok) {
      return
    }
    this.showDetail = false
    this.dayNotes = await ObservationStore.notesForDate(this.selectedDateKey)
    void this.reload()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Text('状态图谱')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Row() {
              Text('周')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .backgroundColor(this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.weekly = true; void this.reload() })
              Text('月')
                .fontSize(Theme.type.bodyS)
                .fontColor(!this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .backgroundColor(!this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.weekly = false; void this.reload() })
            }
          }
          .width('100%')

          Text('点击趋势柱可查看当日笔记')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('情绪分布')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            if (this.visibleEmotions.length === 0) {
              AppEmpty({
                title: '暂无数据',
                description: '记录漫观笔记后，情绪分布会在这里呈现',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.visibleEmotions, (e: EmotionStat) => {
                Row({ space: Theme.space.s2 }) {
                  Circle().width(12).height(12).fill(e.color)
                  Text(e.label)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width(48)
                  Stack({ alignContent: Alignment.Start }) {
                    Row().width('100%').height(10)
                      .backgroundColor(Theme.colors().surfaceSubtle).borderRadius(Theme.radius.pill)
                    Row().width(`${Math.round(e.ratio * 100)}%`).height(10)
                      .backgroundColor(e.color).borderRadius(Theme.radius.pill)
                  }
                  .layoutWeight(1)
                  Text(`${Math.round(e.ratio * 100)}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                    .width(36)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
              }, (e: EmotionStat) => e.key)
            }
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('情绪趋势')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Row({ space: Theme.space.s1 }) {
              ForEach(this.trends, (p: TrendPoint) => {
                Column({ space: 4 }) {
                  if (p.score > 0) {
                    Column()
                      .width('100%')
                      .height(100 * (p.score / this.maxTrend()))
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.xs)
                  } else {
                    Column()
                      .width('100%')
                      .height(4)
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.xs)
                  }
                  Text(p.label)
                    .fontSize(10)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.End)
                .height(120)
                .onClick((): void => { void this.openDay(p.dateKey) })
              }, (p: TrendPoint) => p.dateKey)
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('关键词云')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            if (this.keywords.length === 0) {
              Text('记录更多笔记后，高频词会浮现于此')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textTertiary)
            } else {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.keywords, (k: KeywordItem) => {
                  Text(k.word)
                    .fontSize(12 + Math.min(k.count, 5) * 2)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }, (k: KeywordItem) => k.word)
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showDayOverlay) {
        DayNotesOverlay({
          dateKey: this.selectedDateKey,
          notes: this.dayNotes,
          onClose: (): void => this.closeDay(),
          onOpenNote: (n: ObservationNote): void => this.openNoteDetail(n)
        })
      }

      if (this.showDetail && this.detailNote.id.length > 0) {
        NoteDetailOverlay({
          note: this.detailNote,
          onClose: (): void => this.closeDetail(),
          onDelete: (): void => { void this.deleteDetailNote() },
          onSave: (text: string, emotionKey: string): void => {
            void this.saveDetailNote(text, emotionKey)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
