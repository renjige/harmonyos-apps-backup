import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { DetailShell } from '../components/detail/DetailShell'
import { GuideCard } from '../components/camp/GuideCard'
import { CatalogItem } from '../models/CampModels'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'

@Component
export struct PostsPage {
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
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
    this.items = await CampBizService.loadMine('posts')
    this.loading = false
  }

  private publish(): void {
    if (!AuthService.requireAuth('publish_guide')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openPostNew()
  }

  build() {
    DetailShell({ title: '我的攻略', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        AppButton({ label: '发布攻略', onTap: () => this.publish() })
        if (this.loading) {
          AppLoading({ label: '读取攻略' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有发布过攻略',
            description: '新账号默认空列表。写下装备评测或营地推荐即可。',
            actionLabel: '去发布',
            onAction: (): void => this.publish()
          })
        } else {
          ForEach(this.items, (p: CatalogItem) => {
            GuideCard({
              title: p.title,
              summary: p.summary.length > 0 ? p.summary : p.body,
              coverKey: p.coverKey.length > 0 ? p.coverKey : 'guide_tent',
              minutes: p.readMinutes,
              onTap: (): void => CampDetailNav.openPost(p.id)
            })
          }, (p: CatalogItem) => p.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
