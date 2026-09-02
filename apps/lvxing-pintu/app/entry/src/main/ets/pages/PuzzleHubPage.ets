import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { PuzzleListCard } from '../components/puzzle/PuzzleListCard'
import { TravelPuzzle } from '../models/PuzzleModels'
import { PuzzleStore } from '../services/PuzzleStore'
import { PuzzleNav } from '../services/PuzzleNav'

@Component
export struct PuzzleHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State puzzles: TravelPuzzle[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.puzzles = PuzzleStore.sortedPuzzles()
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('旅行拼图')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('选择照片，智能布局，拼合旅行故事')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin({ top: Theme.space.s1 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Image($r('app.media.banner_01'))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      AppButton({
        label: '＋ 创建新拼图',
        onTap: (): void => { PuzzleNav.openCreate() }
      })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })

      Text('我的拼图')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })

      if (this.puzzles.length === 0) {
        AppEmpty({
          title: '还没有拼图',
          description: '选择 3～9 张照片，挑选布局模板，为每张照片写下旅行瞬间'
        })
          .layoutWeight(1)
          .padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.puzzles, (item: TravelPuzzle) => {
              PuzzleListCard({
                item: item,
                onTap: (): void => { PuzzleNav.openDetail(item.id) }
              })
            }, (item: TravelPuzzle) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
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
