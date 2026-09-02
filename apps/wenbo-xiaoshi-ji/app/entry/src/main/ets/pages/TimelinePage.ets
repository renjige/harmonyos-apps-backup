import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteCard, NoteCardBinder } from '../components/moment/NoteCard'
import { ActivityStrip } from '../components/moment/ActivityStrip'
import { WeekPosterCard } from '../components/moment/WeekPosterCard'
import { MonthCell, MomentNote, WeekSummary, DayActivity, LifeMemorial } from '../models/MomentModels'
import { DateHelper } from '../services/DateHelper'
import { MomentStore } from '../services/MomentStore'
import { MomentNav } from '../services/MomentNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onClose: () => void = () => {}
  @State year: number = 2026
  @State month: number = 0
  @State cells: MonthCell[] = []
  @State selectedKey: string = ''
  @State dayNotes: MomentNote[] = []
  @State monthCount: number = 0
  @State streak: number = 0
  @State weekLine: string = ''
  @State posterTitle: string = ''
  @State posterKeep: string = ''
  @State activityDays: DayActivity[] = []
  @State memorialLine: string = ''
  @State toast: string = ''
  private weekNames: string[] = ['日', '一', '二', '三', '四', '五', '六']

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth()
    this.selectedKey = DateHelper.todayKey()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.cells = await MomentStore.monthCells(this.year, this.month)
    this.monthCount = await MomentStore.monthNoteCount(this.year, this.month)
    this.streak = await MomentStore.streakDays()
    const week: WeekSummary = await MomentStore.weekSummary()
    this.weekLine = week.line
    const poster = await MomentStore.buildWeekPoster()
    this.posterTitle = `记下 ${poster.noteCount} 件小事 · 连续 ${poster.streak} 天`
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    this.posterKeep = wrap.keep.trim().length > 0 ? wrap.keep.trim() : '今晚可以写一句今日收束'
    this.activityDays = await MomentStore.last7DayActivity()
    this.dayNotes = await MomentStore.notesOn(this.selectedKey)
    const next: LifeMemorial | undefined = await MomentStore.nextMemorial()
    if (next !== undefined) {
      const days = DateHelper.daysUntil(next.dateKey)
      const when = days === 0 ? '今天' : (days === 1 ? '明天' : `${days} 天后`)
      this.memorialLine = `${next.title} · ${when} ${next.time}`
    } else {
      this.memorialLine = ''
    }
  }

  private async shiftMonth(delta: number): Promise<void> {
    let m = this.month + delta
    let y = this.year
    if (m < 0) {
      m = 11
      y--
    }
    if (m > 11) {
      m = 0
      y++
    }
    this.month = m
    this.year = y
    await this.reload()
  }

  private async pick(cell: MonthCell): Promise<void> {
    if (!cell.inMonth) {
      return
    }
    this.selectedKey = cell.dateKey
    this.dayNotes = await MomentStore.notesOn(cell.dateKey)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2600)
  }

  private async shareWeek(): Promise<void> {
    const card = await MomentStore.buildWeekPoster()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, card.body)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('本周生活海报已复制，可粘贴分享')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async shareMonth(): Promise<void> {
    const card = await MomentStore.buildMonthShare(this.year, this.month)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, card.body)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('本月记录卡片已复制，可粘贴到备忘录或社交软件分享')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => this.onClose())
            Text('时光轴')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .rotate({ angle: 180 })
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { void this.shiftMonth(-1) })
            Text(DateHelper.monthTitle(this.year, this.month))
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { void this.shiftMonth(1) })
          }
          .width('100%')
          .padding({ top: Theme.space.s4 })

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.calendar_window'))
              .width('100%')
              .height(128)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
            Column()
              .width('100%')
              .height(72)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(45,45,45,0.62)', 1]]
              })
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })
            Text(`本月 ${this.monthCount} 件小事 · 连续 ${this.streak} 天 · 生活轨迹`)
              .fontSize(Theme.type.body)
              .fontColor('#FFFFFF')
              .padding({ left: 16, bottom: 12 })
          }
          .clip(true)
          .borderRadius(16)

          Text(this.weekLine)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(20)
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)

          WeekPosterCard({
            posterTitle: this.posterTitle,
            posterLine: this.weekLine,
            posterKeep: this.posterKeep,
            onCopy: (): void => { void this.shareWeek() }
          })

          ActivityStrip({ days: this.activityDays, title: '近 7 日记录与完成' })

          if (this.memorialLine.length > 0) {
            Column({ space: 4 }) {
              Text('下一条纪念日')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(this.memorialLine)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
            .onClick((): void => MomentNav.openMemorials())
          }

          AppButton({
            label: '写本周复盘（三问整理）',
            variant: 'primary',
            onTap: (): void => { MomentNav.openWeeklyReview() }
          })
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '打卡日历',
                variant: 'secondary',
                onTap: (): void => MomentNav.openCheckin()
              })
            }.layoutWeight(1)
            Column() {
              AppButton({
                label: '心情轨迹',
                variant: 'secondary',
                onTap: (): void => MomentNav.openMoodTrend()
              })
            }.layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '今日收束',
                variant: 'secondary',
                onTap: (): void => MomentNav.openDailyWrap()
              })
            }.layoutWeight(1)
            Column() {
              AppButton({
                label: '纪念日',
                variant: 'secondary',
                onTap: (): void => MomentNav.openMemorials()
              })
            }.layoutWeight(1)
          }
          .width('100%')

          Row() {
            ForEach(this.weekNames, (w: string) => {
              Text(w)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('14.2%')
                .textAlign(TextAlign.Center)
            }, (w: string) => w)
          }
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cells, (c: MonthCell) => {
              Column({ space: 4 }) {
                Text(c.inMonth ? `${c.day}` : '')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.selectedKey === c.dateKey && c.inMonth ?
                    '#FFFFFF' : Theme.colors().textPrimary)
                if (c.hasNote) {
                  Column()
                    .width(6)
                    .height(6)
                    .borderRadius(3)
                    .backgroundColor(this.selectedKey === c.dateKey ?
                      Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                }
              }
              .width('14.2%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.selectedKey === c.dateKey && c.inMonth ?
                Theme.colors().brandPrimary : 'transparent')
              .borderRadius(12)
              .onClick((): void => { void this.pick(c) })
            }, (c: MonthCell) => `slot_${c.slot}`)
          }
          .width('100%')

          AppButton({
            label: '分享本月记录卡片',
            variant: 'secondary',
            onTap: (): void => { void this.shareMonth() }
          })

          Text(DateHelper.displayLong(this.selectedKey))
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.dayNotes.length === 0) {
            AppEmpty({
              title: '这一天还没有小事',
              description: '去灵感随记写下一条吧'
            })
          } else {
            ForEach(this.dayNotes, (n: MomentNote) => {
              NoteCard({
                noteId: n.id,
                content: n.content,
                tagsText: NoteCardBinder.tagsText(n),
                stripe: n.stripeColor(),
                timeLabel: DateHelper.timeLabel(n.createdAt),
                pinned: n.pinned,
                onOpen: (): void => MomentNav.openNote(n.id)
              })
            }, (n: MomentNote) => `${n.id}_${n.pinned ? '1' : '0'}_${n.updatedAt}`)
          }
          Row().height(this.bottomInset)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
