import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { ItemCard } from '../components/trip/ItemCard'
import { MemoItem, TripDateHelp } from '../models/TripModels'
import { TripStore } from '../services/TripStore'
import { TripNav } from '../services/TripNav'

@Component
export struct HomePage {
  @Prop appName: string = '行程备忘'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop themeDark: boolean = false
  @StorageLink('homeDateIso') @Watch('onDateChange') homeDateIso: string = ''
  @StorageLink('smartRemindOn') smartRemindOn: boolean = true
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State items: MemoItem[] = []
  @State remindLine: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  onDateChange(): void {
    this.reload()
  }

  private viewDate(): Date {
    if (this.homeDateIso.length >= 8) {
      return TripDateHelp.parseIso(this.homeDateIso)
    }
    return new Date()
  }

  private viewIso(): string {
    return TripDateHelp.toIso(this.viewDate())
  }

  private isToday(): boolean {
    return this.viewIso() === TripDateHelp.todayIso()
  }

  private reload(): void {
    this.items = TripStore.itemsOnDate(this.viewIso())
    this.remindLine = this.buildRemind()
    AppStorage.setOrCreate('homeHasItems', this.items.length > 0)
  }

  private buildRemind(): string {
    if (!this.smartRemindOn) {
      return ''
    }
    let soon = 0
    const now = TripDateHelp.nowHm()
    for (const n of this.items) {
      const live = TripDateHelp.liveItemStatus(n, this.viewIso())
      if (live === 'pending' && n.time.length > 0 && n.time >= now) {
        soon += 1
      }
    }
    if (soon <= 0) {
      return ''
    }
    return `智慧提醒：还有 ${soon} 项未开始`
  }

  private countLine(): string {
    const n = this.items.length
    if (!this.isToday()) {
      if (n === 0) {
        return '这一天还没有安排'
      }
      return `这一天有 ${n} 项安排`
    }
    if (n === 0) {
      return '今天还没有安排'
    }
    return `今天有 ${n} 项安排`
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.paper_desk'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
        .opacity((this.themeDark || this.darkModeOn) ? 0.22 : 1)
      Column()
        .width('100%')
        .height(168)
        .linearGradient({
          angle: 180,
          colors: [[Theme.heroScrimTop(this.themeDark || this.darkModeOn), 0], [Theme.heroScrimBottom(this.themeDark || this.darkModeOn), 1]]
        })

      Column() {
        this.TopBar()
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Column({ space: 6 }) {
              Text(TripDateHelp.homeTitle(this.viewDate()))
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
                .width('100%')
              Text(TripDateHelp.weekdayLabel(this.viewDate()))
                .fontSize(Theme.type.body)
                .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textSecondary)
                .width('100%')
              Text(this.countLine())
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textTertiary)
                .width('100%')
              if (this.remindLine.length > 0) {
                Text(this.remindLine)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.palette(this.themeDark || this.darkModeOn).brandPrimary)
                  .width('100%')
                  .margin({ top: 4 })
              }
            }
            .width('100%')
            .padding({ top: 8 })

            if (this.items.length === 0) {
              this.EmptyBlock()
            } else {
              Column() {
                ForEach(this.items, (it: MemoItem, idx: number) => {
                  ItemCard({
                    item: it,
                    last: idx === this.items.length - 1,
                    onTap: (): void => { TripNav.openDetail(it.tripId) }
                  })
                }, (it: MemoItem) => it.id)
              }
              .width('100%')
              .padding({ bottom: Theme.space.s10 })
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: 88
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.themeDark || this.darkModeOn).surfacePage)
  }

  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.app_icon'))
        .width(28)
        .height(28)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      Text(this.appName)
        .fontSize(Theme.type.titleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
        .margin({ left: 10 })
      Blank()
      Column() {
        AppIcon({ name: 'calendar', iconSize: Theme.icon.md, color: Theme.palette(this.themeDark || this.darkModeOn).textPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick((): void => { TripNav.openCalendar() })
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.pageY,
      bottom: Theme.space.s2
    })
  }

  @Builder
  EmptyBlock() {
    Column({ space: Theme.space.s4 }) {
      Image($r('app.media.empty_timeline'))
        .width(148)
        .height(148)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
        .opacity((this.themeDark || this.darkModeOn) ? 0.72 : 1)
      Text('还没有行程')
        .fontSize(Theme.type.titleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
      Text('把接下来的安排，先记录下来')
        .fontSize(Theme.type.bodyM)
        .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textSecondary)
        .textAlign(TextAlign.Center)
      AppButton({
        label: '新建行程',
        onTap: (): void => { TripNav.openCreate() }
      })
        .width('72%')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: Theme.space.s8, bottom: Theme.space.s8 })
    .alignItems(HorizontalAlign.Center)
  }
}
