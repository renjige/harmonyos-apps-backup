import { Theme } from '../design-system/Theme'
import { QualityDates } from '../../models/QualityModels'
import { QualityLocalStore } from '../../services/QualityLocalStore'

@Component
export struct TodayStatsCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('qualityTick') tick: number = 0

  private todayInspect(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().todayInspect
  }

  private foundToday(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().foundToday
  }

  private rectifying(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().rectifying
  }

  private closedCount(): number {
    const _keep = this.tick
    return QualityLocalStore.stats().closed
  }

  build() {
    Column({ space: 14 }) {
      Text('今日统计')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        this.metricCell('今日巡查', this.todayInspect())
        this.metricCell('发现问题', this.foundToday())
        this.metricCell('整改中', this.rectifying())
        this.metricCell('已闭环', this.closedCount())
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.05)', offsetY: 2, offsetX: 0 })
  }

  @Builder
  metricCell(label: string, value: number) {
    Column({ space: 4 }) {
      Text(QualityDates.pad(value))
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandDeep)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .width('48%')
    .alignItems(HorizontalAlign.Start)
    .padding({ bottom: 10 })
  }
}
