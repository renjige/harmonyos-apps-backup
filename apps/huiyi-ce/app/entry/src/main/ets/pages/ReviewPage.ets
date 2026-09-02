import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MemoryListCard } from '../components/memory/MemoryListCard'
import { DayCell, MemoryRecord, WeekDigest } from '../models/MemoryModels'
import { MemoryStatsService } from '../services/MemoryStatsService'
import { MemoryStore } from '../services/MemoryStore'
import { ExportService } from '../services/ExportService'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1
  @State cells: DayCell[] = []
  @State selectedKey: string = MemoryStore.todayKey()
  @State dayItems: MemoryRecord[] = []
  @State dueItems: MemoryRecord[] = []
  @State randomItem: MemoryRecord = new MemoryRecord()
  @State hasRandom: boolean = false
  @State digest: WeekDigest = new WeekDigest()
  @State toastText: string = ''
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const active = await MemoryStore.loadActive()
    this.cells = MemoryStore.monthGrid(this.year, this.month, MemoryStore.filledDateKeys(active))
    this.dueItems = await MemoryStore.loadDueReview()
    this.digest = await MemoryStatsService.weekDigest()
    this.dayItems = await MemoryStore.byDateKey(this.selectedKey)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async pickDay(cell: DayCell): Promise<void> {
    if (cell.isPad || cell.dateKey.length === 0) {
      return
    }
    this.selectedKey = cell.dateKey
    this.dayItems = await MemoryStore.byDateKey(cell.dateKey)
  }

  private async drawRandom(): Promise<void> {
    const one = await MemoryStore.randomOne()
    if (one === undefined) {
      this.hasRandom = false
      this.showToast('还没有可抽的记忆')
      return
    }
    this.randomItem = one
    this.hasRandom = true
  }

  private async markRandom(): Promise<void> {
    if (!this.hasRandom) {
      return
    }
    await MemoryStore.markReviewed(this.randomItem.id)
    await this.load()
    this.showToast('已记入温习')
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y = y - 1
    }
    if (m > 12) {
      m = 1
      y = y + 1
    }
    this.month = m
    this.year = y
    void this.load()
  }

  private async copyDigest(): Promise<void> {
    const ok = await ExportService.copyText(this.digest.summaryText())
    this.showToast(ok ? '本周回顾已复制' : '复制失败')
  }

  build() {
    Stack() {
      Column() {
        Text('记忆回顾')
          .fontSize(Theme.type.titleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s2
          })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_paper_light'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
              Column() {
                Blank()
                Text('按日回看，随机抽忆，把旧记忆温习一遍')
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
                  .width('100%')
                  .padding(Theme.space.s4)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.78)', 1]]
                  })
              }
              .width('100%')
              .height(120)
            }
            .width('100%')
            .height(120)
            .borderRadius(Theme.radius.md)
            .clip(true)

            AppCard() {
              Column({ space: Theme.space.s3 }) {
                Text(this.digest.summaryText())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                AppButton({
                  label: '复制本周回顾',
                  variant: 'secondary',
                  onTap: (): void => { void this.copyDigest() }
                })
              }
            }

            AppButton({
              label: '随机抽忆',
              onTap: (): void => { void this.drawRandom() }
            })
            if (this.hasRandom) {
              Column({ space: Theme.space.s2 }) {
                Text(this.randomItem.previewLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Column({ space: Theme.space.s2 }) {
                  AppButton({
                    label: '打开详情',
                    variant: 'secondary',
                    onTap: (): void => { this.onOpenDetail(this.randomItem.id) }
                  })
                  AppButton({
                    label: '记入温习',
                    onTap: (): void => { void this.markRandom() }
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }

            Text(`待温习 · ${this.dueItems.length}`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.dueItems.length === 0) {
              Text('七天内温习过的记忆会离开队列')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              ForEach(this.dueItems, (it: MemoryRecord) => {
                MemoryListCard({
                  item: it,
                  onOpen: (): void => { this.onOpenDetail(it.id) }
                })
              }, (it: MemoryRecord) => `due_${it.id}`)
            }

            Row() {
              Text('上一月')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { this.shiftMonth(-1) })
              Blank()
              Text(`${this.year}年${this.month}月`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('下一月')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { this.shiftMonth(1) })
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.weekLabels(), (w: string) => {
                Text(w)
                  .width('14%')
                  .fontSize(Theme.type.overline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 4, bottom: 4 })
              }, (w: string) => w)
              ForEach(this.cells, (c: DayCell) => {
                Column() {
                  if (!c.isPad) {
                    Text(`${c.dayNum}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(c.isToday ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  }
                }
                .width('14%')
                .height(36)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.cellBg(c))
                .borderRadius(Theme.radius.sm)
                .margin({ bottom: 4 })
                .onClick((): void => { void this.pickDay(c) })
              }, (c: DayCell) => c.dateKey)
            }
            .width('100%')

            Text(`${this.selectedKey} · ${this.dayItems.length} 条`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.dayItems.length === 0) {
              AppEmpty({
                title: '这一天没有记忆',
                description: '点有圆点的日期，查看当天写下的内容'
              })
            } else {
              ForEach(this.dayItems, (it: MemoryRecord) => {
                MemoryListCard({
                  item: it,
                  onOpen: (): void => { this.onOpenDetail(it.id) }
                })
              }, (it: MemoryRecord) => `day_${it.id}`)
            }
          }
          .width('100%')
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
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '28%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
  }

  private weekLabels(): string[] {
    const labels: string[] = []
    labels.push('一')
    labels.push('二')
    labels.push('三')
    labels.push('四')
    labels.push('五')
    labels.push('六')
    labels.push('日')
    return labels
  }

  private cellBg(c: DayCell): string {
    if (c.isPad) {
      return 'transparent'
    }
    if (c.dateKey === this.selectedKey) {
      return Theme.colors().brandPrimary
    }
    if (c.hasEntry) {
      return Theme.colors().brandPrimaryContainer
    }
    return 'transparent'
  }
}
