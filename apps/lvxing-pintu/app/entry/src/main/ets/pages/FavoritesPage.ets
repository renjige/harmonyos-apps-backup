import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { PuzzleListCard } from '../components/puzzle/PuzzleListCard'
import { TravelPuzzle } from '../models/PuzzleModels'
import { PuzzleStore } from '../services/PuzzleStore'
import { PuzzleNav } from '../services/PuzzleNav'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: TravelPuzzle[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = PuzzleStore.favorites()
  }

  build() {
    Column() {
      Column() {
        Text('拼图收藏')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('收藏喜欢的拼图，随时回顾旅行故事')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .margin({ top: Theme.space.s1 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Image($r('app.media.banner_02'))
        .width('100%')
        .height(100)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有收藏',
          description: '在拼图详情页点击心形图标，即可加入收藏'
        })
          .layoutWeight(1)
          .padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: TravelPuzzle) => {
              PuzzleListCard({
                item: item,
                onTap: (): void => { PuzzleNav.openDetail(item.id) }
              })
            }, (item: TravelPuzzle) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s10 })
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
