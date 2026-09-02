import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TripItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'
import { ScenicMedia } from '../services/ScenicMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct TripListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State trips: TripItem[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.trips = await ScenicBizService.loadTrips()
    this.loading = false
  }

  private newTrip(): void {
    if (!AuthService.requireAuth('save_trip')) {
      this.onRequireAuth()
      return
    }
    ScenicDetailNav.openTripNew('', '', 'hero_bg')
  }

  build() {
    Column() {
      Row() {
        Text('我的行程')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('新建行程')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick(() => this.newTrip())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

      if (this.loading) {
        AppLoading({ label: '读取行程' }).layoutWeight(1)
      } else if (this.trips.length === 0) {
        Column({ space: 12 }) {
          AppEmpty({
            title: '还没有保存的行程',
            description: '从目的地详情或这里开始智能规划。新用户列表为空。',
            actionLabel: '新建行程',
            onAction: () => { this.newTrip() }
          })
        }
        .layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.trips, (t: TripItem) => {
            ListItem() {
              Row({ space: 12 }) {
                Image(ScenicMedia.resource(t.coverKey))
                  .width(88)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 4 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(`${t.destName} · ${t.days} 日 · ${t.prefLabel()}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => ScenicDetailNav.openTrip(t.id))
            }
          }, (t: TripItem) => t.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
