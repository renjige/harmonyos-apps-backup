import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppBarChart, BarChartItem } from '../design-system/AppChart'
import { FanMilestone } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'

/** 拾光页成长概览：类型分布 + 里程碑预览 + 本月小结 */
@Component
export struct FanMemoryOverview {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @State chartItems: BarChartItem[] = []
  @State milestones: FanMilestone[] = []
  @State recapLines: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const counts = FanMemoryStore.typeCounts()
    const items: BarChartItem[] = []
    for (let i = 0; i < counts.length; i++) {
      const row = new BarChartItem()
      row.label = counts[i].label
      row.value = counts[i].value
      items.push(row)
    }
    this.chartItems = items
    this.milestones = FanMemoryStore.milestones()
    this.recapLines = FanMemoryStore.monthlyRecapLines()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('球迷成长概览')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('完整报告')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => {
            CourtDetailNav.openFanDashboard()
          })
      }
      .width('100%')

      if (this.chartItems.length > 0) {
        AppBarChart({
          title: '记忆类型分布',
          items: this.chartItems
        })
      }

      Column({ space: Theme.space.s2 }) {
        Text('成长里程碑')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.milestones, (m: FanMilestone) => {
            Column({ space: 2 }) {
              Text(m.title)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(m.unlocked ? Theme.colors().success : Theme.colors().textPrimary)
              Text(m.progress)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(m.unlocked ? Theme.colors().successContainer : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          }, (m: FanMilestone) => m.id)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Column({ space: Theme.space.s1 }) {
        Text('本月小结')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.recapLines, (line: string, idx: number) => {
          Text(`· ${line}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }, (line: string, idx: number) => `recap_${idx}`)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      AppButton({
        label: '打开球迷成长报告',
        variant: 'secondary',
        onTap: (): void => {
          CourtDetailNav.openFanDashboard()
        }
      })
    }
    .width('100%')
  }
}
