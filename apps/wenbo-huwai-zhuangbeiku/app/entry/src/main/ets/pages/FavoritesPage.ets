import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { TrailListCard } from '../components/gear/TrailListCard'
import { CatalogItem } from '../models/GearModels'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'

@Component
export struct FavoritesPage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State items: CatalogItem[] = []
  @State loading: boolean = true
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await GearBizService.loadMine('favorites')
    this.loading = false
  }

  build() {
    DetailShell({ title: '收藏路线', onClose: () => GearDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取收藏' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '新用户为空。在路线详情可收藏精选路线。',
            actionLabel: '返回',
            onAction: () => GearDetailNav.close()
          })
        } else {
          ForEach(this.items, (t: CatalogItem) => {
            TrailListCard({
              title: t.title,
              meta: '已收藏',
              summary: t.summary,
              coverKey: t.coverKey.length > 0 ? t.coverKey : 'hero_ridge',
              onTap: () => {
                if (t.targetId.length > 0) {
                  GearDetailNav.openTrail(t.targetId)
                }
              }
            })
          }, (t: CatalogItem) => t.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
