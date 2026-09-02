import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { JournalItem, MoodItem, BreathSessionItem } from '../models/CoolPlanModels'
import { AppButton } from '../components/design-system/AppButton'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { CoolPlanLocalStore } from '../services/CoolPlanLocalStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  mood: string = ''
  hasJournal: boolean = false
  breathSec: number = 0
}

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State cells: CalendarCell[] = []
  @State moods: MoodItem[] = []
  @State journals: JournalItem[] = []
  @State sessions: BreathSessionItem[] = []
  @State monthMoodCount: number = 0
  @State monthBreathMin: number = 0
  @State monthJournalCount: number = 0
  @State selectedDate: string = ''
  @State selectedJournal: string = ''
  @State selectedMood: string = ''
  @State selectedJournalId: string = ''
  @State selectedMoodId: string = ''
  @State selectedBreathSec: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    const d = new Date()
    this.year = d.getFullYear()
    this.month = d.getMonth() + 1
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.moods = await CoolPlanBizService.loadMoods()
    this.journals = await CoolPlanBizService.loadJournals()
    this.sessions = await CoolPlanBizService.loadBreathSessions()
    this.buildCells(this.sessions)
    this.monthMoodCount = 0
    this.monthBreathMin = 0
    this.monthJournalCount = 0
    const prefix = `${this.year}-${this.month < 10 ? '0' : ''}${this.month}`
    for (const m of this.moods) {
      if (m.noteDate.startsWith(prefix)) {
        this.monthMoodCount += 1
      }
    }
    for (const j of this.journals) {
      if (j.noteDate.startsWith(prefix)) {
        this.monthJournalCount += 1
      }
    }
    let sec = 0
    for (const s of this.sessions) {
      if (s.noteDate.startsWith(prefix)) {
        sec += s.durationSec
      }
    }
    this.monthBreathMin = Math.floor(sec / 60)
    if (this.selectedDate.length === 0) {
      this.selectedDate = CoolPlanLocalStore.todayKey()
    }
    this.pickDate(this.selectedDate)
  }

  private buildCells(sessions: BreathSessionItem[]): void {
    const list: CalendarCell[] = []
    const first = new Date(this.year, this.month - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    let i = 0
    while (i < startWeek) {
      const c = new CalendarCell()
      c.inMonth = false
      list.push(c)
      i += 1
    }
    let day = 1
    while (day <= daysInMonth) {
      const c = new CalendarCell()
      c.day = day
      c.inMonth = true
      const ms = this.month < 10 ? `0${this.month}` : `${this.month}`
      const ds = day < 10 ? `0${day}` : `${day}`
      c.dateKey = `${this.year}-${ms}-${ds}`
      c.mood = this.moodForKey(c.dateKey)
      c.hasJournal = this.hasJournalForKey(c.dateKey)
      c.breathSec = this.breathSecForKey(c.dateKey, sessions)
      list.push(c)
      day += 1
    }
    this.cells = list
  }

  private hasJournalForKey(key: string): boolean {
    for (const j of this.journals) {
      if (j.noteDate === key) {
        return true
      }
    }
    return false
  }

  private breathSecForKey(key: string, sessions: BreathSessionItem[]): number {
    let total = 0
    for (const s of sessions) {
      if (s.noteDate === key) {
        total += s.durationSec
      }
    }
    return total
  }

  private moodForKey(key: string): string {
    for (const m of this.moods) {
      if (m.noteDate === key) {
        return m.mood
      }
    }
    return ''
  }

  private moodColor(mood: string): string {
    if (mood === '愉悦') {
      return Theme.colors().success
    }
    if (mood === '平静') {
      return Theme.colors().brandPrimary
    }
    if (mood === '专注') {
      return Theme.colors().info
    }
    if (mood === '疲惫') {
      return Theme.colors().warning
    }
    if (mood === '焦虑') {
      return Theme.colors().danger
    }
    return Theme.colors().strokeStrong
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2600)
  }

  private pickDate(key: string): void {
    this.selectedDate = key
    this.selectedJournal = ''
    this.selectedMood = ''
    this.selectedJournalId = ''
    this.selectedMoodId = ''
    this.selectedBreathSec = 0
    for (const j of this.journals) {
      if (j.noteDate === key && this.selectedJournalId.length === 0) {
        this.selectedJournal = j.body
        this.selectedJournalId = j.id
      }
    }
    for (const m of this.moods) {
      if (m.noteDate === key && this.selectedMoodId.length === 0) {
        this.selectedMood = m.mood
        this.selectedMoodId = m.id
      }
    }
    for (const s of this.sessions) {
      if (s.noteDate === key) {
        this.selectedBreathSec += s.durationSec
      }
    }
  }

  private hasSelectedRecord(): boolean {
    return this.selectedMood.length > 0 ||
      this.selectedJournal.length > 0 ||
      this.selectedBreathSec > 0
  }

  private async removeJournal(): Promise<void> {
    if (this.selectedJournalId.length === 0) {
      return
    }
    const ok = await CoolPlanBizService.deleteJournal(this.selectedJournalId)
    if (ok) {
      this.showToast('心语已删除')
      void this.reload()
    } else {
      this.showToast('删除失败，请稍后重试')
    }
  }

  private async removeMood(): Promise<void> {
    if (this.selectedMoodId.length === 0) {
      return
    }
    const ok = await CoolPlanBizService.deleteMood(this.selectedMoodId)
    if (ok) {
      this.showToast('心情记录已清除')
      void this.reload()
    } else {
      this.showToast('清除失败，请稍后重试')
    }
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y -= 1
    } else if (m > 12) {
      m = 1
      y += 1
    }
    this.month = m
    this.year = y
    void this.reload()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: 'calendar', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .linearGradient({
          angle: 135,
          colors: [[Theme.colors().brandPrimary, 0], ['#4A9E9E', 1]]
        })
        .borderRadius(Theme.radius.lg)
        Column({ space: 4 }) {
          Text('📅 心境日历')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('回顾心情与心语留下的痕迹')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '本月心情', value: `${this.monthMoodCount}`, trend: '次', positive: true })
              .layoutWeight(1)
            AppStatCard({ label: '本月心语', value: `${this.monthJournalCount}`, trend: '篇', positive: true })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '本月呼吸', value: `${this.monthBreathMin}`, trend: '分钟', positive: true })
              .layoutWeight(1)
            Column().layoutWeight(1)
          }
          .width('100%')

          Row() {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick(() => this.shiftMonth(-1))
            Text(`${this.year} 年 ${this.month} 月`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.shiftMonth(1))
          }
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.cells, (c: CalendarCell, idx: number) => {
              if (!c.inMonth) {
                Column().width('14.28%').height(40)
              } else {
                Column({ space: 2 }) {
                  Text(`${c.day}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.selectedDate === c.dateKey ?
                      Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  Row({ space: 2 }) {
                    if (c.mood.length > 0) {
                      Circle()
                        .width(5)
                        .height(5)
                        .fill(this.moodColor(c.mood))
                    }
                    if (c.hasJournal) {
                      Circle()
                        .width(5)
                        .height(5)
                        .fill(Theme.colors().brandAccent)
                    }
                    if (c.breathSec > 0) {
                      Circle()
                        .width(5)
                        .height(5)
                        .fill(Theme.colors().info)
                    }
                  }
                }
                .width('14.28%')
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.selectedDate === c.dateKey ?
                  Theme.colors().brandPrimary : 'transparent')
                .borderRadius(Theme.radius.sm)
                .onClick(() => this.pickDate(c.dateKey))
              }
            }, (c: CalendarCell, idx: number) => `${idx}_${c.dateKey}`)
          }
          .width('100%')

          AppCard({ title: this.selectedDate, variant: 'plain' }) {
            if (!this.hasSelectedRecord()) {
              AppEmpty({
                title: '这一天还没有记录',
                description: '在首页选心情、写心语，或在呼吸 Tab 练习，日历会自动标记。',
                iconName: 'calendar',
                emojiMark: '🌿'
              })
            } else {
              Column({ space: 8 }) {
                if (this.selectedMood.length > 0) {
                  Text(`${CategoryEmojiUtil.moodChip(this.selectedMood)}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                }
                if (this.selectedBreathSec > 0) {
                  Text(`🧘 呼吸练习 ${Math.max(1, Math.floor(this.selectedBreathSec / 60))} 分钟（${this.selectedBreathSec} 秒）`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                if (this.selectedJournal.length > 0) {
                  Text(this.selectedJournal)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                }
                Row({ space: Theme.space.s3 }) {
                  if (this.selectedMoodId.length > 0) {
                    AppButton({
                      label: '清除心情',
                      variant: 'secondary',
                      onTap: (): void => { void this.removeMood() }
                    }).layoutWeight(1)
                  }
                  if (this.selectedJournalId.length > 0) {
                    AppButton({
                      label: '删除心语',
                      variant: 'secondary',
                      onTap: (): void => { void this.removeJournal() }
                    }).layoutWeight(1)
                  }
                }
                .width('100%')
              }
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
