import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MonthStampGrid } from '../components/journal/MonthStampGrid'
import { JournalListCard } from '../components/journal/JournalListCard'
import { LifePageShell } from '../components/life/LifePageShell'
import { LifeDates, TodoItem } from '../models/LifeHubModels'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalCatalog } from '../services/JournalCatalog'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct LifeCalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onRequireAuth: () => void = () => {}
  @State year: number = 2026
  @State month: number = 1
  @State marked: string[] = []
  @State picked: string = ''
  @State diaries: JournalItem[] = []
  @State moodText: string = ''
  @State todos: TodoItem[] = []

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.picked = LifeDates.todayIso()
    void this.reloadMarks()
    void this.loadDay(this.picked)
  }

  private async reloadMarks(): Promise<void> {
    const marks: string[] = []
    if (AuthService.isLoggedIn()) {
      const list = await JournalBizService.cachedDiaries(this.currentUsername)
      for (const d of list) {
        if (d.recordDate.length >= 10) {
          marks.push(d.recordDate.substring(0, 10))
        }
      }
    }
    const moods = await LifeHubStore.loadMoods()
    for (const m of moods) {
      marks.push(m.date)
    }
    const todos = await LifeHubStore.loadTodos()
    for (const t of todos) {
      marks.push(t.date)
    }
    this.marked = marks
  }

  private async loadDay(iso: string): Promise<void> {
    this.picked = iso
    this.diaries = []
    this.todos = []
    this.moodText = ''
    if (AuthService.isLoggedIn()) {
      const all = await JournalBizService.cachedDiaries(this.currentUsername)
      for (const d of all) {
        if (d.recordDate.substring(0, 10) === iso) {
          this.diaries.push(d)
        }
      }
    }
    const mood = await LifeHubStore.moodOn(iso)
    if (mood !== undefined) {
      const label = JournalCatalog.moodLabel(mood.moodId)
      this.moodText = mood.note.length > 0 ? `${label} · ${mood.note}` : label
    }
    const todos = await LifeHubStore.loadTodos()
    for (const t of todos) {
      if (t.date === iso) {
        this.todos.push(t)
      }
    }
  }

  private writeForDay(): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    AppStorage.setOrCreate('journalPrefillDate', this.picked)
    AppStorage.setOrCreate('pendingTab', 3)
    AppStorage.setOrCreate('pendingWriteDiary', Date.now())
    LifeHubNav.close()
  }

  build() {
    LifePageShell({
      title: '生活日历',
      subtitle: '按日期回看 · 快速补记',
      onClose: (): void => { LifeHubNav.backOrClose() },
      body: () => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Text(`${this.year}年${this.month}月`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      MonthStampGrid({
        year: this.year,
        month: this.month,
        markedIso: this.marked,
        onPick: (iso: string): void => { void this.loadDay(iso) }
      })
      Text(`已选 ${this.picked}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '为这一天写一页',
        onTap: (): void => { this.writeForDay() }
      })
      if (this.moodText.length > 0) {
        Text(`心情：${this.moodText}`)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
      }
      if (this.diaries.length === 0 && this.todos.length === 0 && this.moodText.length === 0) {
        AppEmpty({
          title: '这一天还没有记录',
          description: '可以写一页笺语，或先记下心情与待办',
          actionLabel: '写一页',
          onAction: (): void => { this.writeForDay() }
        })
      }
      ForEach(this.diaries, (item: JournalItem) => {
        JournalListCard({
          item: item,
          compact: true,
          onTap: (): void => { JournalDetailNav.openDiary(item.id) }
        })
      }, (item: JournalItem) => `cal_${item.id}`)
      ForEach(this.todos, (row: TodoItem) => {
        Text(`${row.done ? '已完成' : '待办'} · ${row.title}`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
      }, (row: TodoItem) => `td_${row.id}`)
    }
    .width('100%')
  }
}
