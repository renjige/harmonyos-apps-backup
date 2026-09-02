import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppRingChart } from '../design-system/AppChart'
import { PlanItem } from '../../services/ObservePlanService'

@Component
export struct HomeProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop planDone: number = 0
  @Prop planTotal: number = 3
  @Prop checkedIn: boolean = false
  @Prop progressPercent: number = 0
  @Prop greeting: string = ''
  @Prop suggestion: string = ''
  onContinue: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日观察进度')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      Row({ space: Theme.space.s4 }) {
        Column() {
          AppRingChart({
            title: '',
            percent: this.progressPercent
          })
        }
        .layoutWeight(1)

        Column({ space: Theme.space.s2 }) {
          if (this.greeting.length > 0) {
            Text(this.greeting)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          Text(`计划 ${this.planDone}/${this.planTotal} · 打卡 ${this.checkedIn ? '已完成' : '未完成'}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          if (this.suggestion.length > 0) {
            Text(this.suggestion)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .maxLines(2)
              .width('100%')
          }
          AppButton({
            label: '继续完成 →',
            variant: 'primary',
            onTap: (): void => this.onContinue()
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}

@Component
export struct HomeKpiRow {
  @Prop totalRecords: number = 0
  @Prop planDone: number = 0
  @Prop favoriteCount: number = 0
  @Prop streakDays: number = 0

  build() {
    Row({ space: Theme.space.s2 }) {
      Column() {
        this.KpiCell('记录', `${this.totalRecords}`)
      }.layoutWeight(1)
      Column() {
        this.KpiCell('完成', `${this.planDone}`)
      }.layoutWeight(1)
      Column() {
        this.KpiCell('收藏', `${this.favoriteCount}`)
      }.layoutWeight(1)
      Column() {
        this.KpiCell('连续', `${this.streakDays}天`)
      }.layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  KpiCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct HomeQuickActions {
  onNewRecord: () => void = () => {}
  onOpenRecords: () => void = () => {}
  onOpenAtlas: () => void = () => {}
  onCheckIn: () => void = () => {}
  onOpenGrowth: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('快捷操作')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({ label: '新建', variant: 'primary', onTap: (): void => this.onNewRecord() })
        }.layoutWeight(1)
        Column() {
          AppButton({ label: '记录', variant: 'secondary', onTap: (): void => this.onOpenRecords() })
        }.layoutWeight(1)
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({ label: '图鉴', variant: 'secondary', onTap: (): void => this.onOpenAtlas() })
        }.layoutWeight(1)
        Column() {
          AppButton({ label: '打卡', variant: 'secondary', onTap: (): void => this.onCheckIn() })
        }.layoutWeight(1)
      }
      .width('100%')
      AppButton({
        label: '查看成长与成就',
        variant: 'ghost',
        onTap: (): void => this.onOpenGrowth()
      })
    }
    .width('100%')
  }
}

@Component
export struct HomeDailyPlanStrip {
  @Prop items: PlanItem[] = []
  onToggle: (id: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('今日计划')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.items, (item: PlanItem) => {
        Row({ space: Theme.space.s2 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: item.done })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((): void => { this.onToggle(item.id) })
          Text(item.label)
            .fontSize(Theme.type.bodyS)
            .fontColor(item.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
            .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
            .layoutWeight(1)
        }
        .width('100%')
      }, (item: PlanItem) => `${item.id}-${item.done}`)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
