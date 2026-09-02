import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MoodDetailOverlay } from '../components/mood/MoodDetailOverlay'
import { MoodRecord, EmotionDef } from '../models/MoodModels'
import { EmotionCatalog } from '../models/EmotionCatalog'
import { DateHelper } from '../services/DateHelper'
import { MoodStore } from '../services/MoodStore'

class CalendarCell {
  day: number = 0
  dateKey: string = ''
  hasRecord: boolean = false
  dotColor: string = ''
  empty: boolean = false
}

@Component
export struct GalleryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1
  @State cells: CalendarCell[] = []
  @State records: MoodRecord[] = []
  @State filterEmotion: string = ''
  @State detailRecord: MoodRecord | null = null
  @State refreshSeen: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private onReload(): void {
    if (this.reloadToken !== this.refreshSeen) {
      this.refreshSeen = this.reloadToken
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.records = await MoodStore.recordsInMonth(this.year, this.month)
    this.cells = this.buildCells()
  }

  private buildCells(): CalendarCell[] {
    const out: CalendarCell[] = []
    const first = new Date(this.year, this.month - 1, 1)
    const startPad = first.getDay()
    const days = DateHelper.daysInMonth(this.year, this.month)
    for (let i = 0; i < startPad; i++) {
      const c = new CalendarCell()
      c.empty = true
      c.dateKey = `pad_${i}`
      out.push(c)
    }
    for (let d = 1; d <= days; d++) {
      const c = new CalendarCell()
      c.day = d
      c.dateKey = DateHelper.dateKey(this.year, this.month, d)
      for (const r of this.records) {
        if (r.dateKey === c.dateKey) {
          if (this.filterEmotion.length === 0 || this.hasEmotion(r, this.filterEmotion)) {
            c.hasRecord = true
            c.dotColor = EmotionCatalog.colorOf(r.primaryEmotionId())
          }
          break
        }
      }
      out.push(c)
    }
    return out
  }

  private hasEmotion(r: MoodRecord, id: string): boolean {
    for (const e of r.emotions) {
      if (e === id) {
        return true
      }
    }
    return false
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m > 12) { m = 1; y++ } else if (m < 1) { m = 12; y-- }
    this.month = m
    this.year = y
    void this.load()
  }

  private async openDay(key: string): Promise<void> {
    const r = await MoodStore.findByDateKey(key)
    if (r !== undefined) {
      this.detailRecord = r
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private async deleteDetail(): Promise<void> {
    if (this.detailRecord === null) {
      return
    }
    await MoodStore.deleteRecord(this.detailRecord.id)
    this.detailRecord = null
    AppStorage.setOrCreate('tabBarHidden', false)
    void this.load()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Text('‹').fontSize(28).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.shiftMonth(-1) })
            Text(DateHelper.monthLabel(this.year, this.month))
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            Text('›').fontSize(28).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.shiftMonth(1) })
          }
          .width('100%')

          Text('按情绪筛选')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Scroll() {
            Row({ space: 8 }) {
              Text('全部')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.filterEmotion.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.filterEmotion.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.filterEmotion = ''
                  this.cells = this.buildCells()
                })
              ForEach(EmotionCatalog.all(), (e: EmotionDef) => {
                Text(e.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.filterEmotion === e.id ? Theme.colors().brandDeep : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.filterEmotion === e.id ? e.color : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.filterEmotion = e.id
                    this.cells = this.buildCells()
                  })
              }, (e: EmotionDef) => e.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.records.length === 0) {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.empty_gallery'))
                .width('100%')
                .height(160)
                .borderRadius(Theme.radius.lg)
                .objectFit(ImageFit.Cover)
              AppEmpty({
                title: '时光画廊还是空的',
                description: '在首页留下第一道月痕，日历上会出现情绪色点'
              })
            }
            .width('100%')
          } else {
            Grid() {
              ForEach(this.cells, (c: CalendarCell) => {
                GridItem() {
                  if (c.empty) {
                    Column().height(44)
                  } else {
                    Column({ space: 4 }) {
                      Text(`${c.day}`)
                        .fontSize(Theme.type.bodyS)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      if (c.hasRecord) {
                        Column()
                          .width(8)
                          .height(8)
                          .backgroundColor(c.dotColor)
                          .borderRadius(4)
                      }
                    }
                    .width('100%')
                    .height(44)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(c.hasRecord ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.sm)
                    .onClick((): void => { if (c.hasRecord) { void this.openDay(c.dateKey) } })
                  }
                }
              }, (c: CalendarCell) => c.dateKey)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.detailRecord !== null) {
        MoodDetailOverlay({
          record: this.detailRecord,
          onClose: (): void => {
            this.detailRecord = null
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onDelete: (): void => { void this.deleteDetail() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => { this.onReload() })
  }
}
