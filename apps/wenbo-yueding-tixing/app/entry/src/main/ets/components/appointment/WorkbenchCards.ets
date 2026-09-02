import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { GapSlot, NextHint } from '../../models/AppointmentModels'

@Component
export struct NextHintCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop hint: NextHint = new NextHint()
  onTap: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Text(this.hint.hasNext ? '下一件约定' : '今日节奏')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
      Text(this.hint.hasNext ? this.hint.title : '今天没有未完成约定')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.hint.countdown)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct ToolEntry {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  onTap: () => void = () => {}

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct ToolGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop missedCount: number = 0
  onBrief: () => void = () => {}
  onSlots: () => void = () => {}
  onOverdue: () => void = () => {}
  onImport: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text('今日简报')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('出发时间与一键完成')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick((): void => { this.onBrief() })
        Column({ space: 4 }) {
          Text('找空档')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('扫描 7 天空闲时段')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick((): void => { this.onSlots() })
      }
      .width('100%')
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text(this.missedCount > 0 ? `逾期台 · ${this.missedCount}` : '逾期台')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('过期改期或批量处理')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick((): void => { this.onOverdue() })
        Column({ space: 4 }) {
          Text('粘贴导入')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('多行文本一次创建')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick((): void => { this.onImport() })
      }
      .width('100%')
    }
    .width('100%')
  }
}

@Component
export struct ProgressHeroCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop doneCount: number = 0
  @Prop totalCount: number = 0
  @Prop nextTitle: string = ''
  @Prop nextTime: string = ''
  onContinue: () => void = () => {}

  private percent(): number {
    if (this.totalCount <= 0) {
      return 0
    }
    const p = Math.floor((this.doneCount / this.totalCount) * 100)
    return p > 100 ? 100 : p
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('今日守约进度')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
        Blank()
        Text(`${this.percent()}%`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      Progress({ value: this.doneCount, total: this.totalCount > 0 ? this.totalCount : 1, type: ProgressType.Linear })
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .width('100%')
      Text(`已完成 ${this.doneCount} / 待办 ${this.totalCount}`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.nextTitle.length > 0) {
        Text(`下一件：${this.nextTime} ${this.nextTitle} →`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
          .onClick((): void => { this.onContinue() })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
  }
}

@Component
export struct DataQuadCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct QuickActionChip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  onTap: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.onTap() })
  }
}

@Component
export struct ActivityFeedRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop action: string = ''
  @Prop title: string = ''
  @Prop timeLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: 8 }) {
      Column({ space: 2 }) {
        Text(`${this.action}「${this.title}」`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.timeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct PlanSummaryCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop progressText: string = ''
  @Prop percent: number = 0
  onTap: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Progress({ value: this.percent, total: 100, type: ProgressType.Linear })
        .color(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .width('100%')
      Text(this.progressText)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct GapHint {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop slot: GapSlot = new GapSlot()
  onTap: () => void = () => {}

  build() {
    Text(this.slot.label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      .width('100%')
      .padding(12)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      .onClick((): void => { this.onTap() })
  }
}
