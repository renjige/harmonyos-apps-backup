import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppLoading } from '../components/design-system/AppLoading'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CatalogItem } from '../models/CampModels'
import { GuideCard } from '../components/camp/GuideCard'
import { CampEmojiUtil } from '../utils/CampEmojiUtil'

@Component
export struct CommunityPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
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
    this.items = await CampBizService.loadPosts()
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
    Column() {
      AppHeader({ title: '露营社区', subtitle: CampEmojiUtil.communityHint() })
      Row() {
        AppButton({ label: '发布笔记', onTap: (): void => this.publish() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '加载社区笔记' }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '社区还很安静',
          description: '登录后可发布露营笔记',
          emojiMark: '⛺',
          actionLabel: '发布第一篇',
          onAction: (): void => this.publish()
        }).layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (p: CatalogItem) => {
            ListItem() {
              GuideCard({
                title: p.title,
                summary: p.summary.length > 0 ? p.summary : p.body,
                coverKey: p.coverKey.length > 0 ? p.coverKey : 'guide_tent',
                minutes: p.readMinutes,
                onTap: (): void => CampDetailNav.openPost(p.id)
              })
            }
          }, (p: CatalogItem) => p.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
