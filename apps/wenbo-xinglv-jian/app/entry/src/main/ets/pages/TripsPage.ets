import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TripListCard } from '../components/trip/TripListCard'
import { TripDateHelp, TripItem } from '../models/TripModels'
import { TripStore } from '../services/TripStore'
import { TripNav } from '../services/TripNav'

@Component
export struct TripsPage {
  @Prop appName: string = '行旅笺'
  @Prop @Watch('onVisibleChange') visible: boolean = true
  @Prop themeDark: boolean = false
  @StorageLink('tripRefresh') @Watch('onDataChange') tripRefresh: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State upcoming: TripItem[] = []
  @State active: TripItem[] = []
  @State done: TripItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onDataChange(): void {
    this.reload()
  }

  onVisibleChange(): void {
    if (this.visible) {
      this.reload()
    }
  }

  private reload(): void {
    const today = TripDateHelp.todayIso()
    const up: TripItem[] = []
    const act: TripItem[] = []
    const fin: TripItem[] = []
    for (const t of TripStore.allTrips()) {
      const s = TripDateHelp.liveTripStatus(t, today)
      if (s === 'active') {
        act.push(t)
      } else if (s === 'done' || s === 'cancelled') {
        fin.push(t)
      } else {
        up.push(t)
      }
    }
    this.upcoming = up
    this.active = act
    this.done = fin
  }

  private emptyAll(): boolean {
    return this.upcoming.length + this.active.length + this.done.length === 0
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_bg'))
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(140)
          .linearGradient({
            angle: 180,
            colors: [[Theme.heroScrimTop(this.darkModeOn), 0], [Theme.heroScrimBottom(this.darkModeOn), 1]]
          })
        Row() {
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('我的行程')
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
          }
          .align(Alignment.BottomStart)
          Blank()
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: '#FFFFFF' })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { TripNav.openSearch() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
      .height(140)

      if (this.emptyAll()) {
        Column() {
          AppEmpty({
            title: '还没有行程',
            description: '开始规划你的第一段旅途吧',
            actionLabel: '新建行程',
            onAction: (): void => { TripNav.openCreate() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            this.Section('进行中', this.active)
            this.Section('计划中', this.upcoming)
            this.Section('已结束', this.done)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: 88 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.themeDark || this.darkModeOn).surfacePage)
  }

  @Builder
  Section(title: string, list: TripItem[]) {
    if (list.length > 0) {
      Column({ space: Theme.space.s3 }) {
        Text(title)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textTertiary)
          .width('100%')
        ForEach(list, (t: TripItem, index: number) => {
          TripListCard({
            tripId: t.id,
            onTap: (): void => { TripNav.openDetail(t.id) }
          })
        }, (t: TripItem, index: number) => `${t.id}_${index}`)
      }
      .width('100%')
    }
  }
}
