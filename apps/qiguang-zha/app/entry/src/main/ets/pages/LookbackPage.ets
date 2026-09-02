import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { QgDateUtil, QgLookbackItem, QgStats, QgTimelineRow } from '../models/QgModels'
import { QgStore } from '../services/QgStore'
import { QgDetailNav } from '../services/QgDetailNav'
import { QgMedia } from '../services/QgMedia'

@Component
export struct LookbackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('qgDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State face: number = 0
  @State rows: QgTimelineRow[] = []
  @State look: QgLookbackItem = new QgLookbackItem()
  @State stats: QgStats = new QgStats()
  @State monthLabels: string[] = []
  @State monthValues: number[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.rows = await QgStore.buildTimeline()
    this.look = await QgStore.buildLookback()
    this.stats = await QgStore.computeStats()
    const months = QgDateUtil.lastNMonths(6)
    const counts = await QgStore.monthCounts(6)
    const labels: string[] = []
    const values: number[] = []
    for (let i = months.length - 1; i >= 0; i--) {
      labels.push(months[i].substring(5))
      values.push(counts[i])
    }
    this.monthLabels = labels
    this.monthValues = values
  }

  private openRow(r: QgTimelineRow): void {
    if (r.kind === 'clip') {
      QgDetailNav.openClip(r.id)
      return
    }
    QgDetailNav.openEntry(r.id)
  }

  private barHeight(idx: number): number {
    let max = 1
    for (const v of this.monthValues) {
      if (v > max) {
        max = v
      }
    }
    if (idx < 0 || idx >= this.monthValues.length) {
      return 8
    }
    return 8 + Math.floor(90 * this.monthValues[idx] / max)
  }

  build() {
    Column() {
      Text('回望')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s3 })
      Row({ space: 8 }) {
        this.faceChip(0, '长廊')
        this.faceChip(1, '智慧回望')
        this.faceChip(2, '数据')
      }
      .padding({ left: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      if (this.face === 0) {
        this.timelineFace()
      } else if (this.face === 1) {
        this.lookFace()
      } else {
        this.statsFace()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  faceChip(idx: number, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.face === idx ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.face === idx ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.face = idx })
  }

  @Builder
  timelineFace() {
    if (this.rows.length === 0) {
      AppEmpty({ title: '时间长廊还是空的', description: '有记录后会按月份铺开' })
    } else {
      List() {
        ForEach(this.rows, (r: QgTimelineRow) => {
          ListItem() {
            Row({ space: 12 }) {
              Column() {
                Text(r.dateKey.substring(8))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                Text(QgDateUtil.displayMonthYear(r.dateKey))
                  .fontSize(10)
                  .fontColor(Theme.colors().textTertiary)
              }
              .width(64)
              Column({ space: 4 }) {
                Text(r.kind === 'clip' ? '光影' : '札记')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                Text(r.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(2)
                  .width('100%')
              }
              .layoutWeight(1)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 10 })
            .onClick((): void => { this.openRow(r) })
          }
        }, (r: QgTimelineRow) => `${r.kind}_${r.id}`)
      }
      .layoutWeight(1)
      .padding({ bottom: this.bottomInset })
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  lookFace() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Image(QgMedia.corridorHero())
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Text('按本机日期回看，不使用生成式能力。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Column({ space: 8 }) {
          Text(this.look.title)
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.look.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .width('100%')
        .onClick((): void => {
          if (this.look.sourceKind === 'clip') {
            QgDetailNav.openClip(this.look.sourceId)
          } else if (this.look.sourceId.length > 0) {
            QgDetailNav.openEntry(this.look.sourceId)
          }
        })
        Text('打开年度档案')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { QgDetailNav.openYear() })
        Column().height(this.bottomInset)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  statsFace() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: 8 }) {
          this.num('札记', `${this.stats.entryCount}`)
          this.num('光影', `${this.stats.clipCount}`)
          this.num('连续', `${this.stats.streakDays}天`)
        }
        Column({ space: 8 }) {
          Text('近六月记录')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(this.monthLabels, (lb: string, idx: number) => {
              Column({ space: 4 }) {
                Column()
                  .width('100%')
                  .height(this.barHeight(idx))
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(4)
                Text(lb)
                  .fontSize(10)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.End)
              .height(120)
            }, (lb: string, idx: number) => `${lb}_${idx}`)
          }
          .width('100%')
          .height(140)
          .alignItems(VerticalAlign.Bottom)
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        Column().height(this.bottomInset)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  num(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
