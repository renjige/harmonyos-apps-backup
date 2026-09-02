import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { StatChip } from './StatChip'
import { GrowthStats } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'
import { ReviewService } from '../../services/ReviewService'

@Component
export struct GrowthDashboardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State stats: GrowthStats = new GrowthStats()
  @State weekText: string = ''
  @State monthText: string = ''
  onClose: () => void = () => {}
  onOpenReview: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.stats = await ZhixingStore.growthStats()
    this.weekText = await ReviewService.weekSummary()
    this.monthText = await ReviewService.monthSummary()
  }

  build() {
    Column() {
      AppNavBar({ title: '成长仪表盘', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: 8 }) {
            StatChip({ label: '知识总量', value: `${this.stats.knowledgeTotal}` })
            StatChip({ label: '收藏', value: `${this.stats.favoriteTotal}` })
          }
          .width('100%')
          Row({ space: 8 }) {
            StatChip({ label: '完成计划', value: `${this.stats.donePlans}` })
            StatChip({ label: '最长连续', value: `${this.stats.maxStreak}天` })
          }
          .width('100%')
          Row({ space: 8 }) {
            StatChip({ label: '本周新增', value: `${this.stats.weekKnowledge}` })
            StatChip({ label: '本月打卡', value: `${this.stats.monthChecks}` })
          }
          .width('100%')
          Column({ space: 6 }) {
            Text('本周回顾')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.weekText)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          Column({ space: 6 }) {
            Text('本月回顾')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.monthText)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onOpenReview() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
