import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ItemCard } from './ItemCard'
import { ConfirmSheet } from './ConfirmSheet'
import { MemoItem, TripDateHelp, TripItem } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'

@Component
export struct TripDetailPane {
  @StorageLink('detailTripId') @Watch('onIdChange') tripId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State trip: TripItem = new TripItem()
  @State items: MemoItem[] = []
  @State showDelete: boolean = false
  @State missing: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onIdChange(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    const found = TripStore.findTrip(this.tripId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.trip = found
    this.items = TripStore.itemsOf(this.tripId)
  }

  private liveLabel(): string {
    const s = TripDateHelp.liveTripStatus(this.trip, TripDateHelp.todayIso())
    if (s === 'active') {
      return '进行中'
    }
    if (s === 'done') {
      return '已完成'
    }
    if (s === 'cancelled') {
      return '已取消'
    }
    return '即将开始'
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({
          title: this.trip.title.length > 0 ? this.trip.title : '行程详情',
          onBack: (): void => { TripNav.closeDetail() }
        })
        if (this.missing) {
          Text('找不到这条行程，可能已被删除。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            .padding(Theme.space.pageX)
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Column({ space: 8 }) {
                Text(this.trip.title)
                  .fontSize(Theme.type.titleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                  .width('100%')
                Text(this.trip.dateRange())
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                  .width('100%')
                if (this.trip.location.length > 0) {
                  Text(this.trip.location)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                    .width('100%')
                }
                Text(`共 ${this.trip.dayCount()} 天 · ${this.items.length} 项事项 · ${this.liveLabel()}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.palette(this.darkModeOn).textTertiary)
                  .width('100%')
                if (this.trip.remark.length > 0) {
                  Text(this.trip.remark)
                    .fontSize(Theme.type.bodyM)
                    .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                    .width('100%')
                    .margin({ top: 4 })
                }
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.card)

              if (this.items.length === 0) {
                Text('还没有事项。把这一天要做的事记下来。')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.palette(this.darkModeOn).textTertiary)
                  .width('100%')
              } else {
                Column() {
                  ForEach(this.items, (it: MemoItem) => {
                    ItemCard({
                      item: it,
                      showDate: it.itemDate !== this.trip.startDate || this.trip.dayCount() > 1,
                      last: false,
                      onTap: (): void => { TripNav.openItemForm(this.tripId, it.id) }
                    })
                  }, (it: MemoItem) => it.id)
                }
                .width('100%')
              }

              Row({ space: 12 }) {
                Text('编辑行程')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.palette(this.darkModeOn).brandPrimary)
                  .onClick((): void => { TripNav.openEditTrip(this.tripId) })
                Text('删除行程')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.palette(this.darkModeOn).danger)
                  .onClick((): void => { this.showDelete = true })
              }
              .width('100%')
              .padding({ top: 8, bottom: Theme.space.s10 })
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: 96
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        Column() {
          AppButton({
            label: '添加事项',
            onTap: (): void => { TripNav.openItemForm(this.tripId, '') }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s5
        })
        .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)

      if (this.showDelete) {
        ConfirmSheet({
          title: '删除行程',
          message: '将同时删除其中的事项。删除后无法恢复。',
          onConfirm: (): void => {
            void this.doDelete()
          },
          onCancel: (): void => { this.showDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private async doDelete(): Promise<void> {
    await TripStore.removeTrip(this.tripId)
    this.showDelete = false
    AppStorage.setOrCreate('toastText', '行程已删除')
    TripNav.closeDetail()
  }
}
