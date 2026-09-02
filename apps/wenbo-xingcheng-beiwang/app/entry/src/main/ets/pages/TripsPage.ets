import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TripListCard } from '../components/trip/TripListCard'
import { TripDateHelp, TripItem } from '../models/TripModels'
import { TripStore } from '../services/TripStore'
import { TripNav } from '../services/TripNav'

@Component
export struct TripsPage {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop themeDark: boolean = false
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State upcoming: TripItem[] = []
  @State active: TripItem[] = []
  @State done: TripItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const today = TripDateHelp.todayIso()
    const up: TripItem[] = []
    const act: TripItem[] = []
    const done: TripItem[] = []
    for (const t of TripStore.allTrips()) {
      const s = TripDateHelp.liveTripStatus(t, today)
      if (s === 'active') {
        act.push(t)
      } else if (s === 'done' || s === 'cancelled') {
        done.push(t)
      } else {
        up.push(t)
      }
    }
    this.upcoming = up
    this.active = act
    this.done = done
  }

  private emptyAll(): boolean {
    return this.upcoming.length + this.active.length + this.done.length === 0
  }

  build() {
    Column() {
      Row() {
        Text('行程')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
        Blank()
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.palette(this.themeDark || this.darkModeOn).textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { TripNav.openSearch() })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      if (this.emptyAll()) {
        Column() {
          AppEmpty({
            title: '还没有行程',
            description: '从空白开始，或用一个简单模板。',
            actionLabel: '使用模板',
            onAction: (): void => { TripNav.openTemplates() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s6 }) {
            this.Section('进行中', this.active)
            this.Section('即将开始', this.upcoming)
            this.Section('已完成', this.done)
            Text('使用模板')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.palette(this.themeDark || this.darkModeOn).brandPrimary)
              .padding({ top: 8, bottom: Theme.space.s10 })
              .onClick((): void => { TripNav.openTemplates() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 88 })
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
        ForEach(list, (t: TripItem) => {
          TripListCard({
            trip: t,
            onTap: (): void => { TripNav.openDetail(t.id) }
          })
        }, (t: TripItem) => t.id)
      }
      .width('100%')
    }
  }
}
