import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { CampCard } from '../components/camp/CampCard'
import { CatalogItem } from '../models/CampModels'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'

@Component
export struct FavoritesPage {
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: CatalogItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await CampBizService.loadMine('favorites')
    this.loading = false
  }

  build() {
    DetailShell({ title: '我的收藏', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取收藏' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏营地',
            description: '在营地详情里把想再去的留下来。新账号默认空列表。',
            actionLabel: '去发现营地',
            onAction: (): void => CampDetailNav.close()
          })
        } else {
          ForEach(this.items, (f: CatalogItem) => {
            CampCard({
              title: f.title,
              summary: f.summary.length > 0 ? f.summary : '已收藏',
              coverKey: f.coverKey.length > 0 ? f.coverKey : 'hero_camp_night',
              region: f.region.length > 0 ? f.region : f.summary,
              campType: '已收藏',
              rating: f.rating,
              onTap: (): void => {
                if (f.campId.length > 0) {
                  CampDetailNav.openCamp(f.campId)
                }
              }
            })
          }, (f: CatalogItem) => f.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
