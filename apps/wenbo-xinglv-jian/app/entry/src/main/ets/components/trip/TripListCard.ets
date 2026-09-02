import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TripDateHelp, TripItem } from '../../models/TripModels'
import { TripStore } from '../../services/TripStore'

@Component
export struct TripListCard {
  @Prop tripId: string = ''
  @StorageLink('tripRefresh') @Watch('onDataChange') tripRefresh: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State trip: TripItem = new TripItem()
  onTap: () => void = () => {}

  aboutToAppear(): void {
    this.loadTrip()
  }

  onDataChange(): void {
    this.loadTrip()
  }

  private loadTrip(): void {
    const found = TripStore.findTrip(this.tripId)
    if (found !== undefined) {
      this.trip = found
    }
  }

  private live(): string {
    return TripDateHelp.liveTripStatus(this.trip, TripDateHelp.todayIso())
  }

  private statusLabel(): string {
    const s = this.live()
    if (s === 'active') {
      return '进行中'
    }
    if (s === 'done') {
      return '已结束'
    }
    if (s === 'cancelled') {
      return '已取消'
    }
    return '计划中'
  }

  private dim(): number {
    return this.live() === 'done' || this.live() === 'cancelled' ? 0.55 : 1
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.trip.title)
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.statusLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.live() === 'active' ? Theme.palette(this.darkModeOn).brandPrimary : Theme.palette(this.darkModeOn).textTertiary)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.palette(this.darkModeOn).textTertiary })
      }
      .width('100%')
      Text(this.trip.dateRange())
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.palette(this.darkModeOn).textSecondary)
        .width('100%')
      Row() {
        if (this.trip.location.length > 0) {
          Text(this.trip.location)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.palette(this.darkModeOn).textTertiary)
            .layoutWeight(1)
            .maxLines(1)
        } else {
          Blank().layoutWeight(1)
        }
        Text(`${TripStore.itemCount(this.trip.id)} 项事项`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.palette(this.darkModeOn).textTertiary)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
    .borderRadius(Theme.radius.card)
    .opacity(this.dim())
    .onClick((): void => { this.onTap() })
  }
}
