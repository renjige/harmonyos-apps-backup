import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { PuzzleListCard } from '../components/puzzle/PuzzleListCard'
import { TravelPuzzle } from '../models/PuzzleModels'
import { PuzzleStore } from '../services/PuzzleStore'
import { PuzzleNav } from '../services/PuzzleNav'

@Component
export struct FootprintPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State viewMode: string = 'timeline'
  @State puzzles: TravelPuzzle[] = []
  @State tripCount: number = 0
  @State cityCount: number = 0
  @State photoCount: number = 0
  @State locations: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.puzzles = PuzzleStore.sortedPuzzles()
    const stats = PuzzleStore.stats()
    this.tripCount = stats.tripCount
    this.cityCount = stats.cityCount
    this.photoCount = stats.photoCount
    this.locations = PuzzleStore.locations()
  }

  @Builder
  StatsRow() {
    Row({ space: Theme.space.s2 }) {
      AppStatCard({ label: '旅行次数', value: `${this.tripCount}` }).layoutWeight(1)
      AppStatCard({ label: '到访城市', value: `${this.cityCount}` }).layoutWeight(1)
      AppStatCard({ label: '累计照片', value: `${this.photoCount}` }).layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  ModeSwitch() {
    Row({ space: Theme.space.s2 }) {
      Text('时间线')
        .fontSize(Theme.type.subhead)
        .fontWeight(this.viewMode === 'timeline' ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.viewMode === 'timeline' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor(this.viewMode === 'timeline' ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => { this.viewMode = 'timeline' })
      Text('地图足迹')
        .fontSize(Theme.type.subhead)
        .fontWeight(this.viewMode === 'map' ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.viewMode === 'map' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor(this.viewMode === 'map' ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick(() => { this.viewMode = 'map' })
    }
    .width('100%')
  }

  @Builder
  TimelineBody() {
    if (this.puzzles.length === 0) {
      Column() {
        AppEmpty({
          title: '还没有旅行拼图',
          description: '去「拼图」页创建你的第一张旅行拼图吧',
          actionLabel: '去创建',
          onAction: (): void => { PuzzleNav.openCreate() }
        })
      }
      .width('100%')
      .padding({ top: Theme.space.s8, bottom: Theme.space.s10 })
      .alignItems(HorizontalAlign.Center)
    } else {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.puzzles, (item: TravelPuzzle) => {
          PuzzleListCard({
            item: item,
            onTap: (): void => { PuzzleNav.openDetail(item.id) }
          })
        }, (item: TravelPuzzle) => item.id)
      }
      .width('100%')
      .padding({ bottom: Theme.space.s10 })
    }
  }

  @Builder
  MapBody() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.map_bg'))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(200)
        .borderRadius(Theme.radius.lg)
        .backgroundColor('rgba(45,58,74,0.10)')
    }
    .width('100%')
    .margin({ bottom: Theme.space.s4 })

    if (this.locations.length === 0) {
      AppEmpty({
        title: '还没有足迹',
        description: '创建拼图并填写地点后，会出现在地图足迹中'
      })
    } else {
      Column({ space: Theme.space.s3 }) {
        ForEach(this.locations, (loc: string) => {
          Row() {
            AppIcon({ name: 'map', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            Column() {
              Text(loc)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('已记录的旅行地点')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .margin({ top: Theme.space.s1 })
            }
            .layoutWeight(1)
            .margin({ left: Theme.space.s3 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (loc: string) => loc)
      }
      .width('100%')
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_bg'))
          .width('100%')
          .height(152)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(152)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(45,58,74,0.78)', 1]]
          })
        Column() {
          Text('旅行拼图')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('碎片 · 拼合 · 完整')
            .fontSize(Theme.type.subhead)
            .fontColor('#FFFFFF')
            .margin({ top: Theme.space.s1 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')

      Scroll() {
        Column() {
          this.StatsRow()
          this.ModeSwitch()

          if (this.viewMode === 'map') {
            this.MapBody()
          } else {
            this.TimelineBody()
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s4
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
