import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FieldRecord } from '../../models/FieldModels'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { DateHelper } from '../../services/DateHelper'
import { AtlasQuickStrip } from './AtlasQuickStrip'

@Component
export struct DailyWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordCount: number = 0
  @Prop favCount: number = 0
  @Prop streak: number = 0
  @Prop checkinCount: number = 0
  @Prop questDone: number = 0
  @Prop ritualDone: number = 0
  @Prop ritualTotal: number = 6
  @Prop checkinToday: boolean = false
  @Prop planTitle: string = ''
  @Prop planId: string = ''
  @Prop planDone: number = 0
  @Prop planTarget: number = 0
  @Prop weekLine: string = ''
  @Prop dateLabel: string = ''
  @Prop weekdayLabel: string = ''
  @Prop showTitle: boolean = false
  @Prop recent: FieldRecord[] = []
  onWrite: () => void = () => {}
  onCheckin: () => void = () => {}
  onPlan: () => void = () => {}
  onFolio: () => void = () => {}

  private ritualPct(): number {
    if (this.ritualTotal <= 0) {
      return 0
    }
    const v = (this.ritualDone / this.ritualTotal) * 100
    if (v > 100) {
      return 100
    }
    return v
  }

  private planPct(): number {
    if (this.planTarget <= 0) {
      return 0
    }
    const v = (this.planDone / this.planTarget) * 100
    if (v > 100) {
      return 100
    }
    return v
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      if (this.showTitle) {
        Column({ space: Theme.space.s1 }) {
          Text('格物集')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(`${this.dateLabel} · ${this.weekdayLabel}`)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('图鉴格物 · 非简单记事')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Column({ space: Theme.space.s3 }) {
        Text('今日功课')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.Center }) {
            Progress({ value: this.ritualPct(), total: 100, type: ProgressType.Ring })
              .width(88)
              .height(88)
              .color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
            Text(`${this.ritualDone}/${this.ritualTotal}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .width(88)
          .height(88)
          Column({ space: Theme.space.s2 }) {
            Text(`探索任务 ${this.questDone}/5 · 物候${this.checkinToday ? '已打卡' : '未打卡'}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.weekLine.length > 0 ? this.weekLine : '完成阅读、小测或观察后，进度会即时更新')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.checkinToday ? '继续完成今日一物 →' : '可先物候打卡，再写下观察')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      AtlasQuickStrip()

      Text('快捷操作')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.QuickChip('观察札', (): void => { this.onWrite() })
        this.QuickChip('物候打卡', (): void => { this.onCheckin() })
        this.QuickChip('新建功课', (): void => { this.onPlan() })
        this.QuickChip('打开图鉴', (): void => { this.onFolio() })
      }
      .width('100%')

      if (this.planTitle.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('进行中的功课')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.planTitle)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Progress({ value: this.planPct(), total: 100, type: ProgressType.Linear })
            .width('100%')
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
          Text(`已完成 ${this.planDone} / ${this.planTarget}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => {
          if (this.planId.length > 0) {
            GewuDetailNav.openPractice('planView', this.planId)
          } else {
            this.onPlan()
          }
        })
      }

      Column({ space: Theme.space.s2 }) {
        Text('最近观察札')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        if (this.recent.length === 0) {
          Text('还没有观察札。从图鉴选一物，按模板写下发现。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.recent, (r: FieldRecord) => {
            Row() {
              Column({ space: 2 }) {
                Text(r.title)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${DateHelper.displayShort(r.dateKey)} · ${r.atlasKind}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .onClick((): void => { GewuDetailNav.openRecord(r.id) })
          }, (r: FieldRecord) => r.id)
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
    }
    .width('100%')
  }

  @Builder
  QuickChip(label: string, tap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { tap() })
  }
}
