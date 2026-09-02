import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { CatalogItem, HeatCell, InsightBundle, SlotBar, StudySession, TimelineItem } from '../models/StudyModels'
import { StudyStore } from '../services/StudyStore'
import { StudyInsightService } from '../services/StudyInsightService'
import { StudyBizService } from '../services/StudyBizService'
import { StudyMedia } from '../services/StudyMedia'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct InsightPage {
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State rangeDays: number = 7
  @State bundle: InsightBundle = new InsightBundle()
  @State bars: BarChartItem[] = []
  @State chartStamp: number = 0
  @State slotSummary: string = '完成专注或补记后，将按清晨 / 上午 / 下午 / 晚上累计分钟。'
  @State timeline: TimelineItem[] = []
  @State tips: CatalogItem[] = []
  @State heat: HeatCell[] = []
  @State toastText: string = ''
  onOpenTip: (id: string) => void = (_id: string) => {}
  onOpenDiagnose: () => void = () => {}
  onOpenDay: (dateKey: string) => void = (_k: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const sessions: StudySession[] = await StudyStore.loadSessions()
    const notes = await StudyStore.loadNotes()
    const cards = await StudyStore.loadCards()
    this.bundle = StudyInsightService.build(sessions, cards, notes.length, this.rangeDays)
    const noteTitles: string[] = []
    const noteTimes: number[] = []
    for (const n of notes) {
      noteTitles.push(n.title)
      noteTimes.push(n.createdAt)
    }
    const cardTitles: string[] = []
    const cardTimes: number[] = []
    for (const c of cards) {
      cardTitles.push(c.title)
      cardTimes.push(c.createdAt)
    }
    this.timeline = StudyInsightService.timeline(sessions, noteTitles, noteTimes, cardTitles, cardTimes)
    const slots: SlotBar[] = StudyInsightService.hourBars(sessions, this.rangeDays)
    const mapped: BarChartItem[] = []
    for (const s of slots) {
      const b = new BarChartItem()
      b.label = s.label
      b.value = s.value
      mapped.push(b)
    }
    this.bars = mapped
    const parts: string[] = []
    for (let i = 0; i < mapped.length; i++) {
      parts.push(`${mapped[i].label} ${mapped[i].value} 分钟`)
    }
    this.slotSummary = parts.join(' · ')
    this.chartStamp = this.chartStamp + 1
    this.heat = StudyStore.heat30(sessions)
    this.tips = await StudyBizService.loadTips()
  }

  private setRange(days: number): void {
    this.rangeDays = days
    void this.load()
  }

  private async exportReport(): Promise<void> {
    try {
      const text = StudyInsightService.exportText(this.bundle, this.rangeDays)
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.toastText = '报告已复制到剪贴板'
    } catch {
      this.toastText = '复制失败，请重试'
    }
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private heatColor(m: number): string {
    if (m <= 0) {
      return Theme.colors().surfaceSubtle
    }
    if (m < 16) {
      return '#8A6A32'
    }
    if (m < 40) {
      return '#5C4A28'
    }
    return '#1A2A4A'
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.themeEpoch >= 0 ? '洞察' : '洞察')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_insight'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column() {
              Blank()
              Text('看见时长、节奏与成长轨迹')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor('#CC1A2A4A')
            }
            .width('100%')
            .height(140)
          }
          .width('100%')
          .height(140)
          .borderRadius(Theme.radius.lg)
          .clip(true)

          Row({ space: 8 }) {
            Text('周报')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.rangeDays === 7 ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(this.rangeDays === 7 ? '#1A2A4A' : Theme.colors().surfaceSubtle)
              .borderRadius(18)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.setRange(7) })
            Text('月报')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.rangeDays === 30 ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(this.rangeDays === 30 ? '#1A2A4A' : Theme.colors().surfaceSubtle)
              .borderRadius(18)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { this.setRange(30) })
            Text('导出报告')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor('#1A2A4A')
              .borderRadius(18)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => { void this.exportReport() })
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '总时长', value: `${this.bundle.totalMinutes}` })
              .layoutWeight(1)
            AppStatCard({ label: '学习天数', value: `${this.bundle.studyDays}` })
              .layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '知识卡片', value: `${this.bundle.cardCount}` })
              .layoutWeight(1)
            AppStatCard({ label: '连续天数', value: `${this.bundle.streak}` })
              .layoutWeight(1)
          }
          .width('100%')

          AppBarChart({ title: '按时段累计（分钟）', items: this.bars, stamp: this.chartStamp })
          Text(this.slotSummary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.isDark() ? '#F8FAFC' : '#0F172A')
            .width('100%')

          Text('近 30 日日历')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.heat, (c: HeatCell) => {
              Text(c.dayLabel)
                .fontSize(Theme.type.caption)
                .fontColor(c.minutes > 0 ? '#FFFFFF' : Theme.colors().textSecondary)
                .width(36)
                .height(36)
                .textAlign(TextAlign.Center)
                .margin(3)
                .borderRadius(8)
                .backgroundColor(this.heatColor(c.minutes))
                .onClick((): void => { this.onOpenDay(c.dateKey) })
            }, (c: HeatCell) => `cal-${c.dateKey}`)
          }
          .width('100%')
          Text('点日期查看当天学习日记')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.bodyMuted())
            .width('100%')

          Column({ space: 8 }) {
            Text('智慧分析')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.bundle.peakHint)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.bundle.advice)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('学习节律自测')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onOpenDiagnose() })
            .width('100%')

          Text('成长轨迹')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.timeline.length === 0) {
            Text('完成第一段专注、补记时长或写下笔记后，轨迹会出现在这里。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.timeline, (t: TimelineItem) => {
              Column({ space: 4 }) {
                Text(t.timeLabel)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(t.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(t.subtitle)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
            }, (t: TimelineItem) => t.id)
          }

          Text('学习锦囊')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.tips, (tip: CatalogItem) => {
            Row({ space: 10 }) {
              Image(StudyMedia.resource(tip.coverKey))
                .width(56)
                .height(56)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
              Text(tip.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(12)
            .onClick((): void => { this.onOpenTip(tip.id) })
          }, (tip: CatalogItem) => tip.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s8
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
