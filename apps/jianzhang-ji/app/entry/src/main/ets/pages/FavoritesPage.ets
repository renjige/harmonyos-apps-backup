import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { BrochureListCard } from '../components/brochure/BrochureListCard'
import { BrochureItem } from '../models/BrochureModels'
import { BrochureBizService } from '../services/BrochureBizService'
import { BrochureDetailNav } from '../services/BrochureDetailNav'
import { FavoriteService } from '../services/FavoriteService'
import { CompareStore } from '../services/CompareStore'
import { AuthService } from '../services/AuthService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State brochures: BrochureItem[] = []
  @State favItems: BrochureItem[] = []
  @State loading: boolean = true
  @StorageLink('favoriteTick') @Watch('onFavTick') favoriteTick: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onFavTick(): void {
    void this.applyFavorites()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      await FavoriteService.syncFromServer()
    }
    this.brochures = await BrochureBizService.loadBrochures()
    this.applyFavorites()
    this.loading = false
  }

  private applyFavorites(): void {
    const ids = FavoriteService.listIds()
    const out: BrochureItem[] = []
    for (let id of ids) {
      const found = BrochureBizService.findBrochure(this.brochures, id)
      if (found !== undefined) {
        out.push(found)
      }
    }
    this.favItems = out
  }

  build() {
    Column() {
      AppHeader({ title: '收藏', subtitle: '我收藏的招生简章' })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.favItems.length === 0) {
            AppEmpty({
              title: '暂无收藏',
              description: '在简章详情页点击「收藏」；游客可先本地收藏，登录后同步云端',
              actionLabel: '去首页浏览',
              onAction: (): void => {
                AppStorage.setOrCreate('mainTab', 0)
              }
            })
          } else {
            if (AuthService.isLoggedIn()) {
              Text('已登录 · 收藏已与云端同步')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              Row({ space: Theme.space.s2 }) {
                Text('游客模式 · 收藏保存在本机')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .layoutWeight(1)
                Text('登录同步')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .onClick((): void => { this.onRequireAuth() })
              }
              .width('100%')
            }
            ForEach(this.favItems, (row: BrochureItem) => {
              BrochureListCard({
                item: row,
                favorited: true,
                inCompare: CompareStore.contains(row.id),
                onTap: (): void => { BrochureDetailNav.openBrochure(row.id) }
              })
            }, (row: BrochureItem) => row.id)
            AppButton({
              label: '刷新列表',
              variant: 'secondary',
              onTap: (): void => { void this.reload() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
