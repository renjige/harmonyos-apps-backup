import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AuthService } from '../services/AuthService'

@Component
export struct DashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private trendItems: BarChartItem[] = []

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        AppHeader({ title: '成长看板', subtitle: '仅展示你自己的数据' })
        if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看看板',
            description: '游客不展示任何个人统计或示例数字'
          })
        } else {
          Column() {
            AppRingChart({ title: '目标完成率', percent: 0 })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')
          Column() {
            AppBarChart({
              title: '近五日记录',
              items: this.trendItems
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .width('100%')
        }
      }
      .padding({ bottom: Theme.space.s8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
