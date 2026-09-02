import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { RouteCard } from '../components/wander/RouteCard'
import { RouteItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'

@Component
export struct FavoritesPage {
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: RouteItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const ids = await WanderLocalStore.loadFavoriteIds()
    const all = await WanderBizService.loadRoutes()
    const next: RouteItem[] = []
    for (const r of all) {
      for (const id of ids) {
        if (r.id === id) {
          next.push(r)
        }
      }
    }
    this.items = next
  }

  private kindLabel(r: RouteItem): string {
    const d = r.durationKind === 'weekend' ? '周末' : (r.durationKind === 'day' ? '一日' : '半日')
    const s = r.sceneKind === 'city' ? '城市' : '自然'
    return `${d} · ${s}`
  }

  build() {
    DetailShell({ title: '收藏的漫游点', onClose: () => WanderDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '在漫游点详情里，把想再走的留下来。',
            actionLabel: '去看地图',
            onAction: (): void => WanderDetailNav.close()
          })
        } else {
          ForEach(this.items, (r: RouteItem) => {
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
