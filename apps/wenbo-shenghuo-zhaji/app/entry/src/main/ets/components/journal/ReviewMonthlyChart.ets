import { Theme } from '../design-system/Theme'
import { AppBarChart, BarChartItem } from '../design-system/AppChart'
import { MonthStatItem } from '../../models/JournalModels'

@Component
export struct ReviewMonthlyChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop months: MonthStatItem[] = []

  private barItems(): BarChartItem[] {
    const out: BarChartItem[] = []
    for (let i = 0; i < this.months.length; i++) {
      const m = this.months[i]
      const item = new BarChartItem()
      item.value = m.diaryCount > 0 ? m.diaryCount : m.imageCount
      item.label = `${m.month}月`
      out.push(item)
    }
    return out
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('月度记录趋势')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('柱高为当月札记篇数（无札记时显示配图数）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      AppBarChart({
        title: '',
        items: this.barItems()
      })
    }
    .width('100%')
  }
}
