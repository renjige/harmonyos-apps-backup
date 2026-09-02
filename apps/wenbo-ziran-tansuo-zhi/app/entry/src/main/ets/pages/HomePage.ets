import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DiscoverCard } from '../components/nq/DiscoverCard'
import { TipItem, TrailItem } from '../models/NqModels'
import { NqBizService } from '../services/NqBizService'
import { NqDetailNav } from '../services/NqDetailNav'
import { NqMedia } from '../services/NqMedia'

class CatChip {
  label: string = ''
  value: string = ''

  constructor(label: string, value: string) {
    this.label = label
    this.value = value
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '自然探索志'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('prefInterest') prefInterest: string = 'forest'
  @State category: string = ''
  @State trails: TrailItem[] = []
  @State shown: TrailItem[] = []
  @State leftCol: TrailItem[] = []
  @State rightCol: TrailItem[] = []
  @State recommended: TrailItem[] = []
  @State todayTip: TipItem = new TipItem()
  @State hasToday: boolean = false
  @State loading: boolean = true
  private categories: CatChip[] = [
    new CatChip('全部', ''),
    new CatChip('森林徒步', 'forest'),
    new CatChip('山川风光', 'mountain'),
    new CatChip('湖泊湿地', 'lake'),
    new CatChip('星空观测', 'star'),
    new CatChip('城市公园', 'park')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trails = await NqBizService.loadTrails('', '')
    const tips = await NqBizService.loadTips()
    const tip = NqBizService.todayTip(tips)
    this.hasToday = tip !== undefined
    if (tip !== undefined) {
      this.todayTip = tip
    }
    this.recommended = NqBizService.recommendTrails(this.trails, this.prefInterest)
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    this.shown = NqBizService.filterByDiscoverCategory(this.trails, this.category)
    this.splitWaterfall(this.shown)
  }

  private splitWaterfall(items: TrailItem[]): void {
    const left: TrailItem[] = []
    const right: TrailItem[] = []
    let i = 0
    for (const t of items) {
      if (i % 2 === 0) {
        left.push(t)
      } else {
        right.push(t)
      }
      i += 1
    }
    this.leftCol = left
    this.rightCol = right
  }

  private setCategory(next: string): void {
    this.category = next
    this.applyFilter()
  }

  private interestLabel(): string {
    if (this.prefInterest === 'lake') {
      return '湖泊湿地'
    }
    if (this.prefInterest === 'star') {
      return '星空观测'
    }
    if (this.prefInterest === 'park') {
      return '城市公园'
    }
    if (this.prefInterest === 'mountain') {
      return '山川风光'
    }
    return '森林徒步'
  }

  build() {
    Column() {
      if (this.loading) {
        Scroll() {
          Column() {
            AppLoading({ label: '加载自然秘境' })
          }
          .width('100%')
          .padding({ top: Theme.space.s10, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (this.trails.length === 0) {
        Scroll() {
          Column() {
            AppEmpty({
              title: '暂时读不到探索点',
              description: '栏目来自平台，请检查网络后重试。',
              actionLabel: '重新加载',
              onAction: (): void => { void this.reload() }
            })
          }
          .width('100%')
          .padding({ top: Theme.space.s6, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        Scroll() {
          Column() {
            this.Hero()
            Column({ space: Theme.space.s5 }) {
              if (this.hasToday) {
                this.TodayTip()
              }
              this.RecommendRow()
              this.CategoryChips()
              this.Waterfall()
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s4,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Hero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(NqMedia.resource('hero_forest_path'))
        .width('100%')
        .height(260)
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height(156)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.88)', 1]]
        })
      Column({ space: Theme.space.s3 }) {
        Text('走进自然，记录每一刻')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('100%')
        Text(this.appName)
          .fontSize(Theme.type.footnote)
          .fontColor('#F5F0E8')
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 18 })
      .width('100%')
    }
    .width('100%')
    .height(260)
  }

  @Builder
  TodayTip() {
    Column({ space: Theme.space.s2 }) {
      Text('今日自然灵感')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Image(NqMedia.resource(this.todayTip.coverKey))
          .width(88)
          .height(88)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Column({ space: 4 }) {
          Text(this.todayTip.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.todayTip.summary)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .width('100%')
        }
        .layoutWeight(1)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
      }
      .width('100%')
      .padding(Theme.space.s3)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => NqDetailNav.openTip(this.todayTip.id))
    }
    .width('100%')
  }

  @Builder
  RecommendRow() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('智慧推荐')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text(`偏好 · ${this.interestLabel()}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.recommended, (t: TrailItem) => {
            DiscoverCard({
              item: t,
              cardHeight: 140,
              onTap: (): void => NqDetailNav.openSpot(t.id)
            })
              .width(200)
          }, (t: TrailItem) => `rec-${t.id}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height(196)
    }
    .width('100%')
  }

  @Builder
  CategoryChips() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(this.categories, (c: CatChip) => {
          Text(c.label)
            .fontSize(Theme.type.footnote)
            .fontColor(this.category === c.value ?
              Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.category === c.value ?
              Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setCategory(c.value))
        }, (c: CatChip) => c.value)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(40)
  }

  @Builder
  Waterfall() {
    Column({ space: Theme.space.s2 }) {
      Text('探索发现')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.leftCol, (t: TrailItem, idx: number) => {
            DiscoverCard({
              item: t,
              cardHeight: idx % 2 === 0 ? 168 : 200,
              onTap: (): void => NqDetailNav.openSpot(t.id)
            })
          }, (t: TrailItem) => `L-${t.id}`)
        }
        .layoutWeight(1)

        Column({ space: Theme.space.s3 }) {
          ForEach(this.rightCol, (t: TrailItem, idx: number) => {
            DiscoverCard({
              item: t,
              cardHeight: idx % 2 === 0 ? 200 : 168,
              onTap: (): void => NqDetailNav.openSpot(t.id)
            })
          }, (t: TrailItem) => `R-${t.id}`)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
  }
}
