import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { InspirationBizService } from '../services/InspirationBizService'
import { GrowthStore } from '../services/GrowthStore'
import { GrowthService } from '../services/GrowthService'
import { GrowthStatsService, GrowthStatsSnapshot, WeekDayCount } from '../services/GrowthStatsService'
import { BoardPinService } from '../services/BoardPinService'
import { AuthService } from '../services/AuthService'

@Component
export struct GrowthStatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('growthEpoch') growthEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State snap: GrowthStatsSnapshot = new GrowthStatsSnapshot()
  @State bars: BarChartItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.loading = false
      return
    }
    const ins = await InspirationBizService.loadInspirations(this.currentUsername)
    const fav = await InspirationBizService.loadFavorites(this.currentUsername)
    const boards = await BoardPinService.listOwnBoards(this.currentUsername)
    const plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
    const growth = await GrowthStore.load(this.currentUsername)
    const today = GrowthService.todayIso()
    this.snap = GrowthStatsService.snapshot(
      ins, fav, boards, plans, growth, GrowthService.hasCheckIn(growth, today)
    )
    const days: WeekDayCount[] = GrowthStatsService.weekBars(ins)
    const mapped: BarChartItem[] = []
    for (const d of days) {
      const bar = new BarChartItem()
      bar.label = d.label
      bar.value = d.count
      mapped.push(bar)
    }
    this.bars = mapped
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('成长统计')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '汇总真实记录…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后查看统计',
          description: '柱状图与完成率来自你自己的灵感、计划和打卡',
          actionLabel: '去登录',
          onAction: (): void => { this.onRequireAuth() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppRingChart({
              title: '本周捕捉完成率',
              percent: GrowthStatsService.weekProgressRatio(this.snap.weekCapture, this.snap.weekGoal)
            })
            AppBarChart({ title: '本周每天记录条数', items: this.bars })
            Text(`计划均进度 ${this.snap.planAvgProgress}% · 打卡 ${this.snap.weekCheckIns} 天 · 专题 ${this.snap.topicCount} 个 · 本月打卡 ${this.snap.monthCheckIns}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text('数字全部来自你的灵感、画板、计划和本机打卡，没有演示曲线。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
              .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
