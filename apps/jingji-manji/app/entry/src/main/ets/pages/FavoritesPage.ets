import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { SportListCard } from '../components/sport/SportListCard'
import { SportRecord } from '../models/SportModels'
import { FavoriteStore } from '../services/FavoriteStore'
import { SportStore } from '../services/SportStore'
import { SportDetailNav } from '../services/SportDetailNav'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: SportRecord[] = []
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const out: SportRecord[] = []
    for (const fav of FavoriteStore.list()) {
      if (fav.targetType === 'record') {
        const r = SportStore.findById(fav.targetId)
        if (r !== null) {
          out.push(r)
        }
      }
    }
    this.items = out
  }

  build() {
    Column({ space: Theme.space.s5 }) {
      Row() {
        Text('我的收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({
          label: '关闭',
          variant: 'secondary',
          onTap: (): void => {
            SportDetailNav.close()
          }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有收藏',
          description: '在训练详情页点「收藏」即可加入此处。',
          actionLabel: '去训练页',
          onAction: (): void => {
            SportDetailNav.close()
          }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            ForEach(this.items, (r: SportRecord) => {
              SportListCard({
                record: r,
                onTap: (): void => {
                  SportDetailNav.open(r.id)
                }
              })
            }, (r: SportRecord) => r.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
