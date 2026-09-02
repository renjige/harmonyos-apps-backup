import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { MoodPicker } from '../components/daily/MoodPicker'
import { DailyConstants, MoodEntry } from '../models/DailyModels'
import { DailyLocalStore, DateHelper } from '../services/DailyLocalStore'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = true
  hasMood: boolean = false
}

@Component
export struct DiaryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State year: number = 2026
  @State month: number = 8
  @State cells: CalendarCell[] = []
  @State moodMap: Map<string, MoodEntry> = new Map()
  @State showEditor: boolean = false
  @State editDateKey: string = ''
  @State editMoodKey: string = ''
  @State editMoodLabel: string = ''
  @State editNote: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    void this.reload()
  }

  private async reload(): Promise<void> {
    const moods = await DailyLocalStore.loadMoods()
    const map = new Map<string, MoodEntry>()
    for (const m of moods) {
      map.set(m.dateKey, m)
    }
    this.moodMap = map
    this.buildCells()
  }

  private buildCells(): void {
    const first = new Date(this.year, this.month - 1, 1)
    const startWeek = first.getDay()
    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    const list: CalendarCell[] = []
    for (let i = 0; i < startWeek; i++) {
      const c = new CalendarCell()
      c.day = 0
      c.inMonth = false
      list.push(c)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const c = new CalendarCell()
      c.day = d
      c.inMonth = true
      c.dateKey = DateHelper.keyFromDate(new Date(this.year, this.month - 1, d))
      c.hasMood = this.moodMap.has(c.dateKey)
      list.push(c)
    }
    this.cells = list
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y--
    } else if (m > 12) {
      m = 1
      y++
    }
    this.month = m
    this.year = y
    this.buildCells()
  }

  private openEditor(dateKey: string): void {
    this.editDateKey = dateKey
    const existing = this.moodMap.get(dateKey)
    if (existing !== undefined) {
      this.editMoodKey = existing.moodKey
      this.editMoodLabel = existing.moodLabel
      this.editNote = existing.note
    } else {
      this.editMoodKey = 'happy'
      this.editMoodLabel = '开心'
      this.editNote = ''
    }
    AppStorage.setOrCreate('tabBarHidden', true)
    this.showEditor = true
  }

  private closeEditor(): void {
    this.showEditor = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async saveEntry(): Promise<void> {
    if (this.editMoodKey.length === 0) {
      this.toastText = '请选择心情'
      return
    }
    const entry = MoodEntry.create(this.editDateKey, this.editMoodKey, this.editMoodLabel, this.editNote)
    await DailyLocalStore.saveMood(entry)
    this.toastText = '已保存'
    this.closeEditor()
    await this.reload()
    setTimeout(() => { this.toastText = '' }, 2000)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(`${this.year}年${this.month}月`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => this.shiftMonth(-1))
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.shiftMonth(1))
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Row() {
          ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
            Text(w)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

        Grid() {
          ForEach(this.cells, (cell: CalendarCell, idx: number) => {
            GridItem() {
              if (cell.inMonth) {
                Column({ space: 2 }) {
                  Text(`${cell.day}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(cell.dateKey === DateHelper.todayKey() ?
                      Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  if (cell.hasMood) {
                    Circle({ width: 6, height: 6 })
                      .fill(Theme.colors().brandAccent)
                  }
                }
                .width('100%')
                .height(52)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(cell.dateKey === DateHelper.todayKey() ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick(() => this.openEditor(cell.dateKey))
              }
            }
          }, (cell: CalendarCell, idx: number) => `${idx}-${cell.dateKey}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .layoutWeight(1)

        if (this.moodMap.size === 0) {
          AppEmpty({
            title: '还没有心情记录',
            description: '点击日历上的日期，写下今天的一句话'
          })
            .padding(Theme.space.pageX)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showEditor) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Row() {
              Text(this.editDateKey)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('关闭')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .onClick(() => this.closeEditor())
            }
            .width('100%')

            MoodPicker({
              options: DailyConstants.moods(),
              selectedKey: this.editMoodKey,
              onSelect: (key: string, label: string) => {
                this.editMoodKey = key
                this.editMoodLabel = label
              }
            })

            TextArea({ text: this.editNote, placeholder: '用一句话记录今天（140字以内）' })
              .height(120)
              .maxLength(140)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string) => { this.editNote = v })

            AppButton({
              label: '保存',
              onTap: (): void => { void this.saveEntry() }
            })
          }
          .padding(Theme.space.s5)
          .width('100%')
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .backgroundColor(Theme.colors().overlayScrim)
      }

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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
