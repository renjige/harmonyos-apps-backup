import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { MonthRhythmGrid } from '../components/sport/MonthRhythmGrid'
import { SportRecord } from '../models/SportRecord'
import { RecordStore } from '../services/RecordStore'
import { StatisticsUtil, CalendarCell, MonthDayMap } from '../services/StatisticsUtil'
import { CompareDelta, TransformReportService } from '../services/TransformReportService'
import { SportDetailNav } from '../services/SportDetailNav'

@Component
export struct ComparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State records: SportRecord[] = []
  @State leftIndex: number = 0
  @State rightIndex: number = 0
  @State heatmap: MonthDayMap[] = []
  @State cells: CalendarCell[] = []
  @State delta: CompareDelta = new CompareDelta()
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.records = await RecordStore.loadAll()
    this.heatmap = StatisticsUtil.monthActivityMap(this.records, this.year)
    this.cells = StatisticsUtil.monthCells(this.records, this.year, this.month)
    if (this.records.length >= 2) {
      this.leftIndex = this.records.length - 1
      this.rightIndex = 0
    }
    this.refreshDelta()
  }

  private refreshDelta(): void {
    this.delta = TransformReportService.delta(this.leftRecord(), this.rightRecord())
  }

  private leftRecord(): SportRecord | undefined {
    if (this.records.length === 0 || this.leftIndex < 0 || this.leftIndex >= this.records.length) {
      return undefined
    }
    return this.records[this.leftIndex]
  }

  private rightRecord(): SportRecord | undefined {
    if (this.records.length === 0 || this.rightIndex < 0 || this.rightIndex >= this.records.length) {
      return undefined
    }
    return this.records[this.rightIndex]
  }

  private shiftLeft(delta: number): void {
    if (this.records.length === 0) {
      return
    }
    let next = this.leftIndex + delta
    if (next < 0) {
      next = this.records.length - 1
    }
    if (next >= this.records.length) {
      next = 0
    }
    this.leftIndex = next
    this.refreshDelta()
  }

  private shiftRight(delta: number): void {
    if (this.records.length === 0) {
      return
    }
    let next = this.rightIndex + delta
    if (next < 0) {
      next = this.records.length - 1
    }
    if (next >= this.records.length) {
      next = 0
    }
    this.rightIndex = next
    this.refreshDelta()
  }

  private openDay(dateKey: string): void {
    for (const it of this.records) {
      if (it.date === dateKey) {
        SportDetailNav.openDetail(it.id)
        return
      }
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('蜕变工作台')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('对照两张定格，算出体重/距离/时长差值，再生成可执行报告。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        if (this.records.length < 2) {
          AppEmpty({
            title: '至少需要 2 条记录才能对照',
            description: '对照不是看图，而是算出两次运动之间的具体变化',
            actionLabel: '',
            onAction: (): void => {}
          })
        } else {
          Row({ space: Theme.space.s3 }) {
            this.ComparePane('Before', this.leftRecord(), (): void => { this.shiftLeft(-1) }, (): void => { this.shiftLeft(1) })
            this.ComparePane('After', this.rightRecord(), (): void => { this.shiftRight(-1) }, (): void => { this.shiftRight(1) })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text(`间隔 ${this.delta.daysBetween} 天`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`体重 ${this.delta.weightText}  ·  距离 ${this.delta.distanceText}  ·  时长 ${this.delta.durationText}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          AppButton({
            label: '根据全部记录生成蜕变报告',
            variant: 'primary',
            onTap: (): void => { SportDetailNav.openReport() }
          })
        }

        MonthRhythmGrid({
          title: `${this.year}年${this.month}月节奏日历`,
          cells: this.cells,
          onSelectDay: (key: string): void => { this.openDay(key) }
        })

        Text(`${this.year} 年活跃度`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.heatmap, (item: MonthDayMap) => {
            Column({ space: 4 }) {
              Text(`${item.month}月`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Column()
                .width(28)
                .height(28)
                .borderRadius(6)
                .backgroundColor(this.heatColor(item.activeDays))
            }
            .margin({ right: 10, bottom: 10 })
            .onClick((): void => {
              this.month = item.month
              this.cells = StatisticsUtil.monthCells(this.records, this.year, this.month)
            })
          }, (item: MonthDayMap) => `${item.month}`)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onVisibleAreaChange([0.0, 1.0], (_expanding: boolean, ratio: number): void => {
      if (ratio > 0) {
        void this.reload()
      }
    })
  }

  private heatColor(activeDays: number): string {
    const level = StatisticsUtil.heatLevel(activeDays)
    if (level === 0) {
      return Theme.colors().surfaceSubtle
    }
    if (level === 1) {
      return 'rgba(255,107,53,0.25)'
    }
    if (level === 2) {
      return 'rgba(255,107,53,0.45)'
    }
    if (level === 3) {
      return 'rgba(255,107,53,0.65)'
    }
    return '#FF6B35'
  }

  @Builder
  ComparePane(label: string, record: SportRecord | undefined, onPrev: () => void, onNext: () => void) {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      if (record !== undefined) {
        if (record.coverPhoto().length > 0) {
          Image(record.coverPhoto())
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        } else {
          Image($r('app.media.hero_home'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        Text(record.displayTitle())
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
        Text(record.date)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        if (record.primaryMetric().length > 0) {
          Text(record.primaryMetric())
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
      }
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(onPrev)
        Text('切换')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .onClick(onNext)
      }
      .width('100%')
    }
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .layoutWeight(1)
  }
}
