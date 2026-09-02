import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TripCard } from '../components/travel/TravelCards'
import { ChecklistItem, TripItem } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'

@Component
export struct TripsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State trips: TripItem[] = []
  @State loading: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onOpenTrip: (trip: TripItem) => void = () => {}
  onCreateTrip: () => void = () => {}
  onEditTrip: (trip: TripItem) => void = () => {}
  onDeleteTrip: (trip: TripItem) => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      const tripRows = await TravelService.trips()
      const items: ChecklistItem[] = await TravelService.checklistItems()
      this.trips = TravelService.attachProgress(tripRows, items)
    } catch {
      this.trips = []
    }
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '行程', subtitle: '从目的地到每日安排，一站规划' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppButton({ label: '创建新行程', onTap: () => this.onCreateTrip() })
          if (this.loading) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color(Theme.colors().brandPrimary)
          }
          if (this.trips.length === 0 && !this.loading) {
            AppEmpty({ title: '暂无行程', description: '创建行程后可安排每日时间轴，也可在攻略页使用模板',
              actionLabel: '重新加载', onAction: () => { void this.load() } })
          } else {
            ForEach(this.trips, (trip: TripItem) => {
              Column({ space: Theme.space.s2 }) {
                TripCard({ trip: trip, onTap: () => this.onOpenTrip(trip) })
                Row({ space: Theme.space.s4 }) {
                  Text('编辑行程')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .onClick(() => this.onEditTrip(trip))
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .onClick(() => this.onDeleteTrip(trip))
                }
                .width('100%')
                .padding({ bottom: Theme.space.s2 })
              }
            }, (trip: TripItem) => `${trip.id}-${trip.progress}`)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
