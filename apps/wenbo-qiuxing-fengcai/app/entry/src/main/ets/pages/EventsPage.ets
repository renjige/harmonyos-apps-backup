import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { SportCategoryBar, SportCategoryKey } from '../components/sports/SportCategoryBar'
import { EventListCard } from '../components/sports/EventListCard'
import { EventItem } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'

class StatusTab {
  key: string = 'upcoming'
  label: string = '未开始'

  static all(): StatusTab[] {
    const out: StatusTab[] = []
    const t0 = new StatusTab()
    t0.key = 'upcoming'
    t0.label = '未开始'
    out.push(t0)
    const t1 = new StatusTab()
    t1.key = 'live'
    t1.label = '进行中'
    out.push(t1)
    const t2 = new StatusTab()
    t2.key = 'finished'
    t2.label = '已结束'
    out.push(t2)
    return out
  }
}

@Component
export struct EventsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @Prop embedded: boolean = false
  @State selectedCategory: SportCategoryKey = 'all'
  @State selectedStatus: string = 'upcoming'
  @State items: EventItem[] = []
  @State loading: boolean = true
  private statusTabs: StatusTab[] = StatusTab.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private sportFilter(): string {
    if (this.selectedCategory === 'all') {
      return ''
    }
    return this.selectedCategory
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await StarBizService.loadEvents(this.sportFilter(), '', this.selectedStatus)
    this.loading = false
  }

  build() {
    Column() {
      if (!this.embedded) {
        AppHeader({ title: '赛事', subtitle: '赛程日历 · 按项目筛选 · 设置提醒' })
      }
      SportCategoryBar({
        selected: this.selectedCategory,
        onSelect: (key: SportCategoryKey): void => {
          this.selectedCategory = key
          void this.reload()
        }
      })
      .margin({ bottom: Theme.space.s2 })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.statusTabs, (tab: StatusTab) => {
            Text(tab.label)
              .fontSize(Theme.type.caption)
              .fontWeight(this.selectedStatus === tab.key ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.selectedStatus === tab.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.selectedStatus === tab.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({
                width: 1,
                color: this.selectedStatus === tab.key ?
                  Theme.colors().brandPrimary : Theme.colors().strokeHairline
              })
              .onClick((): void => {
                this.selectedStatus = tab.key
                void this.reload()
              })
          }, (tab: StatusTab) => tab.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: Theme.space.s3 })

      if (this.loading) {
        AppLoading({ label: '加载赛事…' }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: this.selectedStatus === 'finished' ? '暂无已结束赛事' :
            (this.selectedStatus === 'live' ? '暂无进行中赛事' : '暂无未开始赛事'),
          description: this.selectedStatus === 'finished' ?
            '历史赛程会在开赛后自动归入此处' :
            '下拉刷新或切换项目分类；开赛后状态会自动更新',
          actionLabel: '刷新',
          onAction: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: EventItem) => {
            ListItem() {
              EventListCard({
                item: item,
                onTap: (): void => { StarDetailNav.openEvent(item.id) }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (item: EventItem) => item.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
