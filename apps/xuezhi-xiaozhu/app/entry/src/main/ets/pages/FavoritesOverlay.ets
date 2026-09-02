import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PathListCard } from '../components/cottage/CottageCards'
import { AuthService } from '../services/AuthService'
import { CottageItem } from '../models/CottageModels'
import { CottageBizService } from '../services/CottageBizService'
import { CottageNav } from '../services/CottageNav'

@Component
export struct FavoritesOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: CottageItem[] = []
  @State loading: boolean = true
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.items = []
      this.loading = false
      return
    }
    this.loading = true
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    this.items = await CottageBizService.loadFavorites(uid)
    this.loading = false
  }

  private openItem(item: CottageItem): void {
    const cardId = item.cardId.length > 0 ? item.cardId : item.id
    CottageNav.closeOverlay()
    CottageNav.openCard(cardId)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CottageNav.closeOverlay() })
        Text('我的收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (!AuthService.isLoggedIn()) {
        AppEmpty({
          title: '登录后查看收藏',
          description: '游客可浏览卡片；收藏需登录',
          actionLabel: '登录 / 注册',
          onAction: (): void => {
            CottageNav.closeOverlay()
            this.onRequireAuth()
          }
        })
      } else if (this.loading) {
        Text('加载收藏…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '收藏夹是空的',
          description: '在卡片详情点「收藏这张卡片」后会出现在这里'
        })
      } else {
        List() {
          ForEach(this.items, (item: CottageItem) => {
            ListItem() {
              PathListCard({
                title: item.title,
                summary: item.summary.length > 0 ? item.summary : '已收藏的知识卡片',
                meta: item.categoryLabel,
                coverKey: item.coverKey.length > 0 ? item.coverKey : 'card_variable',
                onOpen: (): void => { this.openItem(item) }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (item: CottageItem) => item.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
