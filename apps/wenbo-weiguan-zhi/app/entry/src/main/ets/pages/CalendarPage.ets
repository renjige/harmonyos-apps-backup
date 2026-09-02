import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { EssayListCard } from '../components/essay/EssayListCard'
import { EssayDetailPane } from '../components/essay/EssayDetailPane'
import { EssayEditorSheet } from '../components/essay/EssayEditorSheet'
import { CalDayCell, MicroEssay } from '../models/EssayModels'
import { EssayStore } from '../services/EssayStore'
import { DateHelper } from '../services/DateHelper'
import { GrowthStore } from '../services/GrowthStore'
import { ObserveEvent } from '../models/GrowthModels'
import { MonthRecapPane } from '../components/essay/MonthRecapPane'
import { FootprintBlock } from '../components/essay/FootprintBlock'

@Component
export struct CalendarPage {
  @Prop @Watch('onReloadToken') reloadToken: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('essayDataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State year: number = 2026
  @State month: number = 1
  @State cells: CalDayCell[] = []
  @State selectedKey: string = ''
  @State dayEssays: MicroEssay[] = []
  @State monthCount: number = 0
  @State detailId: string = ''
  @State showEditor: boolean = false
  @State editingId: string = ''
  @State lastEpoch: number = -1
  @State showMonthRecap: boolean = false
  @State events: ObserveEvent[] = []
  private weekday: string[] = ['一', '二', '三', '四', '五', '六', '日']

  aboutToAppear(): void {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.selectedKey = DateHelper.todayKey()
    void this.reload()
  }

  onReloadToken(): void {
    void this.reload()
  }

  onDataEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await EssayStore.loadAll()
    this.cells = this.buildCells(all)
    this.monthCount = 0
    for (const e of all) {
      const key = EssayStore.resolvedDateKey(e)
      if (key.startsWith(this.monthPrefix())) {
        this.monthCount++
      }
    }
    this.events = GrowthStore.buildFootprint(all, this.year, this.month)
    await this.loadDay()
  }

  private monthPrefix(): string {
    const ms = this.month < 10 ? `0${this.month}` : `${this.month}`
    return `${this.year}-${ms}`
  }

  private buildCells(all: MicroEssay[]): CalDayCell[] {
    const countMap = new Map<string, number>()
    for (const e of all) {
      const key = EssayStore.resolvedDateKey(e)
      if (key.length > 0) {
        countMap.set(key, (countMap.get(key) ?? 0) + 1)
      }
    }
    const first = new Date(this.year, this.month - 1, 1)
    const startPad = (first.getDay() + 6) % 7
    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    const out: CalDayCell[] = []
    for (let i = 0; i < startPad; i++) {
      out.push(new CalDayCell())
    }
    for (let d = 1; d <= daysInMonth; d++) {
      const cell = new CalDayCell()
      cell.inMonth = true
      cell.day = d
      cell.key = DateHelper.keyFromDate(new Date(this.year, this.month - 1, d))
      cell.count = countMap.get(cell.key) ?? 0
      out.push(cell)
    }
    return out
  }

  private async loadDay(): Promise<void> {
    this.dayEssays = await EssayStore.loadByDate(this.selectedKey)
  }

  private prevMonth(): void {
    if (this.month === 1) {
      this.month = 12
      this.year--
    } else {
      this.month--
    }
    void this.reload()
  }

  private nextMonth(): void {
    if (this.month === 12) {
      this.month = 1
      this.year++
    } else {
      this.month++
    }
    void this.reload()
  }

  private select(cell: CalDayCell): void {
    if (!cell.inMonth) {
      return
    }
    this.selectedKey = cell.key
    void this.loadDay()
  }

  private openBackfill(): void {
    this.editingId = ''
    this.showEditor = true
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .rotate({ angle: 180 })
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.prevMonth() })
          Blank()
          Column({ space: 2 }) {
            Text(DateHelper.monthTitle(this.year, this.month))
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`本月 ${this.monthCount} 条观察`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          Blank()
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.nextMonth() })
        }
        .width('100%')
        .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s3 })

        Text('按观察日回看 · 五感练习足迹')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 4, bottom: Theme.space.s2 })

        Text('本月观察回顾')
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width('90%')
          .padding({ top: 8, bottom: 8 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.sm)
          .onClick((): void => { this.showMonthRecap = true })

        Scroll() {
          Column() {
            Row() {
              ForEach(this.weekday, (w: string) => {
                Text(w)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
              }, (w: string) => w)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cells, (cell: CalDayCell, idx: number) => {
                Column({ space: 2 }) {
                  Text(cell.inMonth ? `${cell.day}` : '')
                    .fontSize(Theme.type.body)
                    .fontColor(cell.key === this.selectedKey ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  if (cell.count > 0) {
                    Circle()
                      .width(6)
                      .height(6)
                      .fill(cell.key === this.selectedKey ? Theme.colors().brandOnPrimary : Theme.colors().brandAccent)
                  }
                }
                .width('14.28%')
                .height(52)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(cell.key === this.selectedKey ? Theme.colors().brandPrimary : 'transparent')
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.select(cell) })
              }, (cell: CalDayCell, idx: number) => `d_${idx}_${cell.key}_${cell.count}`)
            }
            .width('100%')
            .padding({ left: Theme.space.s2, right: Theme.space.s2 })

            Text(`${DateHelper.displayDate(this.selectedKey)} 的观察`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding({ left: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

            if (this.dayEssays.length === 0) {
              AppEmpty({
                title: '这一天还是空白',
                description: '点下方按钮补记当天的微观瞬间',
                actionLabel: '补记这一天',
                onAction: (): void => { this.openBackfill() }
              })
            } else {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.dayEssays, (item: MicroEssay) => {
                  EssayListCard({
                    essay: item,
                    fontScale: this.fontScale,
                    onTap: (): void => { this.detailId = item.id }
                  })
                }, (item: MicroEssay) => `${item.id}_${item.updatedAt}`)
                Text('补记这一天')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor('#1A2A3A')
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { this.openBackfill() })
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }

            FootprintBlock({
              events: this.events,
              onOpen: (id: string): void => { this.detailId = id }
            })

            Blank().height(Theme.space.s10)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailId.length > 0) {
        EssayDetailPane({
          essayId: this.detailId,
          fontScale: this.fontScale,
          onClose: (): void => { this.detailId = '' },
          onEdit: (): void => {
            this.editingId = this.detailId
            this.detailId = ''
            this.showEditor = true
          },
          onDeleted: (): void => {
            this.detailId = ''
            void this.reload()
          },
          onChanged: (): void => { void this.reload() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }

      if (this.showMonthRecap) {
        MonthRecapPane({
          year: this.year,
          month: this.month,
          onClose: (): void => { this.showMonthRecap = false },
          onWrite: (): void => {
            this.showMonthRecap = false
            this.editingId = ''
            this.showEditor = true
          },
          onOpen: (id: string): void => {
            this.showMonthRecap = false
            this.detailId = id
          }
        })
      }

      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.fontScale,
          openAsCard: this.editingId.length === 0,
          presetDateKey: this.editingId.length === 0 ? this.selectedKey : '',
          onClose: (): void => {
            this.showEditor = false
            void this.reload()
          },
          onSaved: (): void => {
            this.showEditor = false
            void this.reload()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.dataEpoch !== this.lastEpoch) {
        this.lastEpoch = this.dataEpoch
        void this.reload()
      }
    })
  }
}
