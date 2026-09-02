import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { TimelineEvent } from '../../models/VitalityModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ProgressHeroCard {
  @Prop percent: number = 0
  @Prop checkedIn: boolean = false
  @Prop rxDone: number = 0
  @Prop rxTotal: number = 0
  @Prop weekDone: number = 0
  @Prop weekGoal: number = 5

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日活力进度')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`${this.percent}%`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')

      Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height(12)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
        Column()
          .width(`${this.percent}%`)
          .height(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')

      Text(this.summaryLine())
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 16,
      color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(255,107,53,0.1)',
      offsetY: 4
    })
  }

  private summaryLine(): string {
    const check = this.checkedIn ? '已打卡' : '未打卡'
    const rx = `${this.rxDone}/${this.rxTotal} 处方`
    const wx = `${this.weekDone}/${this.weekGoal} 本周`
    return `${check} · ${rx} · ${wx}`
  }
}

@Component
export struct CheckInCalendarStrip {
  @Prop monthKeys: string[] = []
  @Prop checkedKeys: string[] = []

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('本月打卡')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.monthKeys, (k: string) => {
          Column()
            .width(10)
            .height(10)
            .margin({ right: 4, bottom: 4 })
            .backgroundColor(this.isChecked(k) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
        }, (k: string) => k)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  private isChecked(key: string): boolean {
    for (const k of this.checkedKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }
}

@Component
export struct WorkbenchStatGrid {
  @Prop totalRecords: number = 0
  @Prop monthRecords: number = 0
  @Prop rxPercent: number = 0
  @Prop favoriteCount: number = 0

  build() {
    Row({ space: Theme.space.s2 }) {
      Column({ space: 4 }) {
        Text(`${this.totalRecords}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text('总纪行')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .shadow({
        radius: 12,
        color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(10,37,64,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      Column({ space: 4 }) {
        Text(`${this.monthRecords}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().success)
        Text('本月')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .shadow({
        radius: 12,
        color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(10,37,64,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      Column({ space: 4 }) {
        Text(`${this.rxPercent}%`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().info)
        Text('处方完成')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .shadow({
        radius: 12,
        color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(10,37,64,0.05)',
        offsetX: 0,
        offsetY: 2
      })

      Column({ space: 4 }) {
        Text(`${this.favoriteCount}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().warning)
        Text('收藏')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .shadow({
        radius: 12,
        color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(10,37,64,0.05)',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
  }
}

@Component
export struct QuickActionRow {
  onCheckIn: () => void = () => {}
  onNote: () => void = () => {}
  onPlan: () => void = () => {}
  onAction: () => void = () => {}
  onBreathing: () => void = () => {}
  onSearch: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      this.chip('记录', 'check', (): void => this.onCheckIn())
      this.chip('笔记', 'add', (): void => this.onNote())
      this.chip('计划', 'chart', (): void => this.onPlan())
      this.chip('行动', 'biz', (): void => this.onAction())
      this.chip('呼吸', 'refresh', (): void => this.onBreathing())
      this.chip('搜索', 'search', (): void => this.onSearch())
    }
    .width('100%')
  }

  @Builder
  chip(label: string, icon: AppIconName, tap: () => void) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .onClick((): void => tap())
  }
}

@Component
export struct RecentTimelineStrip {
  @Prop events: TimelineEvent[] = []
  onTapEvent: (event: TimelineEvent) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('最近动态')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      if (this.events.length === 0) {
        Column({ space: Theme.space.s2 }) {
          Image($r('app.media.empty_calm'))
            .width('100%')
            .height(88)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          Text('完成首次记录后，动态会在这里串联展示')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
      } else {
        ForEach(this.events, (e: TimelineEvent) => {
          Row({ space: Theme.space.s3 }) {
            Column()
              .width(8)
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .margin({ top: 6 })
            Column({ space: 2 }) {
              Text(e.title)
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`${DateHelper.displayShort(e.dateKey)} · ${e.summary}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onClick((): void => this.onTapEvent(e))
        }, (e: TimelineEvent) => e.id)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
export struct SectionHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
