import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { RouteCard } from '../components/wander/RouteCard'
import { FilterChip, RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'

@Component
export struct RoutesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State filter: string = 'all'
  @State routes: RouteItem[] = []
  @State shown: RouteItem[] = []
  private chips: FilterChip[] = RoutesPage.makeChips()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static makeChips(): FilterChip[] {
    const out: FilterChip[] = []
    const c0 = new FilterChip()
    c0.id = 'all'
    c0.label = '全部'
    out.push(c0)
    const c1 = new FilterChip()
    c1.id = 'halfday'
    c1.label = '半日'
    out.push(c1)
    const c2 = new FilterChip()
    c2.id = 'day'
    c2.label = '一日'
    out.push(c2)
    const c3 = new FilterChip()
    c3.id = 'weekend'
    c3.label = '周末'
    out.push(c3)
    const c4 = new FilterChip()
    c4.id = 'nature'
    c4.label = '自然'
    out.push(c4)
    const c5 = new FilterChip()
    c5.id = 'city'
    c5.label = '城市'
    out.push(c5)
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.routes = await WanderBizService.loadRoutes()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const next: RouteItem[] = []
    for (const r of this.routes) {
      if (r.matchesFilter(this.filter)) {
        next.push(r)
      }
    }
    this.shown = next
  }

  private kindLabel(r: RouteItem): string {
    const d = r.durationKind === 'weekend' ? '周末' : (r.durationKind === 'day' ? '一日' : '半日')
    const s = r.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
  }

  build() {
    Column() {
      Text('路线')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (c: FilterChip) => {
            Text(c.label)
              .fontSize(Theme.type.footnote)
              .fontColor(this.filter === c.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.filter === c.id ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.filter = c.id
                this.applyFilter()
              })
          }, (c: FilterChip) => c.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      if (this.loading) {
        AppLoading({ label: '展开路线' }).layoutWeight(1)
      } else if (this.shown.length === 0) {
        AppEmpty({
          title: '这一类还空着',
          description: '换一个筛选，或稍后重试',
          actionLabel: '重试',
          onAction: () => { void this.reload() }
        }).layoutWeight(1)
      } else {
        List({ space: 14 }) {
          ForEach(this.shown, (r: RouteItem) => {
            ListItem() {
              RouteCard({
                title: r.title,
                summary: r.summary,
                coverKey: r.coverKey,
                duration: r.duration,
                difficulty: r.difficulty,
                kindLabel: this.kindLabel(r),
                onTap: (): void => WanderDetailNav.openRoute(r.id)
              })
            }
          }, (r: RouteItem) => r.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
