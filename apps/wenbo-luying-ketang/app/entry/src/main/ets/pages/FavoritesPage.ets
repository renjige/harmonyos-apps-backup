import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { GuideCard } from '../components/camp/GuideCard'
import { FavoriteEntry, FavoriteService } from '../services/FavoriteService'
import { CampDetailNav } from '../services/CampDetailNav'

@Component
export struct FavoritesPage {
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @State items: FavoriteEntry[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = FavoriteService.list()
    this.loading = false
  }

  private openItem(entry: FavoriteEntry): void {
    if (entry.kind === 'post') {
      CampDetailNav.openPost(entry.targetId)
      return
    }
    CampDetailNav.openGuide(entry.targetId)
  }

  build() {
    DetailShell({ title: '我的收藏', onClose: () => CampDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取收藏' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏内容',
            description: '在课程或社区笔记详情里点「收藏」，方便下次快速打开。',
            emojiMark: '⭐',
            actionLabel: '返回',
            onAction: (): void => CampDetailNav.close()
          })
        } else {
          ForEach(this.items, (f: FavoriteEntry) => {
            GuideCard({
              title: f.title,
              summary: f.kind === 'post' ? '社区笔记' : '精品课程',
              coverKey: f.coverKey,
              minutes: 0,
              onTap: (): void => this.openItem(f)
            })
          }, (f: FavoriteEntry) => f.targetId)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
