import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { RouteCard } from '../components/wander/RouteCard'
import { RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State all: RouteItem[] = []
  @State shown: RouteItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.all = await WanderBizService.loadRoutes()
    this.applyQuery()
  }

  private applyQuery(): void {
    const next: RouteItem[] = []
    for (const r of this.all) {
      if (r.matchesQuery(this.query.trim())) {
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
    DetailShell({ title: '搜索', onClose: () => WanderDetailNav.close() }) {
      Column({ space: 12 }) {
        TextInput({ text: this.query, placeholder: '溪谷、湖畔、古镇…' })
          .onChange((v: string) => {
            this.query = v
            this.applyQuery()
          })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        if (this.shown.length === 0) {
          AppEmpty({
            title: '没有找到这条路',
            description: '换个词，或者把风放慢一点。'
          })
        } else {
          ForEach(this.shown, (r: RouteItem) => {
            RouteCard({
              title: r.title,
              summary: r.summary,
              coverKey: r.coverKey,
              duration: r.duration,
              difficulty: r.difficulty,
              kindLabel: this.kindLabel(r),
              onTap: (): void => WanderDetailNav.openRoute(r.id)
            })
          }, (r: RouteItem) => r.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
