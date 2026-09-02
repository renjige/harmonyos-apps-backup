import { Theme } from '../design-system/Theme'
import { AppListRow } from '../design-system/AppListRow'
import { QualityLocalStore } from '../../services/QualityLocalStore'
import { QualityNav } from '../../services/QualityNav'

@Component
export struct MineStatsRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('qualityTick') tick: number = 0

  private monthInspect(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().monthInspect
  }

  private monthFound(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().monthFound
  }

  private monthClosed(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().monthClosed
  }

  build() {
    Row({ space: 8 }) {
      this.monthCell('本月巡查', this.monthInspect())
      this.monthCell('发现问题', this.monthFound())
      this.monthCell('已闭环', this.monthClosed())
    }
    .width('100%')
  }

  @Builder
  monthCell(label: string, value: number) {
    Column({ space: 4 }) {
      Text(`${value}`)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandDeep)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(14)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(14)
  }
}

@Component
export struct MineCountsBlock {
  @StorageLink('qualityTick') tick: number = 0
  onOpenInspect: () => void = () => {}
  onOpenIssues: (filter: string) => void = (_f: string) => {}

  private projectCount(): number {
    const _keep = this.tick
    return QualityLocalStore.snapshot().projects.length
  }

  private inspectionCount(): number {
    const _keep = this.tick
    return QualityLocalStore.snapshot().inspections.length
  }

  private issueCount(): number {
    const _keep = this.tick
    return QualityLocalStore.snapshot().issues.length
  }

  build() {
    Column() {
      AppListRow({
        title: '我的项目',
        subtitle: `${this.projectCount()} 个项目`,
        onTap: () => QualityNav.open('projects')
      })
      AppListRow({
        title: '我的巡查',
        subtitle: `${this.inspectionCount()} 条记录`,
        onTap: () => this.onOpenInspect()
      })
      AppListRow({
        title: '我的问题',
        subtitle: `${this.issueCount()} 条问题`,
        onTap: () => this.onOpenIssues('全部')
      })
      AppListRow({
        title: '我的整改',
        subtitle: '查看整改中的问题',
        showDivider: false,
        onTap: () => this.onOpenIssues('整改中')
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
  }
}
