import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import {
  PersonalBest, TypeShare, WeeklySnapshot, WorkoutRecord, WorkoutTypeOption
} from '../models/WorkoutModels'
import { DateHelper } from '../services/DateHelper'
import { WorkoutStore } from '../services/WorkoutStore'
import { InsightService } from '../services/InsightService'
import { StatsService } from '../services/StatsService'

@Component
export struct TracePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 88
  onOpenWorkout: (record: WorkoutRecord) => void = () => {}
  onOpenSnapshot: (snap: WeeklySnapshot) => void = () => {}
  onManual: () => void = () => {}
  @State traces: WorkoutRecord[] = []
  @State filterKey: string = 'all'
  @State shares: TypeShare[] = []
  @State bests: PersonalBest[] = []
  @State snapshots: WeeklySnapshot[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onPageShow(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await WorkoutStore.loadAll()
    const filtered: WorkoutRecord[] = []
    for (const r of all) {
      if (this.filterKey === 'all' || r.typeKey === this.filterKey) {
        filtered.push(r)
      }
    }
    const cap: WorkoutRecord[] = []
    for (let i = 0; i < filtered.length && i < 16; i++) {
      cap.push(filtered[i])
    }
    this.traces = cap
    this.shares = await StatsService.typeShares()
    this.bests = await StatsService.personalBests()
    this.snapshots = await InsightService.recentSnapshots(8)
  }

  private applyFilter(key: string): void {
    this.filterKey = key
    void this.reload()
  }

  @Builder
  FilterChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filterKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.filterKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.applyFilter(key) })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('留痕')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('把每一次运动串成轨迹。不是系统健康数据的复刻，而是你自己写下的记忆线。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        AppButton({
          label: '补记一场运动',
          variant: 'primary',
          onTap: (): void => { this.onManual() }
        })

        Text('时间线')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          this.FilterChip('全部', 'all')
          ForEach(WorkoutTypeOption.all(), (opt: WorkoutTypeOption) => {
            this.FilterChip(opt.label, opt.key)
          }, (opt: WorkoutTypeOption) => opt.key)
        }
        .width('100%')

        if (this.traces.length === 0) {
          AppEmpty({
            title: '时间线还是空的',
            description: '计时开始，或补记过去 90 天内的一场运动',
            actionLabel: '去补记',
            onAction: (): void => { this.onManual() }
          })
        } else {
          Column({ space: 0 }) {
            ForEach(this.traces, (rec: WorkoutRecord) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 0 }) {
                  Column()
                    .width(12)
                    .height(12)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(6)
                  Column()
                    .width(2)
                    .layoutWeight(1)
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                }
                .width(16)
                .height(64)
                Column({ space: 2 }) {
                  Text(`${WorkoutTypeOption.labelFor(rec.typeKey)} · ${rec.durationMinutes()} 分钟`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${DateHelper.displayDate(rec.dateKey)}${rec.note.length > 0 ? ' · ' + rec.note : ''}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
              .onClick((): void => { this.onOpenWorkout(rec) })
            }, (rec: WorkoutRecord) => rec.id)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        if (this.shares.length > 0) {
          Text('类型分布')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Column({ space: Theme.space.s2 }) {
            ForEach(this.shares, (s: TypeShare) => {
              Row() {
                Text(s.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                  .width(64)
                Text(`${s.count} 次 · ${s.minutes} 分钟`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
              }
              .width('100%')
            }, (s: TypeShare) => s.typeKey)
          }
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        if (this.bests.length > 0) {
          Text('个人纪录')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Column({ space: Theme.space.s2 }) {
            ForEach(this.bests, (b: PersonalBest) => {
              Row() {
                Text(b.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                Blank()
                Text(`${b.durationSeconds >= 60 ? Math.round(b.durationSeconds / 60) : 1} 分钟 · ${DateHelper.displayShort(b.dateKey)}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textPrimary)
              }
              .width('100%')
              .onClick((): void => {
                void WorkoutStore.findById(b.workoutId).then((rec: WorkoutRecord | undefined): void => {
                  if (rec !== undefined) {
                    this.onOpenWorkout(rec)
                  }
                })
              })
            }, (b: PersonalBest) => b.typeKey)
          }
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }

        Text('周报印记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('点进一周，写下复盘。这是第二条完整闭环，不是只读统计。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')

        Column({ space: Theme.space.s3 }) {
          ForEach(this.snapshots, (snap: WeeklySnapshot) => {
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({
                  name: snap.pinned === 1 ? 'check' : 'chart',
                  iconSize: Theme.icon.md,
                  color: Theme.colors().brandPrimary
                })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.md)
              Column({ space: 2 }) {
                Text(snap.weekLabel)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(`${snap.count} 次 · ${snap.totalMinutes} 分钟${snap.reflection.length > 0 ? ' · 已复盘' : ''}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { this.onOpenSnapshot(snap) })
          }, (snap: WeeklySnapshot) => snap.id)
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: this.bottomInset
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
