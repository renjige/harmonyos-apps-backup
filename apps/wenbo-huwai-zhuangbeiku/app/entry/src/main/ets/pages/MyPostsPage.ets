import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { NoteListCard } from '../components/gear/NoteListCard'
import { CatalogItem } from '../models/GearModels'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'

@Component
export struct MyPostsPage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State items: CatalogItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await GearBizService.loadMine('posts')
    this.loading = false
  }

  build() {
    DetailShell({ title: '我的动态', onClose: () => GearDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取动态' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有动态',
            description: '新用户为空。登录后可在社区发布装备与路线心得。',
            actionLabel: '去发布',
            onAction: () => GearDetailNav.openPostNew()
          })
        } else {
          ForEach(this.items, (p: CatalogItem) => {
            NoteListCard({
              title: p.title,
              summary: p.summary.length > 0 ? p.summary : p.body,
              coverKey: p.coverKey.length > 0 ? p.coverKey : 'banner_ready',
              minutes: 0,
              onTap: () => GearDetailNav.openPost(p.id)
            })
          }, (p: CatalogItem) => p.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
