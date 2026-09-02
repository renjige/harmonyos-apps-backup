import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { AppCard } from '../components/design-system/AppCard'

function buildTrendItems(): BarChartItem[] {
  const items: BarChartItem[] = []
  const values: number[] = [18, 22, 20, 26, 24]
  const labels: string[] = ['一', '二', '三', '四', '五']
  for (let i = 0; i < values.length; i++) {
    const item = new BarChartItem()
    item.value = values[i]
    item.label = labels[i]
    items.push(item)
  }
  return items
}

@Component
export struct DashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  private trendItems: BarChartItem[] = buildTrendItems()

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        AppHeader({ title: '数据看板', subtitle: '经营指标与趋势' })
        Column() {
          AppRingChart({ title: '任务完成率', percent: 0.78 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        Column() {
          AppBarChart({
            title: '近五日业务趋势',
            items: this.trendItems
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        Column() {
          AppCard({ title: '预警', variant: 'outlined' }) {
            Text('存在 2 项高优待办，建议今日闭环。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).warning)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
      .padding({ bottom: Theme.space.s8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
