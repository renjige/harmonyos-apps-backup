import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { NoteItem, TrainLog, ChecklistItem, KnowledgeCard, GoalProgress } from '../models/TuceModels'
import { TuceStore } from '../services/TuceStore'
import { TuceNav } from '../services/TuceNav'
import { TuceEngine } from '../services/TuceEngine'
import { TrainMonthGrid } from '../components/tuce/TrainMonthGrid'
import { CalendarCell } from '../services/StatisticsUtil'
import { GoalProgressCard } from '../components/tuce/GoalProgressCard'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onToken') reloadToken: number = 0
  @State logs: TrainLog[] = []
  @State notes: NoteItem[] = []
  @State cells: CalendarCell[] = []
  @State bars: BarChartItem[] = []
  @State goalProgress: GoalProgress = new GoalProgress()
  @State checklist: ChecklistItem[] = []
  @State cards: KnowledgeCard[] = []
  @State monthHint: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.logs = await TuceStore.logs()
    this.notes = await TuceStore.notes()
    this.cells = await TuceEngine.monthCalendar()
    this.bars = await TuceEngine.weeklyBars()
    this.goalProgress = await TuceEngine.goalProgress()
    this.checklist = await TuceStore.checklist()
    this.cards = await TuceStore.cards()
    this.monthHint = TuceEngine.monthCount(this.logs.length)
  }

  private previewCards(): KnowledgeCard[] {
    const out: KnowledgeCard[] = []
    for (let i = 0; i < this.cards.length && i < 3; i++) {
      out.push(this.cards[i])
    }
    return out
  }

  private checklistDone(): number {
    let n = 0
    for (const it of this.checklist) {
      if (it.done) {
        n++
      }
    }
    return n
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private onCalendarDay(dateKey: string): void {
    const today = TuceStore.today()
    if (dateKey === today) {
      TuceNav.open('logform', '')
      return
    }
    for (const log of this.logs) {
      if (log.date === dateKey) {
        TuceNav.open('log', log.id)
        return
      }
    }
    this.showToast('仅支持为今日打卡；该日期暂无训练记录')
  }

  build() {
    Stack() {
      Column() {
      AppHeader({ title: '成长记录', subtitle: '日历热力、数据看板与训练日志' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.cat_cardio'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text(this.monthHint)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.72)', 1]]
              })
          }
          .width('100%')
          .height(120)

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '写训练日志',
              variant: 'primary',
              onTap: (): void => { TuceNav.open('logform', '') }
            }).layoutWeight(1)
            AppButton({
              label: '写笔记',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('noteform', '') }
            }).layoutWeight(1)
          }
          .width('100%')

          GoalProgressCard({ progress: this.goalProgress })

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '训练周报',
              variant: 'primary',
              onTap: (): void => { TuceNav.open('weeklyreport', '') }
            }).layoutWeight(1)
            AppButton({
              label: '体能自测',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('quiz', '') }
            }).layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '精选课库',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('presets', '') }
            }).layoutWeight(1)
            AppButton({
              label: '动作对比',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('movecompare', '') }
            }).layoutWeight(1)
          }
          .width('100%')

          TrainMonthGrid({
            title: '训练日历（点击今日可打卡）',
            cells: this.cells,
            onSelectDay: (dateKey: string): void => { this.onCalendarDay(dateKey) }
          })

          AppBarChart({ title: '本周训练频次', items: this.bars })

          Row({ space: Theme.space.s3 }) {
            Column({ space: Theme.space.s2 }) {
              Text('训练清单')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${this.checklistDone()}/${this.checklist.length} 项已完成`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              AppButton({
                label: '打开清单',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('checklist', '') }
              })
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            AppRingChart({ title: '周目标', percent: this.goalProgress.weeklyPct })
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '知识卡库',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('klist', '') }
            }).layoutWeight(1)
            AppButton({
              label: '运动回顾',
              variant: 'ghost',
              onTap: (): void => { TuceNav.open('review', '') }
            }).layoutWeight(1)
          }
          .width('100%')

          Text('训练日志')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.logs.length === 0) {
            AppEmpty({
              title: '还没有训练日志',
              description: '完成一次训练后，记录完成情况和自我评价',
              actionLabel: '去记录',
              onAction: (): void => { TuceNav.open('logform', '') }
            })
          }
          ForEach(this.logs, (log: TrainLog) => {
            Row({ space: Theme.space.s3 }) {
              Column()
                .width(48)
                .height(48)
                .borderRadius(Theme.radius.sm)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
              Column({ space: 4 }) {
                Text(`${log.date} · ${log.planName}`)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(log.doneText)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  Text(`完成 ${log.complete}/5`)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(`感受 ${log.feel}`)
                    .fontSize(Theme.type.overline)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TuceNav.open('log', log.id) })
          }, (log: TrainLog) => log.id)

          Text('运动笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.notes.length === 0 && this.cards.length === 0) {
            Text('笔记与知识卡会帮助你复盘每次训练')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          ForEach(this.notes, (n: NoteItem) => {
            Column({ space: 4 }) {
              Text(n.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(n.body)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .maxLines(2)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { TuceNav.open('note', n.id) })
          }, (n: NoteItem) => n.id)

          if (this.cards.length > 0) {
            Text(`知识卡 (${this.cards.length})`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.previewCards(), (c: KnowledgeCard) => {
              Text(`${c.moveName} · ${c.focus}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { TuceNav.open('kcard', c.id) })
            }, (c: KnowledgeCard) => c.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
